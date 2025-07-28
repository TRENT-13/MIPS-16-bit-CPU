module memory (
  input clk,
  input write_enable,
  input [4:0] addrA,  // Address for reading register A
  input [4:0] addrB,  // Address for reading register B
  input [4:0] addrC,  // Address for writing data
  input [31:0] data_in_C,  // Data to be written
  output reg [31:0] srcA,  // Output from register A
  output reg [31:0] srcB   // Output from register B with delay
);

  // Register file to store data
  reg [31:0] regfile [0:31];

  reg [31:0] regB_out;

   
    
    initial begin
        $readmemb("C:/Users/kiustudents/Desktop/Sophomore/Sophomore/2 term/CA LAB/HWs/HW15/finali/Text1.txt", regfile);
        regfile[0] = 32'd0;
    end

  // Assign outputs from register file (combinational logic)
  always @( * ) begin
    srcA = regfile[addrA];
    regB_out = regfile[addrB];  // Capture current value for delayed output
  end

  always @( posedge clk ) begin
    if (write_enable & (addrC != 0)) begin
      regfile[addrC] <= data_in_C;
    end
  end

  // Assign delayed output for srcB (sequential logic)
  always @( posedge clk ) begin
    srcB <= regB_out;
  end

endmodule
