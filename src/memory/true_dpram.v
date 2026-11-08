// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 08-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//==========================================================================================
//
// @brief True Dual-Port RAM with mixed width support
// @details
//
//  This RAM component features 2 independent read/write ports in separate
//  clock domains.
//  The ports can be configured with different widths, which could be supported by hardware.
//  Please check with the vendor which combination of widths is allowed for the ram primitives.
//  It is designed to be able to synthesize as BRAM.
//========================================================================================

`ifndef VIVADO
  `define VIVADO 0
`endif
`ifndef QUARTUS
  `define QUARTUS 1
`endif

module true_dpram#(
    // RAM width in bits
    parameter g_DATA_WIDTH   = 16,
    // RAM port A width in bits (by default set to g_DATA_WIDTH)
    parameter g_A_DATA_WIDTH = g_DATA_WIDTH,
    // RAM port B width in bits (modify to infer mixed width RAM)
    parameter g_B_DATA_WIDTH = g_A_DATA_WIDTH,
    // RAM depth as number of data words of the largest port size
    parameter g_N_WORDS      = 10,
    // RAM address A port
    parameter g_A_ADDR_WIDTH = $clog2((g_A_DATA_WIDTH > g_B_DATA_WIDTH ? g_A_DATA_WIDTH : g_B_DATA_WIDTH)* g_N_WORDS / g_A_DATA_WIDTH),
    // RAM address B port
    parameter g_B_ADDR_WIDTH = $clog2((g_A_DATA_WIDTH > g_B_DATA_WIDTH ? g_A_DATA_WIDTH : g_B_DATA_WIDTH)* g_N_WORDS / g_B_DATA_WIDTH),
    // Select write/read-first port operation (Note: Only Intel supports write-first)
    parameter g_WRITE_FIRST  = 1,
    // Add output register to ease timing
    parameter g_REGISTER_OUT = 0,
    // initialization file
    parameter g_INIT_FILE    = "",
    // Initial value to fill the RAM with (in case no init. file is specified)
    parameter [g_DATA_WIDTH-1:0] g_INIT_WORD = {g_DATA_WIDTH{1'b0}},
    // implementation style, use VIVADO or QUARTUS to force a specific implementation
    parameter g_IMPL_STYLE = `VIVADO
)(
    // Port A
    input                           clka_i,    // clock
    input                           wra_i,     // write-enable
    input      [g_A_ADDR_WIDTH-1:0] addra_i,   // Address
    input      [g_A_DATA_WIDTH-1:0] dataa_i,   // data input
    output reg [g_A_DATA_WIDTH-1:0] dataa_o,   // data output

    // Port B
    input                           clkb_i,    // clock
    input                           wrb_i,     // write-enable
    input      [g_B_ADDR_WIDTH-1:0] addrb_i,   // Address
    input      [g_B_DATA_WIDTH-1:0] datab_i,   // data input
    output reg [g_B_DATA_WIDTH-1:0] datab_o    // data output
);

    generate
        if (g_IMPL_STYLE == `QUARTUS) begin : gen_altera

            true_dpram_altera #(
                .g_DATA_WIDTH   (g_DATA_WIDTH),
                .g_A_DATA_WIDTH (g_A_DATA_WIDTH),
                .g_B_DATA_WIDTH (g_B_DATA_WIDTH),
                .g_N_WORDS      (g_N_WORDS),
                .g_A_ADDR_WIDTH (g_A_ADDR_WIDTH),
                .g_B_ADDR_WIDTH (g_B_ADDR_WIDTH),
                .g_REGISTER_OUT (g_REGISTER_OUT),
                .g_INIT_FILE    (g_INIT_FILE),
                .g_INIT_WORD    (g_INIT_WORD)
            ) true_dpram_altera_inst (
                .clka_i  (clka_i),
                .wra_i   (wra_i),
                .addra_i (addra_i),
                .dataa_i (dataa_i),
                .dataa_o (dataa_o),
                .clkb_i  (clkb_i),
                .wrb_i   (wrb_i),
                .addrb_i (addrb_i),
                .datab_i (datab_i),
                .datab_o (datab_o)
            );

        end else begin : gen_xilinx

            true_dpram_xilinx #(
                .g_DATA_WIDTH   (g_DATA_WIDTH),
                .g_A_DATA_WIDTH (g_A_DATA_WIDTH),
                .g_B_DATA_WIDTH (g_B_DATA_WIDTH),
                .g_N_WORDS      (g_N_WORDS),
                .g_A_ADDR_WIDTH (g_A_ADDR_WIDTH),
                .g_B_ADDR_WIDTH (g_B_ADDR_WIDTH),
                .g_WRITE_FIRST  (g_WRITE_FIRST),
                .g_REGISTER_OUT (g_REGISTER_OUT),
                .g_INIT_FILE    (g_INIT_FILE),
                .g_INIT_WORD    (g_INIT_WORD)
            ) true_dpram_xilinx_inst (
                .clka_i  (clka_i),
                .wra_i   (wra_i),
                .addra_i (addra_i),
                .dataa_i (dataa_i),
                .dataa_o (dataa_o),
                .clkb_i  (clkb_i),
                .wrb_i   (wrb_i),
                .addrb_i (addrb_i),
                .datab_i (datab_i),
                .datab_o (datab_o)
            );

        end
    endgenerate

endmodule
