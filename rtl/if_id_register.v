module if_id_register (
    input clk,
    input reset,
    input stall,                  // hold current contents (load-use hazard)
    input flush,                  // squash to NOP (control hazard)
    input [31:0] instruction_in,
    input [31:0] pc_in,

    output reg [31:0] instruction_out,
    output reg [31:0] pc_out
);

    localparam NOP = 32'h00000013;   // addi x0, x0, 0

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out <= NOP;
            pc_out <= 32'b0;
        end else if (flush) begin
            instruction_out <= NOP;
            pc_out <= 32'b0;
        end else if (stall) begin
            // hold current values, do nothing
        end else begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
        end
    end

endmodule
