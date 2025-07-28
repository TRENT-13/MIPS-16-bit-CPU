module xtimm
#(
parameter N = 16,
parameter M = 32
)
(
input [N-1:0] immediateIN,
input u,
output [M-1:0] immediateOUT
);

assign immediateOUT = u ? {{M-N{1'b0}}, immediateIN} : {{M-N{immediateIN[N-1]}}, immediateIN};

endmodule 