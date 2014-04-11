`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:25:30 04/10/2014 
// Design Name: 
// Module Name:    gameplay_sm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module gameplay_sm(Clk, Start, Reset, Select, CardSelectCode, Ack, 
	QInit, QS1C, QF1C, QS2C, QF2C, QRemCards, QHideCards, QWin
    );
	 
parameter num_matches = 8;

input Clk, Start, Reset, Select, Ack;
input [2:0] CardSelectCode;

output QInit, QS1C, QF1C, QS2C, QF2C, QRemCards, QHideCards, QWin;

reg [6:0] state;
assign {QWin, QHideCards, QRemCards, QF2C, QS2C, QF1C, QS1C, QInit} = state;

reg [2:0] CARD1;
reg [2:0] CARD2;

reg [3:0] NUM_MATCHES;

localparam
	INIT 			= 8'b00000001,
	S1C  			= 8'b00000010,
	F1C  			= 8'b00000100,
	S2C  			= 8'b00001000,
	F2C  			= 8'b00010000,
	REM_CARDS  	= 8'b00100000,
	HIDE_CARDS 	= 8'b01000000,
	WIN			= 8'b10000000,
	UNK			= 8'bXXXXXXXX;

//----------------------STATE ASSIGNMENT----------------//
always @ (posedge Clk, posedge Reset)
	begin
		if(Reset)
			begin
				state <= INIT;
				CARD1 <= 3'bXXX;
				CARD2 <= 3'bXXX;
			end
		else
			case(state)
				INIT:
					begin
						CARD1 <= 3'b000;
						CARD2 <= 3'b000;
						NUM_MATCHES <= 0;
						if(Start)
							state <= S1C;
					end
				S1C:
					begin
						if(Select)
						begin
							state <= F1C;
							CARD1 <= CardSelectCode;
						end
					end
				F1C:
					begin
						if(!Select)
							state <= S2C;
					end
				S2C:
					begin
						if(Select)
						begin
							state <= F2C;
							CARD2 <= CardSelectCode;
						end
					end
				F2C:
					begin
						if(CARD1 != CARD2 && !Select)
							state <= HIDE_CARDS;
						else
							state <= REM_CARDS;
					end
				REM_CARDS:
					begin
						NUM_MATCHES <= NUM_MATCHES + 1;
						if(NUM_MATCHES == num_matches-1)
							state <= WIN;
						else
							state <= S1C;
					end
				HIDE_CARDS:
					begin
						state <= S1C;
					end
				WIN:
					if(Ack)
						state <= INIT;
				default:
					state <= UNK;
			endcase
	end
//-----------------------State Memory-------------------//

endmodule
