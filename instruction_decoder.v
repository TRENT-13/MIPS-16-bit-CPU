module instruction_decoder
(
input [31:0] Instruction,
output reg [3:0] Af,
output reg I,
output reg ALU_MUX_SEL,
output reg [4:0] Cad,
output reg GP_WE,
output reg [1:0] GP_MUX_SEL,
output reg [3:0] Bf,
output reg DM_WE,
output reg [2:0] Shift_type,
output reg [1:0] PC_MUX_SEL
);

reg [5:0] opc;
reg rtype;
reg jtype;
reg itype;

reg [4:0] rs;
reg [4:0] rt;
reg [4:0] rd;
reg [4:0] sa;
reg [5:0] fun;
reg [15:0] imm;
reg [25:0] iindex;

//alu operations
reg alur;
reg alui;
reg alu;

//ls operations
reg l;
reg s;
reg ls;

//branch operations
reg b;

//jump operations
reg jr;
reg jalr;
reg j;
reg jal;

reg jump;
reg jb;

//shift (added sll and sra to the table from the book)
reg srl;
reg sll;
reg sra;
reg shift;

//all of this straight from the book
reg [4:0] rdes;

always@(*) begin
	opc = Instruction[31:26];
	rtype = opc[5] == 0 && opc [3:0] == 0;
	jtype = opc[5:1] == 1;
	itype = !(rtype || jtype);

	rs = Instruction[25:21];
	rt = Instruction[20:16];
	rd = Instruction[15:11];
	sa = Instruction[10:6];
	fun = Instruction[5:0];
	imm = Instruction[15:0];
	iindex = Instruction[25:0];

	alur = rtype && (fun[5:4] == 2);
	alui = itype && (opc[5:3] == 1);
	alu = alur || alui;

	l = opc[5:3] == 4;
	s = opc[5:3] == 5;
	ls = l || s;

	b = itype && (opc[5:3] == 0);

	jr = rtype && fun == 8;
	jalr = rtype && fun == 9;
	j = jtype && opc == 2;
	jal = jtype && opc == 3;

	jump = jr || jalr || j || jal;
	jb = jump || b;

	srl = rtype && fun == 2;
	sll = rtype && fun == 0;
	sra = rtype && fun == 3;
	shift = srl || sll || sra;

	rdes = rtype ? rd : rt;

	Af[2:0] = rtype ? fun[2:0] : opc[2:0];
	Af[3] = rtype ? fun[3] : (opc[2:1] == 1);
	I = itype;
	ALU_MUX_SEL = I;
	
	Bf = {opc[2:0], rt[0]};
	
	if (jal)
		Cad = 31;
	else if (rtype)
		Cad = rd;
	else
		Cad = rt;
		
	GP_WE = alu || shift || l || jal || jalr;
	
	if (alu)
		GP_MUX_SEL = 0;
	else if (ls)
		GP_MUX_SEL = 1;
	else if (shift)
		GP_MUX_SEL = 2;
	else
		GP_MUX_SEL = 3;

	if (srl)
		Shift_type = 1;
	else if (sll)
		Shift_type = 2;
	else if (sra)
		Shift_type = 4;
	else
		Shift_type = 0;

	if (jr || jalr)
		PC_MUX_SEL = 1;
	else if (b)
		PC_MUX_SEL = 2;
	else if (j || jal)
		PC_MUX_SEL = 3;
	else
		PC_MUX_SEL = 0;

	DM_WE = s; //if store, enable writing to memory
end

endmodule