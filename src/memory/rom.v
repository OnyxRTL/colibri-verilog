// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
// @file rom.vhdl
// @brief Read-Only Memory
// @author Mitja Vodnik <mitja.vodnik@cern.ch> (CERN - EP-LBC)
// @date 27-06-2025 Created
// @version 0.1
// @copyright CERN 2025
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 02-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//===============================================================================
//
// @brief Read-Only Memory
// @details
//
// The ROM contents are initialized from a text file, by setting its path to
// the `g_INIT_FILE` generic parameter. The file should contain one word per
// line (e.g. `g_N_WORDS` lines) in hexadecimal format.
// 
// Words are read from ROM by setting the appropriate address at the `addr_i`
// port. The data will be available on the `data_o` port on the next clock
// cycle.
//
// This component is designed to be able to synthesize as BRAM.
//
//===============================================================================


module rom#(
    // Number of words to store
    parameter g_N_WORDS = 10,
    // Word size in bits
    parameter g_DATA_WIDTH = 8,
    // Initialization file path
    parameter g_INIT_FILE = ""
)(
    input                          clk_i,   // clock
    input  [$clog2(g_N_WORDS)-1:0] addr_i,  // read address
    output reg [g_DATA_WIDTH-1:0]  data_o   // data to read
);

    reg [g_DATA_WIDTH-1:0] data[0:g_N_WORDS-1];

    integer i;

    initial begin
        for (i = 0; i < g_N_WORDS; i = i + 1) begin
            data[i] = {g_DATA_WIDTH{1'b0}};
        end
        if (g_INIT_FILE!="") begin
            $readmemh(g_INIT_FILE, data);
        end
    end

    always @(posedge clk_i) begin
        data_o <= data[addr_i];
    end

endmodule
