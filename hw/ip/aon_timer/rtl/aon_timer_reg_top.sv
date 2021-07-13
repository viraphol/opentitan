// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module aon_timer_reg_top (
  input clk_i,
  input rst_ni,
  input clk_aon_i,
  input rst_aon_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  // To HW
  output aon_timer_reg_pkg::aon_timer_reg2hw_t reg2hw, // Write
  input  aon_timer_reg_pkg::aon_timer_hw2reg_t hw2reg, // Read

  // Integrity check errors
  output logic intg_err_o,

  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import aon_timer_reg_pkg::* ;

  localparam int AW = 6;
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
    logic sync_aon_update;
  prim_pulse_sync u_aon_tgl (
    .clk_src_i(clk_aon_i),
    .rst_src_ni(rst_aon_ni),
    .src_pulse_i(1'b1),
    .clk_dst_i(clk_i),
    .rst_dst_ni(rst_ni),
    .dst_pulse_o(sync_aon_update)
  );

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic alert_test_we;
  logic alert_test_wd;
  logic wkup_ctrl_we;
  logic wkup_ctrl_enable_qs;
  logic wkup_ctrl_enable_wd;
  logic wkup_ctrl_enable_busy;
  logic [11:0] wkup_ctrl_prescaler_qs;
  logic [11:0] wkup_ctrl_prescaler_wd;
  logic wkup_ctrl_prescaler_busy;
  logic wkup_thold_we;
  logic [31:0] wkup_thold_qs;
  logic [31:0] wkup_thold_wd;
  logic wkup_thold_busy;
  logic wkup_count_we;
  logic [31:0] wkup_count_qs;
  logic [31:0] wkup_count_wd;
  logic wkup_count_busy;
  logic wdog_regwen_we;
  logic wdog_regwen_qs;
  logic wdog_regwen_wd;
  logic wdog_ctrl_we;
  logic wdog_ctrl_enable_qs;
  logic wdog_ctrl_enable_wd;
  logic wdog_ctrl_enable_busy;
  logic wdog_ctrl_pause_in_sleep_qs;
  logic wdog_ctrl_pause_in_sleep_wd;
  logic wdog_ctrl_pause_in_sleep_busy;
  logic wdog_bark_thold_we;
  logic [31:0] wdog_bark_thold_qs;
  logic [31:0] wdog_bark_thold_wd;
  logic wdog_bark_thold_busy;
  logic wdog_bite_thold_we;
  logic [31:0] wdog_bite_thold_qs;
  logic [31:0] wdog_bite_thold_wd;
  logic wdog_bite_thold_busy;
  logic wdog_count_we;
  logic [31:0] wdog_count_qs;
  logic [31:0] wdog_count_wd;
  logic wdog_count_busy;
  logic intr_state_we;
  logic intr_state_wkup_timer_expired_qs;
  logic intr_state_wkup_timer_expired_wd;
  logic intr_state_wdog_timer_expired_qs;
  logic intr_state_wdog_timer_expired_wd;
  logic intr_test_we;
  logic intr_test_wkup_timer_expired_wd;
  logic intr_test_wdog_timer_expired_wd;
  logic wkup_cause_we;
  logic wkup_cause_qs;
  logic wkup_cause_wd;
  logic wkup_cause_busy;

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


  // R[wkup_ctrl]: V(False)

  //   F[enable]: 0:0
  prim_subreg_async #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0)
  ) u_wkup_ctrl_enable (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wkup_ctrl_we),
    .src_wd_i     (wkup_ctrl_enable_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wkup_ctrl_enable_busy),
    .src_qs_o     (wkup_ctrl_enable_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wkup_ctrl.enable.q)
  );


  //   F[prescaler]: 12:1
  prim_subreg_async #(
    .DW      (12),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (12'h0)
  ) u_wkup_ctrl_prescaler (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wkup_ctrl_we),
    .src_wd_i     (wkup_ctrl_prescaler_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wkup_ctrl_prescaler_busy),
    .src_qs_o     (wkup_ctrl_prescaler_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wkup_ctrl.prescaler.q)
  );


  // R[wkup_thold]: V(False)

  prim_subreg_async #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_wkup_thold (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wkup_thold_we),
    .src_wd_i     (wkup_thold_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wkup_thold_busy),
    .src_qs_o     (wkup_thold_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wkup_thold.q)
  );


  // R[wkup_count]: V(False)

  prim_subreg_async #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_wkup_count (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wkup_count_we),
    .src_wd_i     (wkup_count_wd),
    .dst_de_i     (hw2reg.wkup_count.de),
    .dst_d_i      (hw2reg.wkup_count.d),
    .src_busy_o   (wkup_count_busy),
    .src_qs_o     (wkup_count_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wkup_count.q)
  );


  // R[wdog_regwen]: V(False)

  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1)
  ) u_wdog_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (wdog_regwen_we),
    .wd     (wdog_regwen_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (wdog_regwen_qs)
  );


  // R[wdog_ctrl]: V(False)

  //   F[enable]: 0:0
  prim_subreg_async #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0)
  ) u_wdog_ctrl_enable (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wdog_ctrl_we & wdog_regwen_qs),
    .src_wd_i     (wdog_ctrl_enable_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wdog_ctrl_enable_busy),
    .src_qs_o     (wdog_ctrl_enable_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wdog_ctrl.enable.q)
  );


  //   F[pause_in_sleep]: 1:1
  prim_subreg_async #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0)
  ) u_wdog_ctrl_pause_in_sleep (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wdog_ctrl_we & wdog_regwen_qs),
    .src_wd_i     (wdog_ctrl_pause_in_sleep_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wdog_ctrl_pause_in_sleep_busy),
    .src_qs_o     (wdog_ctrl_pause_in_sleep_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wdog_ctrl.pause_in_sleep.q)
  );


  // R[wdog_bark_thold]: V(False)

  prim_subreg_async #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_wdog_bark_thold (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wdog_bark_thold_we & wdog_regwen_qs),
    .src_wd_i     (wdog_bark_thold_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wdog_bark_thold_busy),
    .src_qs_o     (wdog_bark_thold_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wdog_bark_thold.q)
  );


  // R[wdog_bite_thold]: V(False)

  prim_subreg_async #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_wdog_bite_thold (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wdog_bite_thold_we & wdog_regwen_qs),
    .src_wd_i     (wdog_bite_thold_wd),
    .dst_de_i     (1'b0),
    .dst_d_i      ('0),
    .src_busy_o   (wdog_bite_thold_busy),
    .src_qs_o     (wdog_bite_thold_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wdog_bite_thold.q)
  );


  // R[wdog_count]: V(False)

  prim_subreg_async #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0)
  ) u_wdog_count (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wdog_count_we),
    .src_wd_i     (wdog_count_wd),
    .dst_de_i     (hw2reg.wdog_count.de),
    .dst_d_i      (hw2reg.wdog_count.d),
    .src_busy_o   (wdog_count_busy),
    .src_qs_o     (wdog_count_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wdog_count.q)
  );


  // R[intr_state]: V(False)

  //   F[wkup_timer_expired]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0)
  ) u_intr_state_wkup_timer_expired (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state_we),
    .wd     (intr_state_wkup_timer_expired_wd),

    // from internal hardware
    .de     (hw2reg.intr_state.wkup_timer_expired.de),
    .d      (hw2reg.intr_state.wkup_timer_expired.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state.wkup_timer_expired.q),

    // to register interface (read)
    .qs     (intr_state_wkup_timer_expired_qs)
  );


  //   F[wdog_timer_expired]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0)
  ) u_intr_state_wdog_timer_expired (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state_we),
    .wd     (intr_state_wdog_timer_expired_wd),

    // from internal hardware
    .de     (hw2reg.intr_state.wdog_timer_expired.de),
    .d      (hw2reg.intr_state.wdog_timer_expired.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state.wdog_timer_expired.q),

    // to register interface (read)
    .qs     (intr_state_wdog_timer_expired_qs)
  );


  // R[intr_test]: V(True)

  //   F[wkup_timer_expired]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_wkup_timer_expired (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_wkup_timer_expired_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.intr_test.wkup_timer_expired.qe),
    .q      (reg2hw.intr_test.wkup_timer_expired.q),
    .qs     ()
  );


  //   F[wdog_timer_expired]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_wdog_timer_expired (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_wdog_timer_expired_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.intr_test.wdog_timer_expired.qe),
    .q      (reg2hw.intr_test.wdog_timer_expired.q),
    .qs     ()
  );


  // R[wkup_cause]: V(False)

  prim_subreg_async #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h0)
  ) u_wkup_cause (
    .clk_src_i    (clk_i),
    .rst_src_ni   (rst_ni),
    .clk_dst_i    (clk_aon_i),
    .rst_dst_ni   (rst_aon_ni),
    .src_update_i (sync_aon_update),
    .src_we_i     (wkup_cause_we),
    .src_wd_i     (wkup_cause_wd),
    .dst_de_i     (hw2reg.wkup_cause.de),
    .dst_d_i      (hw2reg.wkup_cause.d),
    .src_busy_o   (wkup_cause_busy),
    .src_qs_o     (wkup_cause_qs),
    .dst_qe_o     (),
    .q            (reg2hw.wkup_cause.q)
  );




  logic [11:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[ 0] = (reg_addr == AON_TIMER_ALERT_TEST_OFFSET);
    addr_hit[ 1] = (reg_addr == AON_TIMER_WKUP_CTRL_OFFSET);
    addr_hit[ 2] = (reg_addr == AON_TIMER_WKUP_THOLD_OFFSET);
    addr_hit[ 3] = (reg_addr == AON_TIMER_WKUP_COUNT_OFFSET);
    addr_hit[ 4] = (reg_addr == AON_TIMER_WDOG_REGWEN_OFFSET);
    addr_hit[ 5] = (reg_addr == AON_TIMER_WDOG_CTRL_OFFSET);
    addr_hit[ 6] = (reg_addr == AON_TIMER_WDOG_BARK_THOLD_OFFSET);
    addr_hit[ 7] = (reg_addr == AON_TIMER_WDOG_BITE_THOLD_OFFSET);
    addr_hit[ 8] = (reg_addr == AON_TIMER_WDOG_COUNT_OFFSET);
    addr_hit[ 9] = (reg_addr == AON_TIMER_INTR_STATE_OFFSET);
    addr_hit[10] = (reg_addr == AON_TIMER_INTR_TEST_OFFSET);
    addr_hit[11] = (reg_addr == AON_TIMER_WKUP_CAUSE_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(AON_TIMER_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(AON_TIMER_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(AON_TIMER_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(AON_TIMER_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(AON_TIMER_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(AON_TIMER_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(AON_TIMER_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(AON_TIMER_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(AON_TIMER_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(AON_TIMER_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(AON_TIMER_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(AON_TIMER_PERMIT[11] & ~reg_be)))));
  end
  assign alert_test_we = addr_hit[0] & reg_we & !reg_error;

  assign alert_test_wd = reg_wdata[0];
  assign wkup_ctrl_we = addr_hit[1] & reg_we & !reg_error;

  assign wkup_ctrl_enable_wd = reg_wdata[0];

  assign wkup_ctrl_prescaler_wd = reg_wdata[12:1];
  assign wkup_thold_we = addr_hit[2] & reg_we & !reg_error;

  assign wkup_thold_wd = reg_wdata[31:0];
  assign wkup_count_we = addr_hit[3] & reg_we & !reg_error;

  assign wkup_count_wd = reg_wdata[31:0];
  assign wdog_regwen_we = addr_hit[4] & reg_we & !reg_error;

  assign wdog_regwen_wd = reg_wdata[0];
  assign wdog_ctrl_we = addr_hit[5] & reg_we & !reg_error;

  assign wdog_ctrl_enable_wd = reg_wdata[0];

  assign wdog_ctrl_pause_in_sleep_wd = reg_wdata[1];
  assign wdog_bark_thold_we = addr_hit[6] & reg_we & !reg_error;

  assign wdog_bark_thold_wd = reg_wdata[31:0];
  assign wdog_bite_thold_we = addr_hit[7] & reg_we & !reg_error;

  assign wdog_bite_thold_wd = reg_wdata[31:0];
  assign wdog_count_we = addr_hit[8] & reg_we & !reg_error;

  assign wdog_count_wd = reg_wdata[31:0];
  assign intr_state_we = addr_hit[9] & reg_we & !reg_error;

  assign intr_state_wkup_timer_expired_wd = reg_wdata[0];

  assign intr_state_wdog_timer_expired_wd = reg_wdata[1];
  assign intr_test_we = addr_hit[10] & reg_we & !reg_error;

  assign intr_test_wkup_timer_expired_wd = reg_wdata[0];

  assign intr_test_wdog_timer_expired_wd = reg_wdata[1];
  assign wkup_cause_we = addr_hit[11] & reg_we & !reg_error;

  assign wkup_cause_wd = reg_wdata[0];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = '0;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = wkup_ctrl_enable_qs;
        reg_rdata_next[12:1] = wkup_ctrl_prescaler_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = wkup_thold_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = wkup_count_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[0] = wdog_regwen_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[0] = wdog_ctrl_enable_qs;
        reg_rdata_next[1] = wdog_ctrl_pause_in_sleep_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = wdog_bark_thold_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[31:0] = wdog_bite_thold_qs;
      end

      addr_hit[8]: begin
        reg_rdata_next[31:0] = wdog_count_qs;
      end

      addr_hit[9]: begin
        reg_rdata_next[0] = intr_state_wkup_timer_expired_qs;
        reg_rdata_next[1] = intr_state_wdog_timer_expired_qs;
      end

      addr_hit[10]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end

      addr_hit[11]: begin
        reg_rdata_next[0] = wkup_cause_qs;
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
      addr_hit[1]: begin
        reg_busy =
          wkup_ctrl_enable_busy |
          wkup_ctrl_prescaler_busy;
      end
      addr_hit[2]: begin
        reg_busy = wkup_thold_busy;
      end
      addr_hit[3]: begin
        reg_busy = wkup_count_busy;
      end
      addr_hit[5]: begin
        reg_busy =
          wdog_ctrl_enable_busy |
          wdog_ctrl_pause_in_sleep_busy;
      end
      addr_hit[6]: begin
        reg_busy = wdog_bark_thold_busy;
      end
      addr_hit[7]: begin
        reg_busy = wdog_bite_thold_busy;
      end
      addr_hit[8]: begin
        reg_busy = wdog_count_busy;
      end
      addr_hit[11]: begin
        reg_busy = wkup_cause_busy;
      end
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
