module execute_stage (
    input  [31:0] rs1_data, rs2_data,     // raw values from ID/EX register
    input  [31:0] imm, pc,
    input  [2:0] funct3,
    input  [6:0] funct7,
    input  [1:0] ALUSrc1,                   // 00=rs1, 01=pc, 10=zero
    input  ALUSrc2,                          // 0=rs2(forwarded), 1=imm
    input  [1:0] ALUOp,

    // forwarding
    input  [1:0] forwardA, forwardB,        // 00=none, 10=EX/MEM, 01=MEM/WB
    input  [31:0] fwd_exmem_data,            // EX/MEM.alu_result
    input  [31:0] fwd_wb_data,               // MEM/WB write_data

    output [31:0] alu_result,
    output [31:0] rs2_data_fwd,               // forwarded store data, latched into EX/MEM
    output branch_taken,
    output [31:0] branch_target,
    output [31:0] jalr_target
);

    // Resolve forwarded source register values first
    reg [31:0] rs1_fwd;
    always @(*) begin
        case (forwardA)
            2'b10:   rs1_fwd = fwd_exmem_data;
            2'b01:   rs1_fwd = fwd_wb_data;
            default: rs1_fwd = rs1_data;
        endcase
    end

    reg [31:0] rs2_fwd_internal;
    always @(*) begin
        case (forwardB)
            2'b10:   rs2_fwd_internal = fwd_exmem_data;
            2'b01:   rs2_fwd_internal = fwd_wb_data;
            default: rs2_fwd_internal = rs2_data;
        endcase
    end
    assign rs2_data_fwd = rs2_fwd_internal;

    // ALU operand selection
    wire [31:0] operand1 = (ALUSrc1 == 2'b01) ? pc :
                            (ALUSrc1 == 2'b10) ? 32'b0 : rs1_fwd;
    wire [31:0] operand2 = ALUSrc2 ? imm : rs2_fwd_internal;

    wire [3:0] alu_op_final;
    wire zero, lt_signed, lt_unsigned;

    alu_control ALUCTRL (
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7),
        .alu_operation(alu_op_final)
    );

    alu ALU (
        .operand1(operand1), .operand2(operand2),
        .alu_operation(alu_op_final),
        .result(alu_result), .zero(zero),
        .lt_signed(lt_signed), .lt_unsigned(lt_unsigned)
    );

    branch_decision BRANCHDEC (
        .funct3(funct3), .zero(zero),
        .lt_signed(lt_signed), .lt_unsigned(lt_unsigned),
        .branch_taken(branch_taken)
    );

    assign branch_target = pc + imm;
    assign jalr_target    = (rs1_fwd + imm) & ~32'b1;

endmodule
