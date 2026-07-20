module riscv_pipeline (
    input clk,
    input reset
);

    // ===================== Fetch =====================
    wire [31:0] pc_current, pc_next, instruction_IF;
    wire pc_write_enable;
    wire stall;
    wire redirect;

    pc_register PC (
        .clk(clk), .reset(reset),
        .pc_write_enable(pc_write_enable),
        .pc_next(pc_next), .pc_current(pc_current)
    );

    instr_mem IMEM (
        .address(pc_current), .instruction(instruction_IF)
    );

    // ===================== IF/ID =====================
    wire [31:0] instruction_ID, pc_ID;

    if_id_register IFID (
        .clk(clk), .reset(reset),
        .stall(stall), .flush(redirect),
        .instruction_in(instruction_IF), .pc_in(pc_current),
        .instruction_out(instruction_ID), .pc_out(pc_ID)
    );

    // ===================== Decode =====================
    wire [31:0] rs1_data_ID, rs2_data_ID, imm_ID;
    wire [4:0]  rs1_ID, rs2_ID, rd_ID;
    wire [2:0]  funct3_ID;
    wire [6:0]  funct7_ID;
    wire RegWrite_ID, MemRead_ID, MemWrite_ID, MemtoReg_ID, Branch_ID, Jump_ID, is_jalr_ID;
    wire [1:0] ALUSrc1_ID, ALUOp_ID;
    wire ALUSrc2_ID;

    wire RegWrite_WB_wire;
    wire [4:0] rd_WB_wire;
    wire [31:0] write_data_WB_wire;

    decode_stage DECODE (
        .clk(clk), .instruction(instruction_ID), .pc(pc_ID),
        .wb_regwrite(RegWrite_WB_wire), .wb_rd(rd_WB_wire), .wb_write_data(write_data_WB_wire),
        .rs1_data(rs1_data_ID), .rs2_data(rs2_data_ID), .imm(imm_ID),
        .rs1_out(rs1_ID), .rs2_out(rs2_ID), .rd_out(rd_ID),
        .funct3_out(funct3_ID), .funct7_out(funct7_ID),
        .RegWrite(RegWrite_ID), .MemRead(MemRead_ID), .MemWrite(MemWrite_ID),
        .MemtoReg(MemtoReg_ID), .ALUSrc1(ALUSrc1_ID), .ALUSrc2(ALUSrc2_ID),
        .Branch(Branch_ID), .Jump(Jump_ID), .is_jalr(is_jalr_ID), .ALUOp(ALUOp_ID)
    );

    // ===================== Hazard Detection =====================
    wire MemRead_EX_wire;
    wire [4:0] rd_EX_wire;

    hazard_detection_unit HAZARD (
        .MemRead_EX(MemRead_EX_wire), .rd_EX(rd_EX_wire),
        .rs1_ID(rs1_ID), .rs2_ID(rs2_ID),
        .stall(stall)
    );

    assign pc_write_enable = ~stall;
    wire id_ex_flush = stall || redirect;

    // ===================== ID/EX =====================
    wire [31:0] rs1_data_EX, rs2_data_EX, imm_EX, pc_EX;
    wire [4:0]  rs1_EX, rs2_EX, rd_EX;
    wire [2:0]  funct3_EX;
    wire [6:0]  funct7_EX;
    wire RegWrite_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, Branch_EX, Jump_EX, is_jalr_EX;
    wire [1:0] ALUSrc1_EX, ALUOp_EX;
    wire ALUSrc2_EX;

    assign MemRead_EX_wire = MemRead_EX;
    assign rd_EX_wire = rd_EX;

    id_ex_register IDEX (
        .clk(clk), .reset(reset), .flush(id_ex_flush),
        .rs1_data_in(rs1_data_ID), .rs2_data_in(rs2_data_ID),
        .imm_in(imm_ID), .pc_in(pc_ID),
        .rs1_in(rs1_ID), .rs2_in(rs2_ID), .rd_in(rd_ID),
        .funct3_in(funct3_ID), .funct7_in(funct7_ID),
        .RegWrite_in(RegWrite_ID), .MemRead_in(MemRead_ID), .MemWrite_in(MemWrite_ID),
        .MemtoReg_in(MemtoReg_ID), .ALUSrc1_in(ALUSrc1_ID), .ALUSrc2_in(ALUSrc2_ID),
        .Branch_in(Branch_ID), .Jump_in(Jump_ID), .is_jalr_in(is_jalr_ID), .ALUOp_in(ALUOp_ID),

        .rs1_data_out(rs1_data_EX), .rs2_data_out(rs2_data_EX),
        .imm_out(imm_EX), .pc_out(pc_EX),
        .rs1_out(rs1_EX), .rs2_out(rs2_EX), .rd_out(rd_EX),
        .funct3_out(funct3_EX), .funct7_out(funct7_EX),
        .RegWrite_out(RegWrite_EX), .MemRead_out(MemRead_EX), .MemWrite_out(MemWrite_EX),
        .MemtoReg_out(MemtoReg_EX), .ALUSrc1_out(ALUSrc1_EX), .ALUSrc2_out(ALUSrc2_EX),
        .Branch_out(Branch_EX), .Jump_out(Jump_EX), .is_jalr_out(is_jalr_EX), .ALUOp_out(ALUOp_EX)
    );

    // ===================== Forwarding =====================
    wire [1:0] forwardA, forwardB;
    wire RegWrite_MEM_wire;
    wire [4:0] rd_MEM_wire;
    wire [31:0] alu_result_MEM_wire;

    forwarding_unit FWD (
        .rs1_EX(rs1_EX), .rs2_EX(rs2_EX),
        .rd_MEM(rd_MEM_wire), .RegWrite_MEM(RegWrite_MEM_wire),
        .rd_WB(rd_WB_wire), .RegWrite_WB(RegWrite_WB_wire),
        .forwardA(forwardA), .forwardB(forwardB)
    );

    // ===================== Execute =====================
    wire [31:0] alu_result_EX, rs2_data_fwd_EX, branch_target_EX, jalr_target_EX;
    wire branch_taken_EX;
    wire [31:0] pc_plus4_EX = pc_EX + 32'd4;

    execute_stage EXEC (
        .rs1_data(rs1_data_EX), .rs2_data(rs2_data_EX), .imm(imm_EX), .pc(pc_EX),
        .funct3(funct3_EX), .funct7(funct7_EX),
        .ALUSrc1(ALUSrc1_EX), .ALUSrc2(ALUSrc2_EX), .ALUOp(ALUOp_EX),
        .forwardA(forwardA), .forwardB(forwardB),
        .fwd_exmem_data(alu_result_MEM_wire), .fwd_wb_data(write_data_WB_wire),
        .alu_result(alu_result_EX), .rs2_data_fwd(rs2_data_fwd_EX),
        .branch_taken(branch_taken_EX),
        .branch_target(branch_target_EX), .jalr_target(jalr_target_EX)
    );

    assign redirect = Jump_EX || (Branch_EX && branch_taken_EX);

    pc_next_mux PCMUX (
        .pc_current(pc_current),
        .branch_target(branch_target_EX), .jalr_target(jalr_target_EX),
        .is_jalr(is_jalr_EX), .redirect(redirect),
        .pc_next(pc_next)
    );

    // ===================== EX/MEM =====================
    wire [31:0] alu_result_MEM, rs2_data_MEM, pc_plus4_MEM;
    wire [4:0] rd_MEM;
    wire [2:0] funct3_MEM;
    wire RegWrite_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM, Jump_MEM;

    assign alu_result_MEM_wire = alu_result_MEM;
    assign RegWrite_MEM_wire = RegWrite_MEM;
    assign rd_MEM_wire = rd_MEM;

    ex_mem_register EXMEM (
        .clk(clk), .reset(reset),
        .alu_result_in(alu_result_EX), .rs2_data_in(rs2_data_fwd_EX), .pc_plus4_in(pc_plus4_EX),
        .rd_in(rd_EX), .funct3_in(funct3_EX),
        .RegWrite_in(RegWrite_EX), .MemRead_in(MemRead_EX), .MemWrite_in(MemWrite_EX),
        .MemtoReg_in(MemtoReg_EX), .Jump_in(Jump_EX),

        .alu_result_out(alu_result_MEM), .rs2_data_out(rs2_data_MEM), .pc_plus4_out(pc_plus4_MEM),
        .rd_out(rd_MEM), .funct3_out(funct3_MEM),
        .RegWrite_out(RegWrite_MEM), .MemRead_out(MemRead_MEM), .MemWrite_out(MemWrite_MEM),
        .MemtoReg_out(MemtoReg_MEM), .Jump_out(Jump_MEM)
    );

    // ===================== Memory =====================
    wire [31:0] mem_data_MEM;

    data_mem DMEM (
        .clk(clk), .address(alu_result_MEM), .write_data(rs2_data_MEM),
        .MemRead(MemRead_MEM), .MemWrite(MemWrite_MEM),
        .funct3(funct3_MEM),
        .read_data(mem_data_MEM)
    );

    // ===================== MEM/WB =====================
    wire [31:0] alu_result_WB, mem_data_WB, pc_plus4_WB;
    wire MemtoReg_WB, Jump_WB;

    mem_wb_register MEMWB (
        .clk(clk), .reset(reset),
        .alu_result_in(alu_result_MEM), .mem_data_in(mem_data_MEM), .pc_plus4_in(pc_plus4_MEM),
        .rd_in(rd_MEM),
        .RegWrite_in(RegWrite_MEM), .MemtoReg_in(MemtoReg_MEM), .Jump_in(Jump_MEM),

        .alu_result_out(alu_result_WB), .mem_data_out(mem_data_WB), .pc_plus4_out(pc_plus4_WB),
        .rd_out(rd_WB_wire),
        .RegWrite_out(RegWrite_WB_wire), .MemtoReg_out(MemtoReg_WB), .Jump_out(Jump_WB)
    );

    // ===================== Writeback =====================
    writeback_stage WB (
        .alu_result(alu_result_WB), .mem_data(mem_data_WB), .pc_plus4(pc_plus4_WB),
        .MemtoReg(MemtoReg_WB), .Jump(Jump_WB),
        .write_data(write_data_WB_wire)
    );

endmodule
