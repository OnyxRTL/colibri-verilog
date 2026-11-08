// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
// @file ring_buffer.vhdl
// @brief Simple Ring Buffer
// @author Alberto Perro
// @date 23-01-2024 Created
// @version 0.1
// @copyright CERN 2024
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 04-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//===============================================================================
//
// @brief RAM-based simple ring buffer
// @details
// This entity implements a simple stream ring buffer.
// Compared to a FIFO, it is possible to write when full, overwriting the oldest word in memory.
//================================================================================

module ring_buffer #(
    // size of buffer in words
    parameter int g_NUM_WORDS = 4,
    // size of data words in bits
    parameter int g_DATA_WIDTH = 8
)(
    input  logic                    clk_i,          // common clock
    input  logic                    reset_i,        // reset
    input  logic [g_DATA_WIDTH-1:0] snk_data_i,     // data input
    input  logic                    snk_valid_i,    // valid input
    output logic [g_DATA_WIDTH-1:0] src_data_o,     // data output
    output logic                    src_valid_o,    // valid output
    input  logic                    src_ready_i     // read request
);

    logic [g_DATA_WIDTH-1:0] mem [0:g_NUM_WORDS-1];

    typedef struct packed {
        logic [$clog2(g_NUM_WORDS)-1:0] head;
        logic [$clog2(g_NUM_WORDS)-1:0] tail;
        logic [$clog2(g_NUM_WORDS):0]   usedw;
    } sig_t;

    localparam sig_t c_SIG_INIT = '{head: 0, tail: 0, usedw: 0};

    sig_t rreg;
    sig_t rcmb;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            rreg <= c_SIG_INIT;
        end else begin
            rreg <= rcmb;
        end
    end

    always_comb begin
        sig_t v_int;

        v_int = rreg;

        // Advance write pointer (head)
        if (snk_valid_i) begin
            if (rreg.head != g_NUM_WORDS - 1) begin
                v_int.head = rreg.head + 1;
            end else begin
                v_int.head = 0;
            end
        end

        // Fill level count (usedw)
        if (snk_valid_i) begin
            if (!src_ready_i || rreg.usedw == 0) begin
                if (rreg.usedw != g_NUM_WORDS) begin
                    v_int.usedw = rreg.usedw + 1;
                end
            end
        end else if (src_ready_i && rreg.usedw != 0) begin
            v_int.usedw = rreg.usedw - 1;
        end

        // Advance read pointer (tail) - write when full, read when not empty
        if ((rreg.usedw == g_NUM_WORDS && snk_valid_i) || (src_ready_i && rreg.usedw != 0)) begin
            if (rreg.tail != g_NUM_WORDS - 1) begin
                v_int.tail = rreg.tail + 1;
            end else begin
                v_int.tail = 0;
            end
        end

        rcmb = v_int;
    end


    always_ff @(posedge clk_i) begin
        if (snk_valid_i) begin
            mem[rreg.head] <= snk_data_i;
        end
    end

    assign src_valid_o = (rreg.usedw != 0) ? 1'b1 : 1'b0;
    assign src_data_o  = src_valid_o ? mem[rreg.tail] : '0;

endmodule
