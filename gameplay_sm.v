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
module gameplay_sm(Clk, Start, Reset, Select, CardSelectData, CardSelectLoc, Ack, 
	 state, WriteEnable, CARD1, CARD2,
    dataOut, dataLoc);
	 
parameter num_matches = 8;

input Clk, Start, Reset, Select, Ack;
input [5:0] CardSelectData;
input [3:0] CardSelectLoc;

wire QInit, QS1C, QF1C, QS2C, QF2C, QRemCards, QHideCards, QWin;
output WriteEnable;
output [3:0] CARD1, CARD2;

output [3:0] dataLoc;
output [5:0] dataOut;
reg [3:0] dataLoc;
reg [5:0] dataOut;
output [7:0] state;
reg [7:0] state;
assign {QWin, QHideCards, QRemCards, QF2C, QS2C, QF1C, QS1C, QInit} = state;

reg [3:0] CARD1;
reg [3:0] CARD1_loc;
reg [3:0] CARD2;
reg [3:0] CARD2_loc;

reg [3:0] NUM_MATCHES;

reg[1:0] state_counter;
reg[24:0] clock_counter;

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
wire [7:0] random;
wire random_done;
reg flag_found_front;
reg [4:0] nums_generated;
reg [4:0] nums_written;
reg [4:0] addresses_written;
reg [1:0] temp_count;
integer i;
reg [63:0] random_numbers;
lsfr_8bit_rand_num_gen    rand_num_generator
			(.clk(Clk),.reset(Reset),.ce(Clk),.lfsr(random),.lsfr_done(random_done));

always @ (posedge Clk, posedge Reset)
	begin
		if(Reset)
			begin
				state <= INIT;
				CARD1 <= 3'bXXX;
				CARD2 <= 3'bXXX;
				NUM_MATCHES <= 4'bXXXX;
				state_counter <= 2'bXX;
				clock_counter <= 24'bX;
				dataOut <= {2'b01, CardSelectData[3:0]};
				addresses_written <= 4'b0000;
			end
		else
			case(state)
				INIT:
					begin
						CARD1 <= 3'b000;
						CARD2 <= 3'b000;
						NUM_MATCHES <= 4'b0000;
						state_counter <= 2'b00;
						clock_counter <= 24'd0;
						addresses_written <= addresses_written+1;
						dataOut <= {2'b01, CardSelectData[3:0]};
						dataLoc <= addresses_written;
						/*
						nums_generated <= 0;
						nums_written <= 4'b0001;
						addresses_written <= addresses_written+1;
						temp_count <= temp_count+1;
						if(temp_count == 2'b01)
						begin
							temp_count <= 2'b00;
							nums_written <= nums_written+1;
						end
						dataOut <= {2'b01, nums_written};
						dataLoc <= random[7:4];
						*/
						/*if(nums_generated < 4'b1111)
						begin
							flag_found_front = 0;
							for(i = 0; i < nums_generated; i=i+1)
							begin
								if(random[7:4] == random_numbers[i+3:i])
									flag_found_front = 1;
							end
							if(!flag_found_front)
							begin
								random_numbers[nums_generated*4-1:(nums_generated-1)*4] <= random[7:4];
								nums_generated <= nums_generated+1;
							end
						end
						
						if(nums_generated == 4'b1111)
						begin
							addresses_written <= addresses_written+1;
							nums_generated <= 4'b1111;
							dataOut <= {2'b01, nums_written};
							dataLoc <= addresses_written;
							temp_count <= temp_count+1;
							if(temp_count == 2'b01)
							begin
								temp_count <= 2'b00;
								nums_written <= nums_written+1;
							end
						end*/
						
						if(Start && addresses_written == 4'b1111)
							state <= S1C;
					end
				S1C:
					begin
						if(Select)
						begin
							state <= F1C;
							CARD1 <= CardSelectData[3:0];
							CARD1_loc <= CardSelectLoc;
							dataOut <= {2'b00, CardSelectData[3:0]};
							dataLoc <= CardSelectLoc;
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
							CARD2 <= CardSelectData[3:0];
							CARD2_loc <= CardSelectLoc;
							dataOut <= {2'b00, CardSelectData[3:0]};
							dataLoc <= CardSelectLoc;
						end
					end
				F2C:
					begin
						clock_counter <= clock_counter+1;
						if(clock_counter[24])
						begin
							clock_counter <= 24'd0;
							dataLoc <= CARD1_loc;
							if(CARD1 != CARD2 && !Select)
								begin
									dataOut <= {2'b01, CARD1};
									dataLoc <= CARD1_loc;
									state <= HIDE_CARDS;
								end
							else
								begin
									dataOut <= {2'b10, CARD1};
									dataLoc <= CARD1_loc;
									state <= REM_CARDS;
								end
						end
						
					end
				REM_CARDS:
					begin
						NUM_MATCHES <= NUM_MATCHES + 1;
						dataOut <= {2'b10, CARD2};
						dataLoc <= CARD2_loc;
						state_counter <= state_counter + 1;
						
						if(state_counter == 2'b01)
						begin
							
							if(NUM_MATCHES == num_matches[3:0]-1)
								begin
									state <= WIN;
									state_counter <= 2'b00;
								end
							else 
								begin 
									state_counter <= 2'b00;
									state <= S1C;
								end
						end						
					end
				HIDE_CARDS:
					begin
						dataOut <= {2'b01, CARD2};
						dataLoc <= CARD2_loc;
						state_counter <= state_counter + 1;
						if(state_counter == 2'b01)
							begin
								state <= S1C;
								state_counter <= 2'b00;
							end
					end
				WIN:
					begin
						if(Ack)
							state <= INIT;
					end
				default:
					state <= UNK;
			endcase
	end
//-----------------------State Memory-------------------//


	assign WriteEnable = QF1C || QF2C || QHideCards || QRemCards;
endmodule
