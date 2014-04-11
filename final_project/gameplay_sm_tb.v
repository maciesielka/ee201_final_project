`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:11:02 04/10/2014
// Design Name:   gameplay_sm
// Module Name:   /home/student/Desktop/EE201/ee201_final_project/final_project/gameplay_sm_tb.v
// Project Name:  final_project
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

module gameplay_sm_tb;

	// Inputs
	reg Clk;
	reg Start;
	reg Reset;
	reg Select;
	reg [2:0] CardSelectCode;
	reg Ack;

	// Outputs
	wire QInit;
	wire QS1C;
	wire QF1C;
	wire QS2C;
	wire QF2C;
	wire QRemCards;
	wire QHideCards;
	wire QWin;
	
	reg [5*8:0] state_string;

	// Instantiate the Unit Under Test (UUT)
	gameplay_sm uut (
		.Clk(Clk), 
		.Start(Start), 
		.Reset(Reset), 
		.Select(Select), 
		.CardSelectCode(CardSelectCode), 
		.Ack(Ack), 
		.QInit(QInit), 
		.QS1C(QS1C), 
		.QF1C(QF1C), 
		.QS2C(QS2C), 
		.QF2C(QF2C), 
		.QRemCards(QRemCards), 
		.QHideCards(QHideCards), 
		.QWin(QWin)
	);
	
	always @(*)
		begin
			case({QWin, QHideCards, QRemCards, QF2C, QS2C, QF1C, QS1C, QInit})
				8'b00000001: state_string = "QInit";
				8'b00000010: state_string = "QS1C";
				8'b00000100: state_string = "QF1C";
				8'b00001000: state_string = "QS2C";
				8'b00010000: state_string = "QF2C";
				8'b00100000: state_string = "QRC";
				8'b01000000: state_string = "QHC";
				8'b10000000: state_string = "QWin";
			endcase
		end
		
	always
	begin
		#10;
		Clk = ~Clk;
	end
	
	task GET_MATCH;
		begin
			wait(QS1C);
			Start = 0;
			Select = 1;
			wait(QF1C);
			Select = 0;
			CardSelectCode = 4;
			wait(QS2C);
			Select = 1;
			wait(QF2C);
			Select = 0;
		end
	endtask

	initial begin
		// Initialize Inputs
		Clk = 0;
		Start = 0;
		Reset = 1;
		Select = 0;
		CardSelectCode = 3;
		Ack = 0;

		// Wait 100 ns for global reset to finish
		#100;
      Start = 1;
		Reset = 0;
		// Add stimulus here
		GET_MATCH();
		$stop;
		
		
	end
      
endmodule

