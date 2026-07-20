module hazard_detection_unit (
    input MemRead_EX,           // instruction currently in Execute is a load
    input [4:0] rd_EX,           // its destination register
    input [4:0] rs1_ID, rs2_ID,  // registers needed by instruction currently in Decode

    output stall   // when 1: freeze PC + IF/ID, bubble ID/EX
);
    // Load-use hazard: the load's result isn't ready until it exits Memory,
    // but the very next instruction needs it one cycle too early (in Execute).
    // One stall cycle lets the load reach EX/MEM, after which the forwarding
    // unit can supply the value normally.
    assign stall = MemRead_EX && (rd_EX != 5'b0) &&
                   ((rd_EX == rs1_ID) || (rd_EX == rs2_ID));

endmodule
