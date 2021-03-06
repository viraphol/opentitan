// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_peri package generated by `tlgen.py` tool

package tl_peri_pkg;

  localparam logic [31:0] ADDR_SPACE_UART0         = 32'h 40000000;
  localparam logic [31:0] ADDR_SPACE_UART1         = 32'h 40010000;
  localparam logic [31:0] ADDR_SPACE_UART2         = 32'h 40020000;
  localparam logic [31:0] ADDR_SPACE_UART3         = 32'h 40030000;
  localparam logic [31:0] ADDR_SPACE_GPIO          = 32'h 40040000;
  localparam logic [31:0] ADDR_SPACE_SPI_DEVICE    = 32'h 40050000;
  localparam logic [31:0] ADDR_SPACE_RV_TIMER      = 32'h 40100000;
  localparam logic [31:0] ADDR_SPACE_USBDEV        = 32'h 40500000;
  localparam logic [31:0] ADDR_SPACE_PWRMGR        = 32'h 40400000;
  localparam logic [31:0] ADDR_SPACE_RSTMGR        = 32'h 40410000;
  localparam logic [31:0] ADDR_SPACE_CLKMGR        = 32'h 40420000;
  localparam logic [31:0] ADDR_SPACE_RAM_RET       = 32'h 40520000;
  localparam logic [31:0] ADDR_SPACE_OTP_CTRL      = 32'h 40130000;
  localparam logic [31:0] ADDR_SPACE_LC_CTRL       = 32'h 40140000;
  localparam logic [31:0] ADDR_SPACE_SENSOR_CTRL   = 32'h 40110000;
  localparam logic [31:0] ADDR_SPACE_ALERT_HANDLER = 32'h 40150000;
  localparam logic [31:0] ADDR_SPACE_SRAM_CTRL_RET = 32'h 40510000;
  localparam logic [31:0] ADDR_SPACE_NMI_GEN       = 32'h 40160000;
  localparam logic [31:0] ADDR_SPACE_AST_WRAPPER   = 32'h 40180000;

  localparam logic [31:0] ADDR_MASK_UART0         = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_UART1         = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_UART2         = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_UART3         = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_GPIO          = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SPI_DEVICE    = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RV_TIMER      = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_USBDEV        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_PWRMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RSTMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_CLKMGR        = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_RAM_RET       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_OTP_CTRL      = 32'h 00003fff;
  localparam logic [31:0] ADDR_MASK_LC_CTRL       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SENSOR_CTRL   = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_ALERT_HANDLER = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_SRAM_CTRL_RET = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_NMI_GEN       = 32'h 00000fff;
  localparam logic [31:0] ADDR_MASK_AST_WRAPPER   = 32'h 00000fff;

  localparam int N_HOST   = 1;
  localparam int N_DEVICE = 19;

  typedef enum int {
    TlUart0 = 0,
    TlUart1 = 1,
    TlUart2 = 2,
    TlUart3 = 3,
    TlGpio = 4,
    TlSpiDevice = 5,
    TlRvTimer = 6,
    TlUsbdev = 7,
    TlPwrmgr = 8,
    TlRstmgr = 9,
    TlClkmgr = 10,
    TlRamRet = 11,
    TlOtpCtrl = 12,
    TlLcCtrl = 13,
    TlSensorCtrl = 14,
    TlAlertHandler = 15,
    TlSramCtrlRet = 16,
    TlNmiGen = 17,
    TlAstWrapper = 18
  } tl_device_e;

  typedef enum int {
    TlMain = 0
  } tl_host_e;

endpackage
