module pc_next_mux (
    input  [31:0] pc_current,
    input  [31:0] branch_target,   // pc_EX + imm_EX (computed in execute_stage)
    input  [31:0] jalr_target,     // (rs1_EX + imm_EX) & ~1 (computed in execute_stage)
    input  is_jalr,                 // dedicated control bit, latched through pipeline (NOT inferred from funct3)
    input  redirect,                 // Jump_EX || (Branch_EX && branch_taken_EX)
    output reg [31:0] pc_next
);

    always @(*) begin
        if (redirect && is_jalr)
            pc_next = jalr_target;
        else if (redirect)
            pc_next = branch_target;
        else
            pc_next = pc_current + 32'd4;
    end

endmodule
