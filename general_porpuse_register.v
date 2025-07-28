module general_porpuse_register (
    input [31:0] data_addr_in, 
    input [31:0] data_in, 
    input [31:0] next_pc,
    input clk, 
    input rst, 
    input s,
    output reg [31:0] pc_out, 
    output reg [31:0] Iout, 
    output reg [31:0] Mout,
    output reg E
);

    reg [31:0] mem[0:255]; // Let's say the first 128 elements are for instructions
    reg [31:0] instr_reg_I;
    reg [29:0] pc;

    initial begin
        $readmemb("C:/Users/kiustudents/Desktop/Sophomore/Sophomore/2 term/CA LAB/HWs/HW15/finali/Text1.txt", mem);
        Mout = 0;
        Iout = 0;
        pc_out = 0;
        E = 0;
    end

    function computeE(input E, clk, rst);
        if (rst)
            computeE = 0;
        else
            computeE = clk ? ~E : E;
    endfunction

    function [31:0] computePC(input [31:0] pc, input clk, rst, E);
        begin
            computePC = 0;
            if (rst)
                computePC = 0;
            else begin
                if (clk && E)
                    computePC = pc + 4; 
                else
                    computePC = pc;
            end
        end
    endfunction

    function [31:0] computeIRI(input [31:0] pc, input E, input [31:0] IRI, input rst, input clk);
        if (rst)
            computeIRI = 0;
        else if (clk && !E)
            computeIRI = pc;
        else
            computeIRI = IRI;
    endfunction

    always @(posedge clk) begin
        E <= computeE(E, clk, rst);
        pc_out <= computePC(pc_out, clk, rst, E);
        instr_reg_I <= computeIRI(pc_out, E, instr_reg_I, rst, clk);
        pc <= pc_out[31:2];
        
        if (!E) begin
            Iout <= mem[pc];
            Mout <= mem[pc];
        end else begin
            Iout <= mem[instr_reg_I];
            Mout <= 0;
            if (s)
                mem[data_addr_in[31:2]] <= data_in;
            else
                Mout <= mem[data_addr_in[31:2]];
        end
    end

endmodule
