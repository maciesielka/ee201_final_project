`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:10:27 04/21/2014
// Design Name:   gameplay_sm
// Module Name:   /home/student/Desktop/EE201/ee201_final_project/gameplay_sm_tb2.v
// Project Name:  rom_example
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gameplay_sm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gameplay_sm_tb2;

	// Inputs
	reg Clk;
	reg Start;
	reg Reset;
	reg Select;
	reg [5:0] CardSelectData;
	reg [3:0] CardSelectLoc;
	reg Ack;
	reg [7:0] seed;

	// Outputs
	wire [7:0] state;
	wire WriteEnable;
	wire [3:0] CARD1;
	wire [3:0] CARD2;
	wire [5:0] dataOut;
	wire [3:0] dataLoc;

	// Instantiate the Unit Under Test (UUT)
	gameplay_sm uut (
		.Clk(Clk), 
		.Start(Start), 
		.Reset(Reset), 
		.Select(Select), 
		.seed(seed),
		.CardSelectData(CardSelectData), 
		.CardSelectLoc(CardSelectLoc), 
		.Ack(Ack), 
		.state(state), 
		.WriteEnable(WriteEnable), 
		.CARD1(CARD1), 
		.CARD2(CARD2), 
		.dataOut(dataOut), 
		.dataLoc(dataLoc)
	);
	
	always
	begin
		#5 Clk = ~Clk;
	end

	initial begin
		// Initialize Inputs
		Clk = 0;
		Start = 1;
		Reset = 1;
		Select = 0;
		seed = 8'b00000000;
		CardSelectData = 0;
		CardSelectLoc = 0;
		Ack = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		Reset = 0;
        
		// Add stimulus here

	end
      
endmodule

