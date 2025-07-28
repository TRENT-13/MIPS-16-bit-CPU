module Mips_proccesor_tb;
    // Inputs
    reg clk;
    reg rst;

    // Outputs
    wire [31:0] aluresout;
    wire [31:0] shift_resultout;
    wire [31:0] GP_DATA_INout;

    // Instantiate the Unit Under Test (UUT)
    mips_processor dut (
        .clk(clk), 
        .rst(rst), 
        .aluresout(aluresout), 
        .shiftresultout(shift_resultout),
        .GP_DATA_INout(GP_DATA_INout)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;

        // Wait for global reset
        #100;
        rst = 0;
		  
		  #100;
		  
		  rst = 1;
		  #10;
        // Add stimulus here
		  rst = 0;

        // Finish after some time
        #1000 $finish;
    end

endmodule
