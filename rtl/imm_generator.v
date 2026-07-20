module imm_generator (
    input  [31:0] inst,
    output reg [31:0] imm
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I-type ALU, Load, JALR
                imm = {{20{inst[31]}}, inst[31:20]};

            7'b0100011: // S-type (Store)
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            7'b1100011: // B-type (Branch)
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

            7'b0110111, 7'b0010111: // U-type (LUI, AUIPC)
                imm = {inst[31:12], 12'b0};

            7'b1101111: // J-type (JAL)
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

            default:
                imm = 32'b0; // R-type and others don't use an immediate
        endcase
    end

endmodule
