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

## Running in Vivado

1. Create a new RTL project, add every file in `rtl/` as a design source and
   `tb/tb_riscv_pipeline.v` as a simulation source.
2. Set `program.hex` as available at simulation time (Vivado working directory,
   or update the path in `instr_mem.v`'s `$readmemh` call).
3. Run Behavioral Simulation. Set `riscv_pipeline` as top for synthesis-only runs.

## Design notes worth knowing cold (interview-relevant)

- **ALUSrc1 is 2 bits** (`00`=rs1, `01`=pc, `10`=hardwired zero) because AUIPC/JAL
  use PC as the ALU's first operand, and LUI reuses the ALU with a zero operand
  rather than a separate bypass path.
- **`is_jalr` is a dedicated control bit**, latched through every pipeline
  register — not inferred from funct3. JALR and branches share funct3=000
  territory in places; inferring from funct3 is fragile.
- **Two pipeline registers are flushed on a taken branch/jump**, not one:
  by the time Execute resolves the branch, both IF/ID and ID/EX hold
  instructions fetched under the wrong PC assumption.
- **Forwarding priority: EX/MEM before MEM/WB** — the more recent result wins
  if both would apply.
- **Load-use hazard is a stall, not just forwarding** — a load's data isn't
  valid until it leaves Memory, one cycle later than every other instruction's
  result, so forwarding alone can't fix a load immediately followed by a
  dependent instruction.
- **`data_mem` is byte-addressable**; `instr_mem` is word-addressable
  (drops the 2 LSBs of the address). They are deliberately different because
  loads/stores need byte/half/word granularity while instruction fetch is
  always word-aligned.
