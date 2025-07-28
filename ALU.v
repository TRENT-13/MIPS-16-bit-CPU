module ALU
(
    input [31:0] srcA, srcB,
    input [3:0] af,
    input i,
    output reg [31:0] Alures,
    output reg zero, neg, ovfalu
);

wire [34:0] areswf;

ALU_Result alu_res_inst (
    .a(srcA),
    .b(srcB),
    .af(af),
    .i(i),
    .result(areswf)
);

always @(*) begin
    ovfalu = areswf[34];
    neg = areswf[33];
    zero = areswf[32];
    Alures = areswf[31:0];
end

endmodule


module ALU_Result
(
    input [31:0] a, b,
    input [3:0] af,
    input i,
    output reg [34:0] result
);

wire comp;
reg [31:0] alu_op_result;
wire [32:0] tmp;

Compare_TwoC compare_twoc_inst (
    .a(a),
    .b(b),
    .comp(comp)
);

assign tmp = (af == 2 || af == 3) ? a - b : a + b;

always @(*) begin
    case (af)
        4'd0: begin 
            alu_op_result = a + b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = comp;
            result[34] = (a[31] & b[31]) ^ tmp[32];
        end
        4'd1: begin 
            alu_op_result = a + b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0);
            result[34] = 0; 
        end
        4'd2: begin 
            alu_op_result = a - b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = comp; 
            result[34] = (a[31] & b[31]) ^ tmp[32];
        end
        4'd3: begin 
            alu_op_result = a - b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0); 
            result[34] = 0;
        end
        4'd4: begin 
            alu_op_result = a & b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0); 
            result[34] = 0; 
        end
        4'd5: begin 
            alu_op_result = a | b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0); 
            result[34] = 0; 
        end
        4'd6: begin 
            alu_op_result = a ^ b; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0); 
            result[34] = 0; 
        end
        4'd7: begin 
            if (i) 
                alu_op_result = ~(a | b); 
            else 
                alu_op_result = {b[15:0], 16'b0000000000000000}; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0); 
            result[34] = 0; 
        end
        4'd10: begin 
            alu_op_result = {31'b0, a < b}; 
            result[31:0] = alu_op_result; 
            result[32] = (alu_op_result == 0); 
            result[33] = (alu_op_result < 0); 
            result[34] = 0; 
        end
        4'd11: begin 
            result[31:0] = {31'b0, comp}; 
            result[32] = (result[31:0] == 0); 
            result[33] = (result[31:0] < 0); 
            result[34] = 0; 
        end
        default: result = 35'b0;
    endcase
end

endmodule


module Compare_TwoC
(
    input [31:0] a, b,
    output reg comp
);

always @(*) begin
    if (a[31] ^ b[31])
        comp = !(a < b);
    else
        comp = a < b;
end

endmodule
