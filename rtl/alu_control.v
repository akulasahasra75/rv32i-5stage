module alu_control (
    input  [1:0] ALUOp,      // 00=ADD, 01=SUB, 10=FUNC
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] alu_operation
);

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam SLL  = 4'b0101;
    localparam SRL  = 4'b0110;
    localparam SRA  = 4'b0111;
    localparam SLT  = 4'b1000;
    localparam SLTU = 4'b1001;

    always @(*) begin
        case (ALUOp)
            2'b00: alu_operation = ADD;
            2'b01: alu_operation = SUB;
            2'b10: begin
                case (funct3)
                    3'b000: alu_operation = (funct7[5]) ? SUB : ADD;
                    3'b001: alu_operation = SLL;
                    3'b010: alu_operation = SLT;
                    3'b011: alu_operation = SLTU;
                    3'b100: alu_operation = XOR;
                    3'b101: alu_operation = (funct7[5]) ? SRA : SRL;
                    3'b110: alu_operation = OR;
                    3'b111: alu_operation = AND;
                endcase
            end
            default: alu_operation = ADD;
        endcase
    end

endmodule
