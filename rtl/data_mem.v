module data_mem (
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input MemRead, MemWrite,
    input [2:0] funct3,
    output reg [31:0] read_data
);
    reg [7:0] mem [0:1023];   // 1KB byte-addressable data memory

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 8'b0;
    end

    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{mem[address][7]}}, mem[address]};                            // LB
                3'b001: read_data = {{16{mem[address+1][7]}}, mem[address+1], mem[address]};          // LH
                3'b010: read_data = {mem[address+3], mem[address+2], mem[address+1], mem[address]};   // LW
                3'b100: read_data = {24'b0, mem[address]};                                             // LBU
                3'b101: read_data = {16'b0, mem[address+1], mem[address]};                             // LHU
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: mem[address] <= write_data[7:0];                                     // SB
                3'b001: begin
                    mem[address]   <= write_data[7:0];
                    mem[address+1] <= write_data[15:8];
                end // SH
                3'b010: begin
                    mem[address]   <= write_data[7:0];
                    mem[address+1] <= write_data[15:8];
                    mem[address+2] <= write_data[23:16];
                    mem[address+3] <= write_data[31:24];
                end // SW
            endcase
        end
    end
endmodule
