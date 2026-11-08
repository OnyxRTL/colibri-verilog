// SPDX-FileCopyrightText: 2026 CERN
// SPDX-License-Identifier: CERN-OHL-W-2.0
//
// Original Work:
// @file true_dpram_xilinx.vhdl
// @brief Xilinx-style True Dual-Port RAM
// @author Alberto Perro (alberto.perro at cern.ch)
// @date 13-03-2026 Created
// @version 0.1
// @copyright CERN 2026
//
// Translated / Ported to Verilog by:
// Copyright (c) 2026 MrAbhi19
// @date 08-11-2026 Ported to Verilog
// @note Ported from the upstream Colibri commit: 3fa784121ccea86d9e65b2e0dc08d2a3327f5f2f
// Derived work under CERN-OHL-W-2.0
//===============================================================================
//
// @brief Xilinx-style True Dual-Port RAM with mixed width support
// @details
//
//  This RAM component features 2 independent read/write ports in separate
//  clock domains.
//  The ports can be configured with different widths, which could be supported by hardware.
//  Please check with the vendor which combination of widths is allowed for the ram primitives.
//  It is designed to be able to synthesize as BRAM.
//=================================================================================

module true_dpram_xilinx#(
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
    // Select write/read-first port operation
    parameter g_WRITE_FIRST  = 1,
    // Add output register to ease timing
    parameter g_REGISTER_OUT = 0,
    // initialization file
    parameter g_INIT_FILE    = "",
    // Initial value to fill the RAM with (in case no init. file is specified)
    parameter [g_DATA_WIDTH-1:0] g_INIT_WORD = {g_DATA_WIDTH{1'b0}}
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

    // internal memory width
    localparam c_MEM_WIDTH  = (g_A_DATA_WIDTH < g_B_DATA_WIDTH) ? g_A_DATA_WIDTH : g_B_DATA_WIDTH;
    // port ratio
    localparam c_PORT_RATIO = ((g_A_DATA_WIDTH > g_B_DATA_WIDTH) ? g_A_DATA_WIDTH : g_B_DATA_WIDTH) / c_MEM_WIDTH;
    // internal memory depth
    localparam c_MEM_DEPTH  = g_N_WORDS * c_PORT_RATIO;
    // Ratio between A port and v_memory
    localparam c_A_RATIO    = g_A_DATA_WIDTH / c_MEM_WIDTH;
    // Ratio between B port and v_memory
    localparam c_B_RATIO    = g_B_DATA_WIDTH / c_MEM_WIDTH;
    // max width
    localparam c_MAX_WIDTH  = (g_A_DATA_WIDTH > g_B_DATA_WIDTH) ? g_A_DATA_WIDTH : g_B_DATA_WIDTH;

    reg [g_A_DATA_WIDTH-1:0] read_a;
    reg [g_B_DATA_WIDTH-1:0] read_b;

    reg [c_MEM_WIDTH-1:0] v_memory [0:c_MEM_DEPTH-1];

    initial begin : init_mem
        integer k;
        for (k = 0; k < c_MEM_DEPTH; k = k + 1)
            v_memory[k] = g_INIT_WORD[c_MEM_WIDTH-1:0];
        if (g_INIT_FILE != "")
            $readmemh(g_INIT_FILE, v_memory);
    end

//==============================================================

    generate
        if (g_A_DATA_WIDTH > g_B_DATA_WIDTH) begin: gen_a_wider

            reg [$clog2(c_MEM_DEPTH)-1:0] v_ptr;

            always @(posedge clka_i) begin : proc_port_a_mux
                integer n;
                if (g_WRITE_FIRST) begin
                    if (wra_i) begin
                        for (n = 0; n < c_A_RATIO; n = n + 1) begin
                            v_ptr = addra_i * c_A_RATIO + n;
                            v_memory[v_ptr] = dataa_i[g_A_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH];
                        end
                        read_a <= dataa_i;
                    end else begin
                        for (n = 0; n < c_A_RATIO; n = n + 1) begin
                            v_ptr = addra_i * c_A_RATIO + n;
                            read_a[g_A_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH] <= v_memory[v_ptr];
                        end
                    end
                end else begin
                    for (n = 0; n < c_A_RATIO; n = n + 1) begin
                        v_ptr = addra_i * c_A_RATIO + n;
                        read_a[g_A_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH] <= v_memory[v_ptr];
                        if (wra_i)
                            v_memory[v_ptr] = dataa_i[g_A_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH];
                    end
                end
            end
        end else begin: gen_a_narrow

            always @(posedge clka_i) begin
                if (g_WRITE_FIRST) begin
                    if (wra_i) begin
                        v_memory[addra_i] = dataa_i;
                        read_a <= dataa_i;
                    end else begin
                        read_a <= v_memory[addra_i];
                    end
                end else begin
                    read_a <= v_memory[addra_i];
                    if (wra_i) begin
                        v_memory[addra_i] = dataa_i;
                    end
                end
            end
        end

    endgenerate

//===============================================================================

    generate
        if (g_B_DATA_WIDTH > g_A_DATA_WIDTH) begin: gen_b_wider

            reg [$clog2(c_MEM_DEPTH)-1:0] v_ptr;

            always @(posedge clkb_i) begin : proc_port_b_mux
                integer n;
                if (g_WRITE_FIRST) begin
                    if (wrb_i) begin
                        for (n = 0; n < c_B_RATIO; n = n + 1) begin
                            v_ptr = addrb_i * c_B_RATIO + n;
                            v_memory[v_ptr] = datab_i[g_B_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH];
                        end
                        read_b <= datab_i;
                    end else begin
                        for (n = 0; n < c_B_RATIO; n = n + 1) begin
                            v_ptr = addrb_i * c_B_RATIO + n;
                            read_b[g_B_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH] <= v_memory[v_ptr];
                        end
                    end
                end else begin
                    for (n = 0; n < c_B_RATIO; n = n + 1) begin
                        v_ptr = addrb_i * c_B_RATIO + n;
                        read_b[g_B_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH] <= v_memory[v_ptr];
                        if (wrb_i)
                            v_memory[v_ptr] = datab_i[g_B_DATA_WIDTH-1 - n*c_MEM_WIDTH -: c_MEM_WIDTH];
                    end
                end
            end
        end else begin: gen_b_narrow

            always @(posedge clkb_i) begin
                if (g_WRITE_FIRST) begin
                    if (wrb_i) begin
                        v_memory[addrb_i] = datab_i;
                        read_b <= datab_i;
                    end else begin
                        read_b <= v_memory[addrb_i];
                    end
                end else begin
                    read_b <= v_memory[addrb_i];
                    if (wrb_i) begin
                        v_memory[addrb_i] = datab_i;
                    end
                end
            end
        end

    endgenerate

//======================================================================================

    generate
        if (g_REGISTER_OUT) begin : gen_reg_out
            always @(posedge clka_i) begin
                dataa_o <= read_a;
            end
            always @(posedge clkb_i) begin
                datab_o <= read_b;
            end
        end else begin : gen_comb_out
            always @(*) begin
                dataa_o = read_a;
                datab_o = read_b;
            end
        end
    endgenerate


//===================================================================================
// Assertions
//===================================================================================

    generate
        if ((c_MAX_WIDTH % c_MEM_WIDTH) != 0) begin : chk_ratio
            $error("Smaller port is not a divisor of larger port. Cannot infer RAM with this configuration.");
        end
        if (g_A_ADDR_WIDTH < $clog2(c_MEM_DEPTH / c_A_RATIO)) begin : chk_a_addr
            $error("The Port A Address width is too small to access g_N_WORDS.");
        end
        if (g_B_ADDR_WIDTH < $clog2(c_MEM_DEPTH / c_B_RATIO)) begin : chk_b_addr
            $error("The Port B Address width is too small to access g_N_WORDS.");
        end
        if (c_A_RATIO != c_B_RATIO) begin : note_mixed
            $info("Implementing a Mixed Width (Asymmetric) dual port RAM. Check FPGA datasheet for allowed widths.");
        end
    endgenerate

endmodule
