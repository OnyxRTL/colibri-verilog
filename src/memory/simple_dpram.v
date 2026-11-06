// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
// @file simple_dpram.vhdl
// @brief Simple Dual-Port RAM
// @author Alberto Perro (alberto.perro at cern.ch)
// @date 04-03-2024 Created
// @version 0.4
// @copyright CERN 2025
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 06-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//===============================================================================
// @brief Simple Dual-Port RAM
// @details
//
//  This RAM component features separate read and write ports, with separate
//  clocks.
//  The ports can be configured with different widths, which could be supported by hardware.
//  Please check with the vendor which combination of widths is allowed for the ram primitives.
//
//  It is designed to be able to synthesize as BRAM.
//===============================================================================

`ifndef VIVADO
  `define VIVADO 0
`endif
`ifndef QUARTUS
  `define QUARTUS 1
`endif

module simple_dpram#(
    // RAM width in bits (legacy behaviour)
    parameter g_DATA_WIDTH = 16,
    // RAM port A width in bits (by default set to g_DATA_WIDTH)
    parameter g_A_DATA_WIDTH = g_DATA_WIDTH,
    // RAM port B width in bits (modify to infer mixed width RAM)
    parameter g_B_DATA_WIDTH = g_A_DATA_WIDTH,
    // RAM depth as number of data words of the largest port size
    parameter g_N_WORDS = 10,
    // RAM address A port
    parameter g_A_ADDR_WIDTH = $clog2((g_A_DATA_WIDTH > g_B_DATA_WIDTH ? g_A_DATA_WIDTH : g_B_DATA_WIDTH)* g_N_WORDS / g_A_DATA_WIDTH),
    // RAM address B port
    parameter g_B_ADDR_WIDTH = $clog2((g_A_DATA_WIDTH > g_B_DATA_WIDTH ? g_A_DATA_WIDTH : g_B_DATA_WIDTH)* g_N_WORDS / g_B_DATA_WIDTH),
    // Add output register to ease timing
    parameter g_REGISTER_OUT = 0,
    // initialization file
    parameter g_INIT_FILE = "",
    // Initial value to fill the RAM with (in case no init. file is specified)
    parameter [g_A_DATA_WIDTH-1:0] g_INIT_WORD = {g_DATA_WIDTH{1'b0}},
    // implementation style, use VIVADO or QUARTUS to force a specific implementation
    parameter g_IMPL_STYLE = `VIVADO
)(
    // Write port
    input                      wrclk_i,  // clock
    input                      wren_i,   // write-enable
    input [g_A_ADDR_WIDTH-1:0] wraddr_i, // Address
    input [g_A_DATA_WIDTH-1:0] wrdata_i, // data input

    // Read port
    input                       rdclk_i,    // clock
    input                       rden_i,     // read-enable
    input  [g_B_ADDR_WIDTH-1:0] rdaddr_i,   // Address
    output [g_B_DATA_WIDTH-1:0] rddata_o    // data output
);

    generate
        if (g_IMPL_STYLE == `QUARTUS) begin : gen_altera

            simple_dpram_altera #(
                .g_DATA_WIDTH   (g_DATA_WIDTH),
                .g_A_DATA_WIDTH (g_A_DATA_WIDTH),
                .g_B_DATA_WIDTH (g_B_DATA_WIDTH),
                .g_N_WORDS      (g_N_WORDS),
                .g_A_ADDR_WIDTH (g_A_ADDR_WIDTH),
                .g_B_ADDR_WIDTH (g_B_ADDR_WIDTH),
                .g_REGISTER_OUT (g_REGISTER_OUT)
            ) simple_dpram_altera_inst (
                .wrclk_i  (wrclk_i),
                .wren_i   (wren_i),
                .wraddr_i (wraddr_i),
                .wrdata_i (wrdata_i),
                .rdclk_i  (rdclk_i),
                .rden_i   (rden_i),
                .rdaddr_i (rdaddr_i),
                .rddata_o (rddata_o)
            );

        end else begin : gen_xilinx

            simple_dpram_xilinx #(
                .g_DATA_WIDTH   (g_DATA_WIDTH),
                .g_A_DATA_WIDTH (g_A_DATA_WIDTH),
                .g_B_DATA_WIDTH (g_B_DATA_WIDTH),
                .g_N_WORDS      (g_N_WORDS),
                .g_A_ADDR_WIDTH (g_A_ADDR_WIDTH),
                .g_B_ADDR_WIDTH (g_B_ADDR_WIDTH),
                .g_REGISTER_OUT (g_REGISTER_OUT),
                .g_INIT_FILE    (g_INIT_FILE),
                .g_INIT_WORD    (g_INIT_WORD)
            ) simple_dpram_xilinx_inst (
                .wrclk_i  (wrclk_i),
                .wren_i   (wren_i),
                .wraddr_i (wraddr_i),
                .wrdata_i (wrdata_i),
                .rdclk_i  (rdclk_i),
                .rden_i   (rden_i),
                .rdaddr_i (rdaddr_i),
                .rddata_o (rddata_o)
            );

        end
    endgenerate

endmodule
