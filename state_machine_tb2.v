`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:35:43 04/21/2014
// Design Name:   gameplay_sm
// Module Name:   /home/student/Desktop/EE201/ee201_final_project/state_machine_tb2.v
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

module state_machine_tb2;

	// Inputs
	reg Clk;
	reg Start;
	reg Reset;
	reg Select;
	reg [5:0] CardSelectData;
	reg [3:0] CardSelectLoc;
	reg Ack;

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

	initial begin
		// Initialize Inputs
		Clk = 0;
		Start = 0;
		Reset = 0;
		Select = 0;
		CardSelectData = 0;
		CardSelectLoc = 0;
		Ack = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

