# colibri-verilog

Verilog port of CERN's [Colibri](https://gitlab.cern.ch/colibri/colibri) HDL library.

> **Note:** `colibri-verilog` is an independent community project. It is not affiliated with, maintained by, or endorsed by CERN, the LHCb collaboration, or the original Colibri authors.

## Current Scope

This repository is currently focused on porting the `src/memory` modules from the original VHDL library to SystemVerilog. This allows these components to be synthesized and simulated natively in open-source EDA toolchains like Yosys and Verilator.

**Modules:**
* `rom.sv` — Read-Only Memory (synthesizes to BRAM, supports hex file initialization)

## Attribution & License

This project is a derivative work based on the Colibri library developed by Alberto Perro, Mitja Vodnik, and contributors at CERN.

* **Original Work:** Copyright © CERN
* **License:** CERN-OHL-W-2.0
* All original copyright headers and SPDX identifiers are retained within the translated source files. See the `LICENSE` file for the full legal text.
