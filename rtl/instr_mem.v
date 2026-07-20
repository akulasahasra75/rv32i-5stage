module instr_mem (
    input  [31:0] address,
    output [31:0] instruction
);

    reg [31:0] mem [0:255];   // 256 words = 1KB instruction memory

    initial begin
        // Loaded externally via $readmemh in the testbench, or initialize here for quick tests
        $readmemh("program.hex", mem);
    end

    assign instruction = mem[address[9:2]];   // drop 2 LSBs (word alignment), 8 bits index 256 words

endmodule
