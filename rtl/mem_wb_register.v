module mem_wb_register (
    input clk, reset,
    input [31:0] alu_result_in, mem_data_in, pc_plus4_in,
    input [4:0] rd_in,
    input RegWrite_in, MemtoReg_in, Jump_in,

    output reg [31:0] alu_result_out, mem_data_out, pc_plus4_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out, MemtoReg_out, Jump_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWrite_out <= 0; MemtoReg_out <= 0; Jump_out <= 0; rd_out <= 0;
            alu_result_out <= 0; mem_data_out <= 0; pc_plus4_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in; MemtoReg_out <= MemtoReg_in; Jump_out <= Jump_in;
            rd_out <= rd_in;
            alu_result_out <= alu_result_in; mem_data_out <= mem_data_in; pc_plus4_out <= pc_plus4_in;
        end
    end
endmodule
