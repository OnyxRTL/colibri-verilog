// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
// @file ram.vhdl
// @brief Single Port RAM
// @author Alberto Perro (alberto.perro at cern.ch)
// @date 30-11-2023 Created
// @date 27-06-2025 (mvodnik) Updated for BRAM synth. and added `g_WRITE_FIRST`
// @version 0.2
// @copyright CERN 2025
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 04-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//===============================================================================
//
// @brief Single Port RAM
// @details
//
//  The contents can be initialized from a text file, by setting its path to
//  the `g_INIT_FILE` generic parameter. The file should contain one word per
//  line (e.g. `g_N_WORDS` lines) in hexadecimal format.
//
//  This component is designed to be able to synthesize as BRAM.
//===============================================================================

module ram#(
    // number of words to store in RAM
    parameter g_N_WORDS      = 16,
    // word size
    parameter g_DATA_WIDTH   = 8,
    // add registers to write line
    parameter g_REGISTER_IN  = 0,
    // add register to read line (required for BRAM synthesis)
    parameter g_REGISTER_OUT = 1,
    // initialization file
    parameter g_INIT_FILE    = "",
    // Initial value to fill the RAM with (in case no init. file is specified)
    parameter [g_DATA_WIDTH-1:0] g_INIT_WORD = {g_DATA_WIDTH{1'b0}},
    // choose between write- or read-first interface
    parameter g_WRITE_FIRST  = 1
)(
    input                          clk_i,   // clock
    input                          reset_i, // reset
    input  [$clog2(g_N_WORDS)-1:0] addr_i,  // ram address (read or write)
    input                          we_i,    // write request
    input  [g_DATA_WIDTH-1:0]      data_i,  // data to write
    output [g_DATA_WIDTH-1:0]      q_o      // data to read
);

    reg [g_DATA_WIDTH-1:0] memory[0:g_N_WORDS-1];

    integer i;

    initial begin
        for (i = 0; i < g_N_WORDS; i = i + 1) begin
            memory[i] = g_INIT_WORD;
        end
        if (g_INIT_FILE!="") begin
            $readmemh(g_INIT_FILE, memory);
        end
    end

    // (Optionally) registered interface signals
    reg [$clog2(g_N_WORDS)-1:0] reg_addr;
    reg                         reg_we;
    reg [g_DATA_WIDTH-1:0]      reg_data;
    reg [g_DATA_WIDTH-1:0]      reg_q;

    generate
        if (g_REGISTER_IN) begin : gen_reg_in
            always @(posedge clk_i) begin
                reg_addr <= addr_i;
                reg_we   <= we_i;
                reg_data <= data_i;
            end
        end else begin : gen_comb_in
            always @(*) begin
                reg_addr = addr_i;
                reg_we   = we_i;
                reg_data = data_i;
            end
        end
    endgenerate

    always @(posedge clk_i) begin
        if (reg_we) begin
            memory[reg_addr] <= reg_data;
        end

        if (g_REGISTER_OUT) begin
            if (reset_i) begin
                reg_q <= {g_DATA_WIDTH{1'b0}};
            end else begin
                if (g_WRITE_FIRST && reg_we) begin
                    reg_q <= reg_data;
                end else begin
                    reg_q <= memory[reg_addr];
                end
            end
        end
    end

    generate
        if (g_REGISTER_OUT) begin : gen_reg_read
            assign q_o = reg_q;
        end else begin : gen_async_read
            assign q_o = (g_WRITE_FIRST && reg_we) ? reg_data : memory[reg_addr];
        end
    endgenerate

endmodule
