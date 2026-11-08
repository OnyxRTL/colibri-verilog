# colibri-verilog

Verilog port of CERN's [Colibri](https://gitlab.cern.ch/colibri/colibri) HDL library.

> **Note:** `colibri-verilog` is an independent community project. It is not affiliated with, maintained by, or endorsed by CERN, the LHCb collaboration, or the original Colibri authors.

## Current Scope

This repository is currently focused on porting the `src/memory` modules from the original VHDL library to Verilog/SystemVerilog, so they can be synthesized and simulated in open-source EDA toolchains like Yosys and Verilator.

## Progress

**colibri.memory:** `[██████░░░░░░░] 6/13`

## Modules

| File | Description |
|---|---|
| `rom.v` | Read-only memory, with hex file initialization |
| `ram.v` | Single-port RAM with optional input/output registers and write-first/read-first mode |
| `simple_dpram.v` | Simple dual-port RAM wrapper. Picks the Xilinx or Altera version with `g_IMPL_STYLE` (`` `VIVADO `` or `` `QUARTUS ``) |
| `simple_dpram_xilinx.v` | Xilinx-style simple dual-port RAM, separate read/write clocks, optional mixed port widths |
| `simple_dpram_altera.v` | Altera-style simple dual-port RAM, separate read/write clocks, optional mixed port widths |
| `simple_dpram_be.v` | Simple dual-port RAM with per-byte write enable |
| `true_dpram.v` | True dual-port RAM wrapper. Picks the Xilinx or Altera version with `g_IMPL_STYLE` (`` `VIVADO `` or `` `QUARTUS ``) |
| `true_dpram_xilinx.v` | Xilinx-style true dual-port RAM, two independent read/write ports with separate clocks, optional mixed port widths and write-first/read-first mode |
| `true_dpram_altera.v` | Altera-style true dual-port RAM, two independent read/write ports with separate clocks, optional mixed port widths |
| `ring_buffer.sv` | RAM-based simple ring buffer (SystemVerilog) |

## Status

All 13 modules of the original `src/memory` directory:

| Module | Ported | Tested |
|---|:---:|:---:|
| `rom` | ✅ | ✅ |
| `ram` | ✅ | ❌ |
| `simple_dpram` | ✅ | ❌ |
| &nbsp;&nbsp;↳ `simple_dpram_xilinx` | ✅ | ❌ |
| &nbsp;&nbsp;↳ `simple_dpram_altera` | ✅ | ❌ |
| `simple_dpram_be` | ✅ | ❌ |
| `true_dpram` | ✅ | ❌ |
| &nbsp;&nbsp;↳ `true_dpram_xilinx` | ✅ | ❌ |
| &nbsp;&nbsp;↳ `true_dpram_altera` | ✅ | ❌ |
| `bicam` | ❌ | ❌ |
| `fifo` | ❌ | ❌ |
| `cc_fifo` | ❌ | ❌ |
| `cc_ram_fifo` | ❌ | ❌ |
| `packet_fifo` | ❌ | ❌ |
| `packet_cc_fifo` | ❌ | ❌ |
| `packet_cc_ram_fifo` | ❌ | ❌ |
| `ring_buffer` | ✅ | ❌ |

Ported: 6/13. Tested: 1/13. The indented `↳` rows are implementation variants of the wrapper above them and are not counted separately.

`mem_pkg` (the VHDL helper package for memory initialization) is not ported as a module. Its job is covered by `$readmemh` and localparams inside each Verilog file.

## Notes

- `simple_dpram.v` needs both `simple_dpram_xilinx.v` and `simple_dpram_altera.v` in the project. `true_dpram.v` likewise needs `true_dpram_xilinx.v` and `true_dpram_altera.v`. These four files live in `src/memory/optimized/`.
- The Xilinx and Altera variants use SystemVerilog features (`$error`/`$info` in generate blocks, and packed arrays in the Altera ones). Set your tool to SystemVerilog mode, or rename the files to `.sv`.
- Memory init files are hex, one word per line. For the Xilinx versions a word is the narrower port's width. For the Altera versions a word is the full wider-port width.
- Only `rom.v` has a testbench so far (`sim/memory/tb_rom.v`). The other ports have not been verified against the original VHDL yet, and testbenches are still to be added.

## Attribution & License

This project is a derivative work based on the Colibri library developed by Alberto Perro, Mitja Vodnik, and contributors at CERN.

* **Original Work:** Copyright © CERN
* **License:** CERN-OHL-W-2.0
* All original copyright headers and SPDX identifiers are retained within the translated source files. See the `LICENSE` file for the full legal text.
