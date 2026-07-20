module id_ex_register (
    input clk, reset,
    input flush,                              // squash to bubble (control hazard) or stall (load-use)

    input [31:0] rs1_data_in, rs2_data_in, imm_in, pc_in,
    input [4:0]  rs1_in, rs2_in, rd_in,
    input [2:0]  funct3_in,
    input [6:0]  funct7_in,
    input RegWrite_in, MemRead_in, MemWrite_in, MemtoReg_in,
    input [1:0] ALUSrc1_in,
    input ALUSrc2_in, Branch_in, Jump_in, is_jalr_in,
    input [1:0] ALUOp_in,

    output reg [31:0] rs1_data_out, rs2_data_out, imm_out, pc_out,
    output reg [4:0]  rs1_out, rs2_out, rd_out,
    output reg [2:0]  funct3_out,
    output reg [6:0]  funct7_out,
    output reg RegWrite_out, MemRead_out, MemWrite_out, MemtoReg_out,
    output reg [1:0] ALUSrc1_out,
    output reg ALUSrc2_out, Branch_out, Jump_out, is_jalr_out,
    output reg [1:0] ALUOp_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            RegWrite_out <= 0; MemRead_out <= 0; MemWrite_out <= 0;
            MemtoReg_out <= 0; Branch_out <= 0; Jump_out <= 0; is_jalr_out <= 0;
            ALUSrc1_out <= 0; ALUSrc2_out <= 0; ALUOp_out <= 0;
            rs1_out <= 0; rs2_out <= 0; rd_out <= 0;
            rs1_data_out <= 0; rs2_data_out <= 0; imm_out <= 0; pc_out <= 0;
            funct3_out <= 0; funct7_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in; MemRead_out <= MemRead_in; MemWrite_out <= MemWrite_in;
            MemtoReg_out <= MemtoReg_in; Branch_out <= Branch_in; Jump_out <= Jump_in;
            is_jalr_out <= is_jalr_in;
            ALUSrc1_out <= ALUSrc1_in; ALUSrc2_out <= ALUSrc2_in; ALUOp_out <= ALUOp_in;
            rs1_out <= rs1_in; rs2_out <= rs2_in; rd_out <= rd_in;
            rs1_data_out <= rs1_data_in; rs2_data_out <= rs2_data_in;
            imm_out <= imm_in; pc_out <= pc_in;
            funct3_out <= funct3_in; funct7_out <= funct7_in;
        end
    end

endmodule
