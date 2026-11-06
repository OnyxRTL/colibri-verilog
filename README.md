# colibri-verilog

Verilog port of CERN's [Colibri](https://gitlab.cern.ch/colibri/colibri) HDL library.

> **Note:** `colibri-verilog` is an independent community project. It is not affiliated with, maintained by, or endorsed by CERN, the LHCb collaboration, or the original Colibri authors.

## Current Scope

This repository is currently focused on porting the `src/memory` modules from the original VHDL library to Verilog/SystemVerilog, so they can be synthesized and simulated in open-source EDA toolchains like Yosys and Verilator.

## Modules

| File | Description |
|---|---|
| `rom.v` | Read-only memory, with hex file initialization |
| `ram.v` | Single-port RAM with optional input/output registers and write-first/read-first mode |
| `simple_dpram.v` | Simple dual-port RAM wrapper. Picks the Xilinx or Altera version with `g_IMPL_STYLE` (`` `VIVADO `` or `` `QUARTUS ``) |
| `simple_dpram_xilinx.v` | Xilinx-style simple dual-port RAM, separate read/write clocks, optional mixed port widths |
| `simple_dpram_altera.v` | Altera-style simple dual-port RAM, separate read/write clocks, optional mixed port widths |
| `simple_dpram_be.v` | Simple dual-port RAM with per-byte write enable |

## Notes

- `simple_dpram.v` needs both `simple_dpram_xilinx.v` and `simple_dpram_altera.v` in the project.
- `simple_dpram_xilinx.v` and `simple_dpram_altera.v` use SystemVerilog features (`$error`/`$info` in generate blocks, and packed arrays in the Altera one). Set your tool to SystemVerilog mode, or rename the files to `.sv`.
- Memory init files are hex, one word per line. For the Xilinx version a word is the narrower port's width. For the Altera version a word is the full wider-port width.
- These ports have not been fully verified against the original VHDL yet. Testbenches are still to be added.

## Attribution & License

This project is a derivative work based on the Colibri library developed by Alberto Perro, Mitja Vodnik, and contributors at CERN.

* **Original Work:** Copyright © CERN
* **License:** CERN-OHL-W-2.0
* All original copyright headers and SPDX identifiers are retained within the translated source files. See the `LICENSE` file for the full legal text.
