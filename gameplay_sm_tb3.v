`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:15:57 04/22/2014
// Design Name:   gameplay_sm
// Module Name:   /home/student/Desktop/EE201/ee201_final_project/gameplay_sm_tb3.v
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

module gameplay_sm_tb3;

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
	wire [9:0] state;
	wire WriteEnable;
	wire [5:0] dataOut;
	wire [3:0] dataLoc;
	wire [3:0] numMatches;

	// Instantiate the Unit Under Test (UUT)
	gameplay_sm uut (
		.Clk(Clk), 
		.Start(Start), 
		.Reset(Reset), 
		.Select(Select), 
		.CardSelectData(CardSelectData), 
		.CardSelectLoc(CardSelectLoc), 
		.Ack(Ack), 
		.seed(seed), 
		.state(state), 
		.WriteEnable(WriteEnable), 
		.dataOut(dataOut), 
		.dataLoc(dataLoc),
		.numMatches(numMatches)
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
		CardSelectData = 0;
		CardSelectLoc = 0;
		Ack = 0;
		seed = 8'h30;

		// Wait 100 ns for global reset to finish
		#100;
       Reset = 0;
		#100;
		 Start = 0;
		// Add stimulus here

	end
      
endmodule

