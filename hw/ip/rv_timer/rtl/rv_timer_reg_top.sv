// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module rv_timer_reg_top (
  input clk_i,
  input rst_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  // To HW
  output rv_timer_reg_pkg::rv_timer_reg2hw_t reg2hw, // Write
  input  rv_timer_reg_pkg::rv_timer_hw2reg_t hw2reg, // Read

  // Integrity check errors
  output logic intg_err_o,

  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import rv_timer_reg_pkg::* ;

  localparam int AW = 9;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;
  logic reg_busy;

  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;


  // incoming payload check
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i(tl_i),
    .err_o(intg_err)
  );

  logic intg_err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      intg_err_q <= '0;
    end else if (intg_err) begin
      intg_err_q <= 1'b1;
    end
  end

  // integrity error output is permanent and should be used for alert generation
  // register errors are transactional
  assign intg_err_o = intg_err_q | intg_err;

  // outgoing integrity generation
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );

  assign tl_reg_h2d = tl_i;
  assign tl_o_pre   = tl_reg_d2h;

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(0)
  ) u_reg_if (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),

    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .busy_i  (reg_busy),
    .rdata_i (reg_rdata),
    .error_i (reg_error)
  );

  // cdc oversampling signals

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic alert_test_we;
  logic alert_test_wd;
  logic ctrl_we;
  logic ctrl_qs;
  logic ctrl_wd;
  logic cfg0_we;
  logic [11:0] cfg0_prescale_qs;
  logic [11:0] cfg0_prescale_wd;
  logic [7:0] cfg0_step_qs;
  logic [7:0] cfg0_step_wd;
  logic timer_v_lower0_we;
  logic [31:0] timer_v_lower0_qs;
  logic [31:0] timer_v_lower0_wd;
  logic timer_v_upper0_we;
  logic [31:0] timer_v_upper0_qs;
  logic [31:0] timer_v_upper0_wd;
  logic compare_lower0_0_we;
  logic [31:0] compare_lower0_0_qs;
  logic [31:0] compare_lower0_0_wd;
  logic compare_upper0_0_we;
  logic [31:0] compare_upper0_0_qs;
  logic [31:0] compare_upper0_0_wd;
  logic intr_enable0_we;
  logic intr_enable0_qs;
  logic intr_enable0_wd;
  logic intr_state0_we;
  logic intr_state0_qs;
  logic intr_state0_wd;
  logic intr_test0_we;
  logic intr_test0_wd;

  // Register instances
  // R[alert_test]: V(True)

  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.alert_test.qe),
    .q      (reg2hw.alert_test.q),
    .qs     ()
  );



  // Subregister 0 of Multireg ctrl
  // R[ctrl]: V(False)

  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0)
  ) u_ctrl (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_we),
    .wd     (ctrl_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.ctrl[0].q),

    // to register interface (read)
    .qs     (ctrl_qs)
  );


  // R[cfg0]: V(False)

  //   F[prescale]: 11:0
  prim_subreg #(
    .DW      (12),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (12'h0)
  ) u_cfg0_prescale (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (cfg0_we),
    .wd     (cfg0_prescale_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.cfg0.prescale.q),

    // to register interface (read)
    .qs     (cfg0_prescale_qs)
  );


  //   F[step]: 23:16
  prim_subreg #(
    .DW      (8),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (8'h1)
  ) u_cfg0_step (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (cfg0_we),
    .wd     (cfg0_step_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.cfg0.step.q),

    // to register interface (read)
    .qs     (cfg0_step_qs)
  );


  // R[timer_v_lower0]: V(False)

  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_timer_v_lower0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (timer_v_lower0_we),
    .wd     (timer_v_lower0_wd),

    // from internal hardware
    .de     (hw2reg.timer_v_lower0.de),
    .d      (hw2reg.timer_v_lower0.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.timer_v_lower0.q),

    // to register interface (read)
    .qs     (timer_v_lower0_qs)
  );


  // R[timer_v_upper0]: V(False)

  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_timer_v_upper0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (timer_v_upper0_we),
    .wd     (timer_v_upper0_wd),

    // from internal hardware
    .de     (hw2reg.timer_v_upper0.de),
    .d      (hw2reg.timer_v_upper0.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.timer_v_upper0.q),

    // to register interface (read)
    .qs     (timer_v_upper0_qs)
  );


  // R[compare_lower0_0]: V(False)

  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'hffffffff)
  ) u_compare_lower0_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (compare_lower0_0_we),
    .wd     (compare_lower0_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (reg2hw.compare_lower0_0.qe),
    .q      (reg2hw.compare_lower0_0.q),

    // to register interface (read)
    .qs     (compare_lower0_0_qs)
  );


  // R[compare_upper0_0]: V(False)

  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'hffffffff)
  ) u_compare_upper0_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (compare_upper0_0_we),
    .wd     (compare_upper0_0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (reg2hw.compare_upper0_0.qe),
    .q      (reg2hw.compare_upper0_0.q),

    // to register interface (read)
    .qs     (compare_upper0_0_qs)
  );



  // Subregister 0 of Multireg intr_enable0
  // R[intr_enable0]: V(False)

  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0)
  ) u_intr_enable0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_enable0_we),
    .wd     (intr_enable0_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_enable0[0].q),

    // to register interface (read)
    .qs     (intr_enable0_qs)
  );



  // Subregister 0 of Multireg intr_state0
  // R[intr_state0]: V(False)

  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0)
  ) u_intr_state0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state0_we),
    .wd     (intr_state0_wd),

    // from internal hardware
    .de     (hw2reg.intr_state0[0].de),
    .d      (hw2reg.intr_state0[0].d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state0[0].q),

    // to register interface (read)
    .qs     (intr_state0_qs)
  );



  // Subregister 0 of Multireg intr_test0
  // R[intr_test0]: V(True)

  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test0 (
    .re     (1'b0),
    .we     (intr_test0_we),
    .wd     (intr_test0_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.intr_test0[0].qe),
    .q      (reg2hw.intr_test0[0].q),
    .qs     ()
  );




  logic [9:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == RV_TIMER_ALERT_TEST_OFFSET);
    addr_hit[1] = (reg_addr == RV_TIMER_CTRL_OFFSET);
    addr_hit[2] = (reg_addr == RV_TIMER_CFG0_OFFSET);
    addr_hit[3] = (reg_addr == RV_TIMER_TIMER_V_LOWER0_OFFSET);
    addr_hit[4] = (reg_addr == RV_TIMER_TIMER_V_UPPER0_OFFSET);
    addr_hit[5] = (reg_addr == RV_TIMER_COMPARE_LOWER0_0_OFFSET);
    addr_hit[6] = (reg_addr == RV_TIMER_COMPARE_UPPER0_0_OFFSET);
    addr_hit[7] = (reg_addr == RV_TIMER_INTR_ENABLE0_OFFSET);
    addr_hit[8] = (reg_addr == RV_TIMER_INTR_STATE0_OFFSET);
    addr_hit[9] = (reg_addr == RV_TIMER_INTR_TEST0_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(RV_TIMER_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(RV_TIMER_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(RV_TIMER_PERMIT[2] & ~reg_be))) |
               (addr_hit[3] & (|(RV_TIMER_PERMIT[3] & ~reg_be))) |
               (addr_hit[4] & (|(RV_TIMER_PERMIT[4] & ~reg_be))) |
               (addr_hit[5] & (|(RV_TIMER_PERMIT[5] & ~reg_be))) |
               (addr_hit[6] & (|(RV_TIMER_PERMIT[6] & ~reg_be))) |
               (addr_hit[7] & (|(RV_TIMER_PERMIT[7] & ~reg_be))) |
               (addr_hit[8] & (|(RV_TIMER_PERMIT[8] & ~reg_be))) |
               (addr_hit[9] & (|(RV_TIMER_PERMIT[9] & ~reg_be)))));
  end
  assign alert_test_we = addr_hit[0] & reg_we & !reg_error;

  assign alert_test_wd = reg_wdata[0];
  assign ctrl_we = addr_hit[1] & reg_we & !reg_error;

  assign ctrl_wd = reg_wdata[0];
  assign cfg0_we = addr_hit[2] & reg_we & !reg_error;

  assign cfg0_prescale_wd = reg_wdata[11:0];

  assign cfg0_step_wd = reg_wdata[23:16];
  assign timer_v_lower0_we = addr_hit[3] & reg_we & !reg_error;

  assign timer_v_lower0_wd = reg_wdata[31:0];
  assign timer_v_upper0_we = addr_hit[4] & reg_we & !reg_error;

  assign timer_v_upper0_wd = reg_wdata[31:0];
  assign compare_lower0_0_we = addr_hit[5] & reg_we & !reg_error;

  assign compare_lower0_0_wd = reg_wdata[31:0];
  assign compare_upper0_0_we = addr_hit[6] & reg_we & !reg_error;

  assign compare_upper0_0_wd = reg_wdata[31:0];
  assign intr_enable0_we = addr_hit[7] & reg_we & !reg_error;

  assign intr_enable0_wd = reg_wdata[0];
  assign intr_state0_we = addr_hit[8] & reg_we & !reg_error;

  assign intr_state0_wd = reg_wdata[0];
  assign intr_test0_we = addr_hit[9] & reg_we & !reg_error;

  assign intr_test0_wd = reg_wdata[0];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = '0;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = ctrl_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[11:0] = cfg0_prescale_qs;
        reg_rdata_next[23:16] = cfg0_step_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = timer_v_lower0_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = timer_v_upper0_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[31:0] = compare_lower0_0_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = compare_upper0_0_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[0] = intr_enable0_qs;
      end

      addr_hit[8]: begin
        reg_rdata_next[0] = intr_state0_qs;
      end

      addr_hit[9]: begin
        reg_rdata_next[0] = '0;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // register busy
  always_comb begin
    reg_busy = '0;
    unique case (1'b1)
      default: begin
        reg_busy  = '0;
      end
    endcase
  end


  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)

  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)

  // this is formulated as an assumption such that the FPV testbenches do disprove this
  // property by mistake
  //`ASSUME(reqParity, tl_reg_h2d.a_valid |-> tl_reg_h2d.a_user.chk_en == tlul_pkg::CheckDis)

endmodule
