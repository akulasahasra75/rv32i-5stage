# RV32I 5-Stage Pipelined Processor

Full RV32I (37-instruction) pipelined RISC-V core in Verilog. Fetch → Decode →
Execute → Memory → Writeback, with data forwarding, load-use stalling, and
branch/jump flushing.

## Verified working

Simulated with Icarus Verilog against a hand-written test program
(`rtl/program.hex`) covering:
- back-to-back data dependency (needs forwarding)
- a load immediately followed by a dependent instruction (needs a stall)
- a taken branch (needs pipeline flush)
- a store followed by a load from the same address

All results matched expected values exactly (see `tb/tb_riscv_pipeline.v`).

## Structure

- `rtl/` — all design files
- `tb/` — testbench
- `rtl/program.hex` — sample program loaded by `instr_mem.v` via `$readmemh`

