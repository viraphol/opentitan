// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Base class providing common methods required for DMA testing
class dma_base_vseq extends cip_base_vseq #(
  .RAL_T              (dma_reg_block),
  .CFG_T              (dma_env_cfg),
  .COV_T              (dma_env_cov),
  .VIRTUAL_SEQUENCER_T(dma_virtual_sequencer)
);

  `uvm_object_utils(dma_base_vseq)

  // response sequences
  dma_pull_seq #(.AddrWidth(HOST_ADDR_WIDTH)) seq_host;
  dma_pull_seq #(.AddrWidth(CTN_ADDR_WIDTH)) seq_ctn;
  dma_pull_seq #(.AddrWidth(SYS_ADDR_WIDTH)) seq_sys;

  // DMA configuration item
  dma_seq_item dma_config;

  // Event triggers
  event e_busy;
  event e_complete;
  event e_aborted;
  event e_errored;

  function new (string name = "");
    super.new(name);
    dma_config = dma_seq_item::type_id::create("dma_config");
    // response sequences
    seq_ctn = dma_pull_seq #(.AddrWidth(CTN_ADDR_WIDTH))::type_id::create("seq_ctn");
    seq_host = dma_pull_seq #(.AddrWidth(HOST_ADDR_WIDTH))::type_id::create("seq_host");
    seq_sys  = dma_pull_seq #(.AddrWidth(SYS_ADDR_WIDTH))::type_id::create("seq_sys");
    // Create memory models
    seq_host.fifo = dma_handshake_mode_fifo#(
                                .AddrWidth(HOST_ADDR_WIDTH))::type_id::create("fifo_host");
    seq_ctn.fifo = dma_handshake_mode_fifo#(
                                .AddrWidth(CTN_ADDR_WIDTH))::type_id::create("fifo_ctn");
    seq_sys.fifo = dma_handshake_mode_fifo#(
                                .AddrWidth(SYS_ADDR_WIDTH))::type_id::create("fifo_sys");
    seq_host.mem = mem_model#(.AddrWidth(HOST_ADDR_WIDTH),
                                .DataWidth(HOST_DATA_WIDTH))::type_id::create("mem_host");
    seq_ctn.mem = mem_model#(.AddrWidth(CTN_ADDR_WIDTH),
                                .DataWidth(CTN_DATA_WIDTH))::type_id::create("mem_ctn");
    seq_sys.mem = mem_model#(.AddrWidth(SYS_ADDR_WIDTH),
                               .DataWidth(SYS_DATA_WIDTH))::type_id::create("mem_sys");

    // System bus is currently unavailable and untestable withing this DV environment,
    // so activate additional constraints to prevent it causing test failures.
    void'($value$plusargs("dma_dv_waive_system_bus=%0b", dma_config.dma_dv_waive_system_bus));
    `uvm_info(`gfn,
              $sformatf("dma_dv_waive_system_bus = %d", dma_config.dma_dv_waive_system_bus),
              UVM_LOW)
  endfunction : new

  function void init_model();
    // Assign mem_model instance handle to config object
    cfg.mem_ctn = seq_ctn.mem;
    cfg.mem_host = seq_host.mem;
    cfg.mem_sys = seq_sys.mem;
    // Assign dma_handshake_mode_fifo instance handle to config object
    cfg.fifo_ctn = seq_ctn.fifo;
    cfg.fifo_host = seq_host.fifo;
    cfg.fifo_sys = seq_sys.fifo;
    // Initialize memory
    cfg.mem_host.init();
    cfg.mem_ctn.init();
    cfg.mem_sys.init();
    cfg.fifo_host.init();
    cfg.fifo_ctn.init();
    cfg.fifo_sys.init();
  endfunction

  // Randomization of DMA configuration and transfer properties; to be overridden in those
  // derived classes where further constraints are required.
  virtual function void randomize_item(ref dma_seq_item dma_config);
    `DV_CHECK_RANDOMIZE_FATAL(dma_config)
    `uvm_info(`gfn, $sformatf("DMA: Randomized a new transaction:%s",
                              dma_config.convert2string()), UVM_HIGH)
  endfunction

  // Set up randomized source data for the transfer
  function void randomize_src_data(bit [31:0] total_transfer_size);
    bit [31:0] offset;
    cfg.src_data = new[total_transfer_size];
    for (offset = 32'b0; offset < total_transfer_size; offset++) begin
      cfg.src_data[offset] = $urandom_range(0, 255);
      `uvm_info(`gfn, $sformatf("%0x: %0x", offset, cfg.src_data[offset]), UVM_DEBUG)
    end
  endfunction

  // Function to populate source memory model with pre-randomized, known source data for the current
  // chunk of the transfer
  function void populate_src_mem(asid_encoding_e asid, bit [63:0] start_addr,
                                 ref bit [7:0] src_data[],
                                 input bit [31:0] offset, input bit [31:0] size);
    // TODO: we should perhaps not be assuming a 32-bit data bus here.
    bit [63:0] end_addr = (start_addr + size + 3) & ~3;
    bit [63:0] addr = {start_addr[63:2], 2'd0};
    `uvm_info(`gfn, $sformatf("Populating ASID 0x%x address range [0x%0x,0x%0x)",
                              asid, addr, end_addr), UVM_MEDIUM)

    // Alas we must ensure that the first bus word is fully-defined because TL-UL host adapater
    // fetches only complete bus words and there are assertion checks on the TL-UL bus.
    while (addr < end_addr) begin
      // Ideally we would use 'X' instead of a defined pattern.
      bit [7:0] data = 32'hBAAD_F00D >> {addr[1:0], 3'd0};
      if (addr >= start_addr && addr - start_addr < size) begin
        // Valid source data
        data = src_data[offset];
        offset++;
      end
      case (asid)
        OtInternalAddr: begin
          cfg.mem_host.write_byte(addr, data);
        end
        SocControlAddr: begin
          cfg.mem_ctn.write_byte(addr, data);
        end
        SocSystemAddr: begin
          cfg.mem_sys.write_byte(addr, data);
        end
        default: begin
          `uvm_error(`gfn, $sformatf("Unsupported Address space ID %d", asid))
        end
      endcase
      addr++;
    end
  endfunction

  // Function to populate FIFO with pre-randomized, known source data
  function void populate_src_fifo(asid_encoding_e asid, ref bit [7:0] src_data[],
                                  input bit [31:0] offset, input bit [31:0] size);
    case (asid)
      OtInternalAddr: begin
        cfg.fifo_host.populate_fifo(src_data, offset, size);
      end
      SocControlAddr: begin
        cfg.fifo_ctn.populate_fifo(src_data, offset, size);
      end
      SocSystemAddr: begin
        cfg.fifo_sys.populate_fifo(src_data, offset, size);
      end
      default: begin
        `uvm_error(`gfn, $sformatf("Unsupported Address space ID %d", asid))
      end
    endcase
  endfunction

  function void supply_data(ref dma_seq_item dma_config, bit [31:0] offset, bit [31:0] size);
    `uvm_info(`gfn, $sformatf("Supplying bytes [0x%0x,0x%0x) of 0x%0x-byte transfer",
                    offset, offset + size, dma_config.total_transfer_size), UVM_MEDIUM)

    // Configure Source model
    if (dma_config.get_read_fifo_en()) begin
      // Supply a block of data for this transfer
      populate_src_fifo(dma_config.src_asid, cfg.src_data, offset, size);
    end else begin
      // The source address depends upon the configuration; chunks may overlap each other for
      // hardware-handshaking mode.
      bit [31:0] src_addr = dma_config.src_addr;
      if (!dma_config.handshake ||
          (dma_config.direction == DmaSendData && dma_config.auto_inc_buffer)) begin
        src_addr += offset;
      end else begin
        src_addr += offset % dma_config.chunk_data_size;
      end

      // Randomise mem_model data
      populate_src_mem(dma_config.src_asid, src_addr, cfg.src_data, offset, size);
    end
  endfunction

  // Function to set dma_handshake_mode_fifo mode settings
  function void set_model_fifo_mode(asid_encoding_e asid,
                                    bit [63:0] start_addr = '0,
                                    dma_transfer_width_e per_transfer_width,
                                    bit [31:0] max_size);
    start_addr[1:0] = 2'd0; // Address generated by DMA is 4B aligned
    case (asid)
      OtInternalAddr: begin
        cfg.fifo_host.enable_fifo(.fifo_base (start_addr),
                                  .max_size (max_size));
      end
      SocControlAddr: begin
        cfg.fifo_ctn.enable_fifo(.fifo_base (start_addr),
                                 .max_size (max_size));
      end
      SocSystemAddr: begin
        cfg.fifo_sys.enable_fifo(.fifo_base (start_addr),
                                 .max_size (max_size));
      end
      default: begin
        `uvm_error(`gfn, $sformatf("Unsupported Address space ID %d", asid))
      end
    endcase
  endfunction

  // Configure the source and destination models (memory models or FIFOs) appropriately for the
  // current chunk of the DMA transfer, starting at the given byte offset.
  // Returns the byte offset of the next chunk to be transferred, if any.
  function bit [31:0] configure_mem_model(ref dma_seq_item dma_config, input bit [31:0] offset);
    // Decide how many bytes of data to supply in this chunk
    bit [31:0] chunk_size = dma_config.total_transfer_size - offset;
    if (chunk_size > dma_config.chunk_data_size) begin
      chunk_size = dma_config.chunk_data_size;
    end

    // Empty source and destination memories of data from any previous chunks transferred.
    clear_memory();
    clear_fifo();

    // Configure Source model
    if (dma_config.get_read_fifo_en()) begin
      // Enable read FIFO mode in models
      set_model_fifo_mode(dma_config.src_asid, dma_config.src_addr, dma_config.per_transfer_width,
                          chunk_size);
    end else begin
      // The source address depends upon the configuration; chunks may overlap each other for
      // hardware-handshaking mode.
      bit [31:0] src_addr = dma_config.src_addr;
      if (!dma_config.handshake ||
          (dma_config.direction == DmaSendData && dma_config.auto_inc_buffer)) begin
        src_addr += offset;
      end
    end

    // Supply the next chunk of data for this transfer
    supply_data(dma_config, offset, chunk_size);

    // Configure Destination model
    if (dma_config.get_write_fifo_en()) begin
      // TODO: Presently there is no way to intervene and check per-chunk data, so gather it all
      // into a single large FIFO and the scoreboard will check it all at the end of the transfer.
      bit [31:0] max_size = chunk_size;
      if (dma_config.handshake && dma_config.direction == DmaSendData) begin
        max_size = dma_config.total_transfer_size;
      end

      // Enable write FIFO mode in models
      set_model_fifo_mode(dma_config.dst_asid, dma_config.dst_addr, dma_config.per_transfer_width,
                          max_size);
    end

    // Return the updated byte offset within the transfer
    return offset + chunk_size;
  endfunction

  // Set hardware handshake interrupt bits based on randomized class item
  function void set_hardware_handshake_intr(
    bit [dma_reg_pkg::NumIntClearSources-1:0] handshake_value);
    cfg.dma_vif.handshake_i = handshake_value;
  endfunction

  function void release_hardware_handshake_intr();
    cfg.dma_vif.handshake_i = '0;
  endfunction

  // Task: Write to Source Address CSR
  task set_source_address(bit [63:0] source_address);
    `uvm_info(`gfn, $sformatf("DMA: Source Address = 0x%016h", source_address), UVM_HIGH)
    csr_wr(ral.source_address_lo, source_address[31:0]);
    csr_wr(ral.source_address_hi, source_address[63:32]);
  endtask : set_source_address

  // Task: Write to Destination Address CSR
  task set_destination_address(bit [63:0] destination_address);
    csr_wr(ral.destination_address_lo, destination_address[31:0]);
    csr_wr(ral.destination_address_hi, destination_address[63:32]);
    `uvm_info(`gfn, $sformatf("DMA: Destination Address = 0x%016h", destination_address), UVM_HIGH)
  endtask : set_destination_address

  task set_destination_address_range(bit[63:0] almost_limit,
                                     bit[63:0] limit);
    csr_wr(ral.destination_address_limit_lo, limit[31:0]);
    csr_wr(ral.destination_address_limit_hi, limit[63:32]);
    `uvm_info(`gfn, $sformatf("DMA: Destination Limit = 0x%016h", limit), UVM_HIGH)
    csr_wr(ral.destination_address_almost_limit_lo, almost_limit[31:0]);
    csr_wr(ral.destination_address_almost_limit_hi, almost_limit[63:32]);
    `uvm_info(`gfn, $sformatf("DMA: Destination Almost Limit = 0x%016h", almost_limit), UVM_HIGH)
  endtask : set_destination_address_range

  // Task: Set DMA Enabled Memory base and limit
  task set_dma_enabled_memory_range(bit [32:0] base, bit [31:0] limit, bit valid, mubi4_t lock);
    csr_wr(ral.enabled_memory_range_base, base);
    `uvm_info(`gfn, $sformatf("DMA: DMA Enabled Memory base = %0x08h", base), UVM_HIGH)
    csr_wr(ral.enabled_memory_range_limit, limit);
    `uvm_info(`gfn, $sformatf("DMA: DMA Enabled Memory limit = %0x08h", limit), UVM_HIGH)
    csr_wr(ral.range_valid, valid);
    `uvm_info(`gfn, $sformatf("DMA: DMA Enabled Memory Range valid = %0d", valid), UVM_HIGH)
    if (lock != MuBi4True) begin
      csr_wr(ral.range_regwen, int'(lock));
      `uvm_info(`gfn, $sformatf("DMA: DMA Enabled Memory lock = %s", lock.name()), UVM_HIGH)
    end
  endtask : set_dma_enabled_memory_range

  // Task: Write to Source and Destination Address Space ID (ASID)
  task set_address_space_id(asid_encoding_e src_asid, asid_encoding_e dst_asid);
    ral.address_space_id.source_asid.set(int'(src_asid));
    ral.address_space_id.destination_asid.set(int'(dst_asid));
    csr_update(.csr(ral.address_space_id));
    `uvm_info(`gfn, $sformatf("DMA: Source ASID = %d", src_asid), UVM_HIGH)
    `uvm_info(`gfn, $sformatf("DMA: Destination ASID = %d", dst_asid), UVM_HIGH)
  endtask : set_address_space_id

  // Task: Set number of bytes to transfer
  task set_total_size(bit [31:0] total_data_size);
    csr_wr(ral.total_data_size, total_data_size);
    `uvm_info(`gfn, $sformatf("DMA: Total Data Size = %d", total_data_size), UVM_HIGH)
  endtask : set_total_size

  // Task: Set number of bytes per chunk to transfer
  task set_chunk_data_size(bit [31:0] chunk_data_size);
    csr_wr(ral.chunk_data_size, chunk_data_size);
    `uvm_info(`gfn, $sformatf("DMA: Chunk Data Size = %d", chunk_data_size), UVM_HIGH)
  endtask : set_chunk_data_size

  // Task: Set Byte size of each transfer (0:1B, 1:2B, 2:3B, 3:4B)
  task set_transfer_width(dma_transfer_width_e transfer_width);
    csr_wr(ral.transfer_width, transfer_width);
    `uvm_info(`gfn, $sformatf("DMA: Transfer Byte Size = %d",
                              transfer_width.name()), UVM_HIGH)
  endtask : set_transfer_width

  // Task: Set handshake interrupt register
  task set_handshake_int_regs(ref dma_seq_item dma_config);
    `uvm_info(`gfn, "Set DMA Handshake mode interrupt registers", UVM_HIGH)
    csr_wr(ral.clear_int_src, dma_config.clear_int_src);
    csr_wr(ral.clear_int_bus, dma_config.clear_int_bus);
    foreach (dma_config.int_src_addr[i]) begin
      csr_wr(ral.int_source_addr[i], dma_config.int_src_addr[i]);
      csr_wr(ral.int_source_wr_val[i], dma_config.int_src_wr_val[i]);
    end
    ral.handshake_interrupt_enable.set(dma_config.handshake_intr_en);
    csr_update(ral.handshake_interrupt_enable);
  endtask : set_handshake_int_regs

  // Task: Configure DMA controller to perform a transfer
  // (common to both 'memory-to-memory' and 'hardware handshaking' modes of operation)
  task run_common_config(ref dma_seq_item dma_config);
    `uvm_info(`gfn, "DMA: Start Common Configuration", UVM_HIGH)
    set_source_address(dma_config.src_addr);
    set_destination_address(dma_config.dst_addr);
    set_destination_address_range(dma_config.mem_buffer_almost_limit,
                                  dma_config.mem_buffer_limit);
    set_address_space_id(dma_config.src_asid, dma_config.dst_asid);
    set_total_size(dma_config.total_transfer_size);
    set_chunk_data_size(dma_config.chunk_data_size);
    set_transfer_width(dma_config.per_transfer_width);
    randomize_src_data(dma_config.total_transfer_size);
    void'(configure_mem_model(dma_config, 32'd0));
    set_handshake_int_regs(dma_config);
    set_dma_enabled_memory_range(dma_config.mem_range_base,
                                 dma_config.mem_range_limit,
                                 dma_config.mem_range_valid,
                                 dma_config.mem_range_lock);
  endtask : run_common_config

  // Task: Enable Interrupt
  task enable_interrupt();
    `uvm_info(`gfn, "DMA: Assert Interrupt Enable", UVM_HIGH)
    csr_wr(ral.intr_enable, (1 << ral.intr_enable.get_n_bits()) - 1);
  endtask : enable_interrupt

  // Task: Enable Handshake Interrupt Enable
  task enable_handshake_interrupt();
    `uvm_info(`gfn, "DMA: Assert Interrupt Enable", UVM_HIGH)
    csr_wr(ral.handshake_interrupt_enable, 32'd1);
  endtask : enable_handshake_interrupt

  function void set_seq_fifo_read_mode(asid_encoding_e asid, bit read_fifo_en);
    case (asid)
      OtInternalAddr: begin
        seq_host.read_fifo_en = read_fifo_en;
        `uvm_info(`gfn, $sformatf("set host read_fifo_en = %0b", read_fifo_en), UVM_HIGH)
      end
      SocControlAddr: begin
        seq_ctn.read_fifo_en = read_fifo_en;
        `uvm_info(`gfn, $sformatf("set ctn read_fifo_en = %0b", read_fifo_en), UVM_HIGH)
      end
      SocSystemAddr: begin
        seq_sys.read_fifo_en = read_fifo_en;
        `uvm_info(`gfn, $sformatf("set sys read_fifo_en = %0b", read_fifo_en), UVM_HIGH)
      end
      default: begin
        `uvm_error(`gfn, $sformatf("Unsupported Address space ID %d", asid))
      end
    endcase
  endfunction

  function void set_seq_fifo_write_mode(asid_encoding_e asid, bit write_fifo_en);
    case (asid)
      OtInternalAddr: begin
        seq_host.write_fifo_en = write_fifo_en;
        `uvm_info(`gfn, $sformatf("set host write_fifo_en = %0b", write_fifo_en), UVM_HIGH)
      end
      SocControlAddr: begin
        seq_ctn.write_fifo_en = write_fifo_en;
        `uvm_info(`gfn, $sformatf("set ctn write_fifo_en = %0b", write_fifo_en), UVM_HIGH)
      end
      SocSystemAddr: begin
        seq_sys.write_fifo_en = write_fifo_en;
        `uvm_info(`gfn, $sformatf("set sys write_fifo_en = %0b", write_fifo_en), UVM_HIGH)
      end
      default: begin
        `uvm_error(`gfn, $sformatf("Unsupported Address space ID %d", asid))
      end
    endcase
  endfunction

  // Task: Start TLUL Sequences
  virtual task start_device(ref dma_seq_item dma_config);
    if (dma_config.handshake) begin
      // Assign memory models used in tl_device_vseq instances
      bit [31:0] fifo_interrupt_mask;
      bit fifo_intr_clear_en;
      bit [31:0] fifo_intr_clear_reg_addr;
      bit [31:0] fifo_intr_clear_val;
      // Variable to check if any of the handshake interrupts are asserted
      fifo_interrupt_mask = dma_config.handshake_intr_en & cfg.dma_vif.handshake_i;
      `uvm_info(`gfn, $sformatf("FIFO interrupt enable mask = %0x ", fifo_interrupt_mask),
                UVM_HIGH)
      fifo_intr_clear_en = fifo_interrupt_mask > 0;
      // Set fifo enable bit
      set_seq_fifo_read_mode(dma_config.src_asid, dma_config.get_read_fifo_en());
      set_seq_fifo_write_mode(dma_config.dst_asid, dma_config.get_write_fifo_en());
      // Get FIFO register clear enable
      if (fifo_intr_clear_en) begin
        // Get FIFO interrupt register address and value
        // Find the interrupt index with both handshake interrupt enable and clear_int_src
        for (int i = 0; i < dma_reg_pkg::NumIntClearSources; i++) begin
          // Check if at least one handshake interrupt is asserted and
          // clear_int_src is set
          if (dma_config.clear_int_src[i]) begin
            `uvm_info(`gfn, $sformatf("Detected FIFO reg clear enable at index : %0d", i),
                      UVM_HIGH)
            // Set FIFO interrupt clear address and values in corresponding pull sequence instance
            case (dma_config.clear_int_bus)
              0: seq_ctn.add_fifo_reg({dma_config.int_src_addr[i][31:2], 2'd0},
                                       dma_config.int_src_wr_val[i]);
              1: seq_host.add_fifo_reg({dma_config.int_src_addr[i][31:2], 2'd0},
                                        dma_config.int_src_wr_val[i]);
              default: begin end
            endcase
            break;
          end
        end
        // Set FIFO interrupt clear in corresponding pull sequence instance
        case (dma_config.clear_int_bus)
          0: seq_ctn.set_fifo_clear(fifo_intr_clear_en);
          1: seq_host.set_fifo_clear(fifo_intr_clear_en);
          default: begin end
        endcase
      end
    end

    `uvm_info(`gfn, "DMA: Starting Devices", UVM_HIGH)
    fork
      seq_ctn.start(p_sequencer.tl_sequencer_dma_ctn_h);
      seq_host.start(p_sequencer.tl_sequencer_dma_host_h);
      seq_sys.start(p_sequencer.tl_sequencer_dma_sys_h);
    join_none
  endtask : start_device

  // Method to terminate sequences gracefully
  virtual task stop_device();
    `uvm_info(`gfn, "DMA: Stopping Devices", UVM_HIGH)
    fork
      seq_ctn.seq_stop();
      seq_host.seq_stop();
      seq_sys.seq_stop();
    join
    // Clear FIFO mode enable bit
    set_seq_fifo_read_mode(OtInternalAddr, 0);
    set_seq_fifo_read_mode(SocControlAddr, 0);
    set_seq_fifo_read_mode(SocSystemAddr, 0);
    set_seq_fifo_write_mode(OtInternalAddr, 0);
    set_seq_fifo_write_mode(SocControlAddr, 0);
    set_seq_fifo_write_mode(SocSystemAddr, 0);
    // Clear FIFO write clear enable bit
    seq_ctn.set_fifo_clear(0);
    seq_host.set_fifo_clear(0);
    seq_sys.set_fifo_clear(0);
    // Disable FIFO
    cfg.fifo_host.disable_fifo();
    cfg.fifo_ctn.disable_fifo();
    cfg.fifo_sys.disable_fifo();
  endtask

  // Method to clear memory models of any content
  function void clear_memory();
    // Clear memory contents
    `uvm_info(`gfn, $sformatf("Clearing memory contents"), UVM_MEDIUM)
    cfg.mem_host.init();
    cfg.mem_ctn.init();
    cfg.mem_sys.init();
  endfunction

  // Method to clear FIFO models of any content
  function void clear_fifo();
    // Clear FIFO contents
    `uvm_info(`gfn, $sformatf("Clearing FIFO contents"), UVM_MEDIUM)
    cfg.fifo_host.init();
    cfg.fifo_ctn.init();
    cfg.fifo_sys.init();
  endfunction

  // Task: Configures (optionally executes) DMA control registers
  task set_control_register(opcode_e op = OpcCopy, // OPCODE
                            bit first, // Initial transfer
                            bit hs, // Handshake Enable
                            bit buff, // Auto-increment Buffer Address
                            bit fifo, // Auto-increment FIFO Address
                            bit dir, // Direction
                            bit go); // Execute
    string tmpstr;
    tmpstr = go ? "Executing" : "Setting";
    `uvm_info(`gfn, $sformatf(
                      "DMA: %s DMA Control Register OPCODE=%d FIRST=%d HS=%d BUF=%d FIFO=%d DIR=%d",
                      tmpstr, op, first, hs, buff, fifo, dir), UVM_HIGH)
    // Configure all fields except GO bit which shall initially be clear
    ral.control.opcode.set(int'(op));
    ral.control.initial_transfer.set(first);
    ral.control.hardware_handshake_enable.set(hs);
    ral.control.memory_buffer_auto_increment_enable.set(buff);
    ral.control.fifo_auto_increment_enable.set(fifo);
    ral.control.data_direction.set(dir);
    ral.control.go.set(1'b0);
    csr_update(.csr(ral.control));
    // Set GO bit
    ral.control.go.set(go);
    csr_update(.csr(ral.control));
  endtask : set_control_register

  // Task: Abort the current transaction
  task abort();
    ral.control.abort.set(1);
    csr_update(.csr(ral.control));
  endtask : abort

  // Task: Clear DMA Status
  task clear();
    `uvm_info(`gfn, "DMA: Clear DMA State", UVM_HIGH)
    csr_wr(ral.clear_state, 32'd1);
  endtask : clear

  // Task: Wait for Completion
  task wait_for_completion(output int status);
    int timeout = 1000000;
    fork
      begin
        // Case 1: Timeout condition due to simulation hang
        delay(timeout);
        status = -1;
        `uvm_fatal(`gfn, $sformatf("ERROR: Timeout Condition Reached at %d cycles", timeout))
      end
      poll_status();
      // Case 2: Test completion via 'status.done' bit
      begin
        wait(e_complete.triggered);
        status = 0;
        `uvm_info(`gfn, "DMA: Completion Seen", UVM_MEDIUM)
      end
      // Case 3: Response to 'control.abort' request, leading to 'status.abort' being asserted
      begin
        wait(e_aborted.triggered);
        status = 1;
        `uvm_info(`gfn, "DMA: Aborted Seen", UVM_MEDIUM)
      end
      // Case 4: Error raised, leading to 'status.error' set
      begin
        wait(e_errored.triggered);
        status = 2;
        `uvm_info(`gfn, "DMA: Error Seen", UVM_MEDIUM)
      end
    join_any
    disable fork;
  endtask : wait_for_completion

  // Task: Continuously poll status until completion every N cycles
  task poll_status(int pollrate = 10);
    bit [31:0] v;

    `uvm_info(`gfn, "DMA: Polling DMA Status", UVM_HIGH)
    while (1) begin
      csr_rd(ral.status, v);
      if (v[0]) begin ->e_busy;     end
      if (v[1]) begin ->e_complete; end
      if (v[2]) begin ->e_aborted;  end
      if (v[3]) begin ->e_errored;  end
      // Note: sha2_digest_valid is not a completion event
      // v[12]
      delay(pollrate);
    end
  endtask : poll_status

  // Monitors busy bit in STATUS register
  task wait_for_idle();
    forever begin
      uvm_reg_data_t data;
      csr_rd(ral.status, data);
      if (!get_field_val(ral.status.busy, data)) begin
        `uvm_info(`gfn, "DMA in Idle state", UVM_MEDIUM)
        break;
      end
    end
  endtask

  // Task: Simulate a clock delay
  virtual task delay(int num = 1);
    cfg.clk_rst_vif.wait_clks(num);
  endtask : delay

  // Task to wait for the transfer of a specified number of bytes.
  //
  // The `stop` signal may be set by a parallel task that monitors the completion of chunks,
  // to ensure the tidy exit of this task. (In a multi-chunk transfer the generation of
  // LSIO triggers is decoupled from the transfers.)
  task wait_num_bytes_transfer(uint num_bytes, ref bit stop);
    while (!stop) begin
      if (get_bytes_written(dma_config) >= num_bytes) begin
        `uvm_info(`gfn, $sformatf("Got %d", num_bytes), UVM_DEBUG)
        break;
      end else begin
        delay(1);
      end
    end
  endtask

  // Task to read out the SHA digest
  task read_sha2_digest(input opcode_e op, output logic [511:0] digest);
    int sha_digest_size; // in 32-bit words
    string sha_mode;
    digest = '0;
    `uvm_info(`gfn, "DMA: Read SHA2 digest", UVM_MEDIUM)
    case (op)
      OpcSha256: begin
        sha_digest_size = 8;
        sha_mode = "SHA2-256";
      end
      OpcSha384: begin
        sha_digest_size = 12;
        sha_mode = "SHA2-384";
      end
      OpcSha512: begin
        sha_digest_size = 16;
        sha_mode = "SHA2-512";
      end
      default: begin
        `uvm_error(`gfn, $sformatf("Unsupported SHA2 opcode %d", op))
      end
    endcase

    for(int i = 0; i < sha_digest_size; ++i) begin
      csr_rd(ral.sha2_digest[i],  digest[i*32 +: 32]);
    end
    `uvm_info(`gfn, $sformatf("DMA: %s digest: %x", sha_mode, digest), UVM_MEDIUM)
  endtask

  // Return number of bytes written to interface corresponding to destination ASID
  virtual function uint get_bytes_written(ref dma_seq_item dma_config);
    case (dma_config.dst_asid)
      OtInternalAddr: begin
        `uvm_info(`gfn,
                  $sformatf("OTInternal bytes_written = %0d", seq_host.bytes_written), UVM_HIGH)
        return seq_host.bytes_written;
      end
      SocControlAddr: begin
        `uvm_info(`gfn,
                  $sformatf("SocControlAddr bytes_written = %0d", seq_ctn.bytes_written), UVM_HIGH)
        return seq_ctn.bytes_written;
      end
      SocSystemAddr: begin
        `uvm_info(`gfn,
                  $sformatf("SocSystemAddr bytes_written = %0d", seq_sys.bytes_written), UVM_HIGH)
        return seq_sys.bytes_written;
      end
      default: begin
        `uvm_error(`gfn, $sformatf("Unsupported Address space ID %d", dma_config.dst_asid))
      end
    endcase
  endfunction

  // Body: Need to override for inherited tests
  task body();
    init_model();
    enable_interrupt();
  endtask : body
endclass
