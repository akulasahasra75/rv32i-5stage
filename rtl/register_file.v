module register_file (
    input clk,
    input regwrite_enable,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);

    reg [31:0] registers [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (regwrite_enable && rd != 5'b0)
            registers[rd] <= write_data;
    end

    // Same-cycle write-then-read: if WB is writing rd this cycle and Decode
    // reads that same register, forward write_data directly instead of the
    // stale value still sitting in the array (array updates one cycle late).
    assign rs1_data = (rs1 == 5'b0) ? 32'b0 :
                       (regwrite_enable && rd == rs1) ? write_data : registers[rs1];

    assign rs2_data = (rs2 == 5'b0) ? 32'b0 :
                       (regwrite_enable && rd == rs2) ? write_data : registers[rs2];

endmodule
