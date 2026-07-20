module ex_mem_register (
    input clk, reset,
    input [31:0] alu_result_in, rs2_data_in, pc_plus4_in,
    input [4:0] rd_in,
    input [2:0] funct3_in,     // FIX: needed by data_mem for width/sign, must travel with this instruction
    input RegWrite_in, MemRead_in, MemWrite_in, MemtoReg_in, Jump_in,

    output reg [31:0] alu_result_out, rs2_data_out, pc_plus4_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,
    output reg RegWrite_out, MemRead_out, MemWrite_out, MemtoReg_out, Jump_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWrite_out <= 0; MemRead_out <= 0; MemWrite_out <= 0;
            MemtoReg_out <= 0; Jump_out <= 0; rd_out <= 0; funct3_out <= 0;
            alu_result_out <= 0; rs2_data_out <= 0; pc_plus4_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in; MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in; MemtoReg_out <= MemtoReg_in;
            Jump_out <= Jump_in; rd_out <= rd_in; funct3_out <= funct3_in;
            alu_result_out <= alu_result_in; rs2_data_out <= rs2_data_in;
            pc_plus4_out <= pc_plus4_in;
        end
    end
endmodule
