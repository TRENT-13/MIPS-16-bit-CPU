module mips_processor(
    input clk,
    input rst,
    output reg [31:0] aluresout,
    output reg [31:0] shiftresultout,
    output reg [31:0] GP_DATA_INout
);

    wire [31:0]  Iout, Mout;
	 wire [31:0] pc_out;
    wire [31:0] srcA, srcB, aluRes;
    wire [31:0] signExtImm;
    wire [31:0] shiftRes, writeData;
    wire [4:0] addrA, addrB, addrC;
    wire zero, neg, ovfalu;
    wire [3:0] Af, Bf;
    wire I, ALU_MUX_SEL, GP_WE, DM_WE;
    wire [1:0] GP_MUX_SEL, PC_MUX_SEL;
    wire [2:0] Shift_type;
    wire branch_taken;
    wire E;
	 wire [31:0] nextPC;

	 
    // Instantiate submodules
    general_porpuse_register mem_inst(
        .data_addr_in(aluRes),
        .data_in(writeData),
        .next_pc(nextPC),
        .clk(clk),
        .rst(rst),
        .s(DM_WE),
        .pc_out(pc_out),
        .Iout(Iout),
        .Mout(Mout),
        .E(E)
    );
	 
	
	 

    instruction_decoder id_inst(
        .Instruction(Iout),
        .Af(Af),
        .I(I),
        .ALU_MUX_SEL(ALU_MUX_SEL),
        .Cad(addrC),
        .GP_WE(GP_WE),
        .GP_MUX_SEL(GP_MUX_SEL),
        .Bf(Bf),
        .DM_WE(DM_WE),
        .Shift_type(Shift_type),
        .PC_MUX_SEL(PC_MUX_SEL)
    );


	 
	 
	 
    ALU alu_inst(
        .srcA(srcA),
        .srcB(srcB),
        .af(Af),
        .i(I),
        .Alures(aluRes),
        .zero(zero),
        .neg(neg),
        .ovfalu(ovfalu)
    );
	 
	 
	 	 memory gpr_inst(
        .clk(clk),
        .write_enable(GP_WE),
        .addrA(Iout[25:21]),
        .addrB(Iout[20:16]),
        .addrC(addrC),
        .data_in_C(writeData),
        .srcA(srcA),
        .srcB(srcB)
    );



    shifter shifter_inst(
        .a(srcB),
        .n(Iout[10:6]),
        .funct(Shift_type),
        .r(shiftRes)
    );

    xtimm xtimm_inst(
        .immediateIN(Iout[15:0]),
        .u(I),
        .immediateOUT(signExtImm)
    );

    // Mux for ALU source B
    assign srcB = ALU_MUX_SEL ? signExtImm : srcB;

    // Mux for register write data
    assign writeData = (GP_MUX_SEL == 2'b00) ? aluRes :
                       (GP_MUX_SEL == 2'b01) ? Mout :
                       (GP_MUX_SEL == 2'b10) ? shiftRes :
                       pc_out + 8;

    // Branch condition evaluation
    cond_eval branch_cond(
        .opcode(Bf),
        .rs1_data(srcA),
        .rs2_data(srcB),
        .branch(branch_taken)
    );
	 
	 

    // Mux for next PC
    wire [31:0] branchTarget, jumpTarget;
    assign branchTarget = signExtImm << 2;
    assign jumpTarget = {pc_out[31:28], Iout[25:0], 2'b00};

    assign nextPC = (PC_MUX_SEL == 2'b00) ? pc_out + 4 :
                    (PC_MUX_SEL == 2'b01) ? srcA :
                    (PC_MUX_SEL == 2'b10) ? (branch_taken ? pc_out + branchTarget : pc_out) :
                    jumpTarget;
						  
						  
	     reg [31:0] pc_out1;
		  reg  E1;
    // Update PC, output values, and E register
    always @(posedge clk) begin
		  pc_out1 <= pc_out;
		  E1 <= E;
        if (rst) begin
            pc_out1 <= 32'b0;
            aluresout <= 0;
            shiftresultout <= 0;
            GP_DATA_INout <= 0;
            E1 <= 0;
        end else begin
            if (E1) begin
                // Fetch cycle
               pc_out1 <= nextPC;
            end else begin
                aluresout <= aluRes;
                shiftresultout <= shiftRes;
                GP_DATA_INout <= writeData;
                E1 <= ~E1;
            end
        end
    end


endmodule 