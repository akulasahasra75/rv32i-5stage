# RV32I 5-Stage Pipelined Processor

A complete RV32I (37-instruction) pipelined RISC-V core, built from scratch
in Verilog. Fetch → Decode → Execute → Memory → Writeback, with data
forwarding, load-use stalling, and branch/jump pipeline flushing.

## Status

- All 37 RV32I base integer instructions decoded and executed (R/I/S/B/U/J
  formats, full opcode/funct3/funct7 mapping)
- All 5 pipeline stages wired, all 4 pipeline registers implemented
- Data hazards resolved via forwarding (EX/MEM and MEM/WB, correct priority)
- Load-use hazard resolved via a dedicated stall (hazard detection unit)
- Control hazards resolved via a 2-register flush (IF/ID and ID/EX) on
  taken branches and jumps
- Verified in Vivado Behavioral Simulation: register and memory values
  matched hand-computed expected results for a program covering back-to-back
  data dependency, a load-use dependency, a store/load round-trip, and a
  taken branch

## Structure

- `rtl/` — all design files
- `tb/` — testbench
- `rtl/program.hex` — test program loaded by `instr_mem.v` via `$readmemh`

## Running in Vivado

1. Create an RTL project pointed at this repo.
2. Add every `.v` file in `rtl/` (except the testbench) as a **Design
   Source**.
3. Add `tb/tb_riscv_pipeline.v` and `rtl/program.hex` as **Simulation
   Sources**.
4. Set `tb_riscv_pipeline` as the simulation top.
5. Run Behavioral Simulation. Expected Tcl console output:
   ```
   x1 = 5, x2 = 10, x3 = 15, x4 = 15, x5 = 20, x6 = 0, x7 = 7
   mem[0..3] as word = 15
   ```

## Design notes

- `ALUSrc1` is 2 bits (`rs1` / `pc` / hardwired zero) — AUIPC/JAL use PC as
  the ALU's first operand, LUI reuses the ALU with a zero operand.
- `is_jalr` is a dedicated control bit latched through every pipeline
  register, not inferred from funct3.
- Branch/jump misprediction flushes **two** pipeline registers (IF/ID and
  ID/EX), not one — both hold instructions fetched under the wrong PC
  assumption by the time Execute resolves the branch.
- Forwarding priority: EX/MEM before MEM/WB (more recent result wins).
- `data_mem` is byte-addressable; `instr_mem` is word-addressable — loads/
  stores need byte/half/word granularity, instruction fetch is always
  word-aligned.

## Known scope limits

- Only a subset of instructions have individual simulation traces so far
  (arithmetic, immediates, load/store, one branch type). The decode/control
  logic for all 37 is built from a verified encoding table, but broader
  per-instruction simulation coverage is a natural next step.
- No branch prediction — every taken branch/jump costs a fixed pipeline
  flush.
- No exception/interrupt handling (ECALL/EBREAK/FENCE out of scope).
