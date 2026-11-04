// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
// @file simple_dpram_be.vhdl
// @brief Simple Dual-Port RAM with write byte-enable
// @author Mitja Vodnik <mitja.vodnik@cern.ch> (CERN - EP-LBC)
// @date 06-06-2025 Created
// @version 0.1
// @copyright CERN 2025
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 04-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//==========================================================================================
//
// @brief Simple Dual-Port RAM with write byte-enable
// @details
//
//  This RAM component features separate read and write ports, with separate
//  clocks.
//  Additionally, the write port features a byte-enable vector (`wren_i`),
//  so only a subset of the bytes in the input word may be written.
//
//  This component is designed to be able to synthesize as BRAM.
//
//==========================================================================================

module simple_dpram_be#(
    // Byte width in bits (AMD supports 8, 9, 16 or 18)
    parameter g_BYTE_WIDTH = 8,
    // Bytes per data word - RAM width
    parameter g_WORD_BYTES = 8,
    // Words to store - RAM depth
    parameter g_N_WORDS    = 8,
    // initialization file
    parameter g_INIT_FILE  = "",
    // Initial value to fill the RAM with (in case no init. file is specified)
    parameter [g_WORD_BYTES * g_BYTE_WIDTH -1:0] g_INIT_WORD  = 0
)(
    // Write port with byte-enable
    input                                    wrclk_i,   // write port's clock
    input [g_WORD_BYTES-1:0]                 wren_i,    // per-byte write enable
    input [$clog2(g_N_WORDS)-1:0]            wraddr_i,  // write address
    input [g_WORD_BYTES * g_BYTE_WIDTH -1:0] wrdata_i,  // write data

    input                                         rdclk_i,  // read port's clock
    input                                         rden_i,   // read enable
    input      [$clog2(g_N_WORDS)-1:0]            rdaddr_i, // read address
    output reg [g_WORD_BYTES * g_BYTE_WIDTH -1:0] rddata_o  // read data
);

    localparam WIDTH = g_WORD_BYTES * g_BYTE_WIDTH;

    reg [WIDTH-1:0] memory[0:g_N_WORDS-1];

    //-----------------------------------------------------------

    integer j;

    initial begin
        for (j = 0; j < g_N_WORDS; j = j + 1) begin
            memory[j] = g_INIT_WORD;
        end
        if (g_INIT_FILE!="") begin
            $readmemh(g_INIT_FILE, memory);
        end
    end

    //----------------------------------------------------------
    //  Synchronous write port with byte-enable
    //----------------------------------------------------------

    integer i;

    always @(posedge wrclk_i) begin
        for (i = 0; i < g_WORD_BYTES; i = i + 1) begin
            if (wren_i[i]) begin
                memory[wraddr_i][i*g_BYTE_WIDTH +: g_BYTE_WIDTH] <=
                    wrdata_i[i*g_BYTE_WIDTH +: g_BYTE_WIDTH];
            end
        end
    end

    //----------------------------------------------------------
    //  Synchronous read port
    //----------------------------------------------------------

    always @(posedge rdclk_i) begin
        if (rden_i) begin
            rddata_o <= memory[rdaddr_i];
        end
    end

endmodule
