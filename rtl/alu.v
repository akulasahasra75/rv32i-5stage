module alu (
    input  [31:0] operand1,
    input  [31:0] operand2,
    input  [3:0]  alu_operation,
    output reg [31:0] result,
    output zero,
    output lt_signed,
    output lt_unsigned
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
        case (alu_operation)
            ADD:  result = operand1 + operand2;
            SUB:  result = operand1 - operand2;
            AND:  result = operand1 & operand2;
            OR:   result = operand1 | operand2;
            XOR:  result = operand1 ^ operand2;
            SLL:  result = operand1 << operand2[4:0];
            SRL:  result = operand1 >> operand2[4:0];
            SRA:  result = $signed(operand1) >>> operand2[4:0];
            SLT:  result = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0;
            SLTU: result = (operand1 < operand2) ? 32'b1 : 32'b0;
            default: result = 32'b0;
        endcase
    end

    assign zero        = (result == 32'b0);
    assign lt_signed    = ($signed(operand1) < $signed(operand2));
    assign lt_unsigned  = (operand1 < operand2);

endmodule
