module decode_stage (
    input clk,
    input [31:0] instruction,
    input [31:0] pc,

    // write-back port, driven by the WB stage
    input        wb_regwrite,
    input [4:0]  wb_rd,
    input [31:0] wb_write_data,

    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [31:0] imm,
    output [4:0]  rs1_out,
    output [4:0]  rs2_out,
    output [4:0]  rd_out,
    output [2:0]  funct3_out,
    output [6:0]  funct7_out,
    output [31:0] pc_out,

    output RegWrite, MemRead, MemWrite, MemtoReg,
    output [1:0] ALUSrc1,
    output ALUSrc2, Branch, Jump, is_jalr,
    output [1:0] ALUOp
);

    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rs1    = instruction[19:15];
    wire [4:0] rs2    = instruction[24:20];
    wire [4:0] rd     = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    assign rs1_out    = rs1;
    assign rs2_out    = rs2;
    assign rd_out     = rd;
    assign funct3_out = funct3;
    assign funct7_out = funct7;
    assign pc_out      = pc;

    control_unit CU (
        .opcode(opcode),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite),
        .MemtoReg(MemtoReg), .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2),
        .Branch(Branch), .Jump(Jump), .is_jalr(is_jalr), .ALUOp(ALUOp)
    );

    imm_generator IMMGEN (
        .inst(instruction),
        .imm(imm)
    );

    register_file REGFILE (
        .clk(clk),
        .regwrite_enable(wb_regwrite),
        .rs1(rs1), .rs2(rs2), .rd(wb_rd),
        .write_data(wb_write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

endmodule
