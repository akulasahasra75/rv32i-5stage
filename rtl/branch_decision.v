module branch_decision (
    input [2:0] funct3,
    input zero,
    input lt_signed,
    input lt_unsigned,
    output reg branch_taken
);

    always @(*) begin
        case (funct3)
            3'b000: branch_taken = zero;          // beq
            3'b001: branch_taken = ~zero;          // bne
            3'b100: branch_taken = lt_signed;      // blt
            3'b101: branch_taken = ~lt_signed;      // bge
            3'b110: branch_taken = lt_unsigned;     // bltu
            3'b111: branch_taken = ~lt_unsigned;    // bgeu
            default: branch_taken = 1'b0;
        endcase
    end

endmodule
