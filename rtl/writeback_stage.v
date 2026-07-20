module writeback_stage (
    input [31:0] alu_result, mem_data, pc_plus4,
    input MemtoReg, Jump,
    output [31:0] write_data
);
    assign write_data = Jump ? pc_plus4 :
                         MemtoReg ? mem_data : alu_result;
endmodule
