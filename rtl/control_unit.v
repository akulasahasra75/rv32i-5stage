module control_unit (
    input  [6:0] opcode,
    output reg RegWrite, MemRead, MemWrite, MemtoReg,
    output reg [1:0] ALUSrc1,   // 00=rs1, 01=pc, 10=zero
    output reg ALUSrc2,          // 0=rs2, 1=imm
    output reg Branch, Jump, is_jalr,
    output reg [1:0] ALUOp       // 00=ADD, 01=SUB, 10=FUNC
);

    always @(*) begin
        // safe defaults every branch, avoids latches
        RegWrite = 0; MemRead = 0; MemWrite = 0; MemtoReg = 0;
        ALUSrc1 = 2'b00; ALUSrc2 = 0;
        Branch = 0; Jump = 0; is_jalr = 0;
        ALUOp = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite = 1; ALUSrc1 = 2'b00; ALUSrc2 = 0; ALUOp = 2'b10;
            end
            7'b0010011: begin // I-type ALU
                RegWrite = 1; ALUSrc1 = 2'b00; ALUSrc2 = 1; ALUOp = 2'b10;
            end
            7'b0000011: begin // Load
                RegWrite = 1; MemRead = 1; MemtoReg = 1;
                ALUSrc1 = 2'b00; ALUSrc2 = 1; ALUOp = 2'b00;
            end
            7'b0100011: begin // Store
                MemWrite = 1; ALUSrc1 = 2'b00; ALUSrc2 = 1; ALUOp = 2'b00;
            end
            7'b1100011: begin // Branch
                Branch = 1; ALUSrc1 = 2'b00; ALUSrc2 = 0; ALUOp = 2'b01;
            end
            7'b0110111: begin // LUI
                RegWrite = 1; ALUSrc1 = 2'b10; ALUSrc2 = 1; ALUOp = 2'b00;
            end
            7'b0010111: begin // AUIPC
                RegWrite = 1; ALUSrc1 = 2'b01; ALUSrc2 = 1; ALUOp = 2'b00;
            end
            7'b1101111: begin // JAL
                RegWrite = 1; Jump = 1; ALUSrc1 = 2'b01; ALUSrc2 = 1; ALUOp = 2'b00;
            end
            7'b1100111: begin // JALR
                RegWrite = 1; Jump = 1; is_jalr = 1;
                ALUSrc1 = 2'b00; ALUSrc2 = 1; ALUOp = 2'b00;
            end
            default: ; // NOP / unsupported opcode falls through to safe defaults above
        endcase
    end

endmodule
