// SPDX-FileCopyrightText: 2026 MrAbhi19
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// @file tb_rom.v
// @brief Automated testbench for the ROM module
// @author MrAbhi19
// @date 07-11-2026
//
// @note This testbench was developed with the assistance of AI tools.
//===============================================================================

`timescale 1ns/1ps

module tb_rom();

    localparam g_N_WORDS = 20;
    localparam g_DATA_WIDTH = 32;
    localparam g_INIT_FILE = "init.hex";

    reg                          clk;
    reg  [$clog2(g_N_WORDS)-1:0] addr;
    wire [g_DATA_WIDTH-1:0]      data_out;

    reg [g_DATA_WIDTH-1:0] expected_data [0:g_N_WORDS-1];
    integer i;
    integer errors = 0;

    rom #(
        .g_N_WORDS(g_N_WORDS),
        .g_DATA_WIDTH(g_DATA_WIDTH),
        .g_INIT_FILE(g_INIT_FILE)
    ) dut (
        .clk_i(clk),
        .addr_i(addr),
        .data_o(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $readmemh(g_INIT_FILE, expected_data);

        addr = 0;

        #20;

        for (i = 0; i < g_N_WORDS; i = i + 1) begin

            addr = i;

            @(posedge clk);
            @(posedge clk);

            #1;

            if (data_out !== expected_data[i]) begin
                $display("ERROR at address %0d: Expected %h, Got %h", i, expected_data[i], data_out);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("TEST PASSED: all %0d words read matched", g_N_WORDS);
         end else begin
            $display("Test failed with %0d mismatches", errors);
        end

        $finish;
    end

endmodule
