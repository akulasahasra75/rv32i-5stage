`timescale 1ns/1ps

module tb_riscv_pipeline;

    reg clk = 0;
    reg reset = 1;

    riscv_pipeline DUT (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_riscv_pipeline);

        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;

        repeat (30) @(posedge clk);

        $display("---- Final register values ----");
        $display("x1 = %0d (expect 5)",  DUT.DECODE.REGFILE.registers[1]);
        $display("x2 = %0d (expect 10)", DUT.DECODE.REGFILE.registers[2]);
        $display("x3 = %0d (expect 15)", DUT.DECODE.REGFILE.registers[3]);
        $display("x4 = %0d (expect 15)", DUT.DECODE.REGFILE.registers[4]);
        $display("x5 = %0d (expect 20)", DUT.DECODE.REGFILE.registers[5]);
        $display("x6 = %0d (expect 0, must be skipped by branch)", DUT.DECODE.REGFILE.registers[6]);
        $display("x7 = %0d (expect 7)",  DUT.DECODE.REGFILE.registers[7]);
        $display("mem[0..3] as word = %0d (expect 15)",
                  {DUT.DMEM.mem[3], DUT.DMEM.mem[2], DUT.DMEM.mem[1], DUT.DMEM.mem[0]});

        $finish;
    end

endmodule
