module pc_register (
    input clk,
    input reset,
    input pc_write_enable,      // held low by hazard unit during a stall
    input [31:0] pc_next,
    output reg [31:0] pc_current
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;
        else if (pc_write_enable)
            pc_current <= pc_next;
        // else: hold current value (stall)
    end

endmodule
