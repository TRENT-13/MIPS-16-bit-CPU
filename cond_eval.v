module cond_eval(
input [3:0] opcode,
input [31:0] rs1_data,
input [31:0] rs2_data,
output wire branch
);

wire [31:0] rs1_comp, rs2_comp;

parameter BEQ = 4'b1000;  // =
parameter BNE = 4'b1010;  // !=

parameter BLT = 4'b0010;  // <
parameter BGE = 4'b0011;  // >=

parameter BGTZ = 4'b1100; // > 0
parameter BGT = 4'b1110;  // >

twos_complement twos_comp_rs1(.data(rs1_data), .two_complement(rs1_comp));
twos_complement twos_comp_rs2(.data(rs2_data), .two_complement(rs2_comp));

wire signed [31:0] difference = rs1_comp - rs2_comp;

assign branch = (opcode == BEQ && rs1_comp == rs2_comp)
             || (opcode == BNE && rs1_comp != rs2_comp)
             || (opcode == BLT && difference < 0)
             || (opcode == BGE && difference >= 0)
             || (opcode == BGTZ && rs1_data > 0)
             || (opcode == BGT && rs1_comp > rs2_comp);
endmodule

module twos_complement (
input [31:0] data,
output [31:0] two_complement
);

assign two_complement = ~data + 1'b1;

endmodule
