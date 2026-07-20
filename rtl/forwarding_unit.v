module forwarding_unit (
    input [4:0] rs1_EX, rs2_EX,          // register addresses of instruction currently in Execute
    input [4:0] rd_MEM,                    // destination reg of instruction currently in Memory (EX/MEM)
    input RegWrite_MEM,
    input [4:0] rd_WB,                     // destination reg of instruction currently in Writeback (MEM/WB)
    input RegWrite_WB,

    output reg [1:0] forwardA,             // 00=no forward, 10=from EX/MEM, 01=from MEM/WB
    output reg [1:0] forwardB
);

    // EX/MEM hazard takes priority over MEM/WB (more recent result)
    always @(*) begin
        forwardA = 2'b00;
        if (RegWrite_MEM && (rd_MEM != 5'b0) && (rd_MEM == rs1_EX))
            forwardA = 2'b10;
        else if (RegWrite_WB && (rd_WB != 5'b0) && (rd_WB == rs1_EX))
            forwardA = 2'b01;
    end

    always @(*) begin
        forwardB = 2'b00;
        if (RegWrite_MEM && (rd_MEM != 5'b0) && (rd_MEM == rs2_EX))
            forwardB = 2'b10;
        else if (RegWrite_WB && (rd_WB != 5'b0) && (rd_WB == rs2_EX))
            forwardB = 2'b01;
    end

endmodule
