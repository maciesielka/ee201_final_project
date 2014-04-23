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
module gameplay_sm(Clk, Start, Reset, Select, CardSelectData, CardSelectLoc, Ack, seed,
	 state, WriteEnable,
    dataOut, dataLoc, numMatches);
	 
parameter num_matches = 8;

input Clk, Start, Reset, Select, Ack;
input [5:0] CardSelectData;
input [3:0] CardSelectLoc;
input [7:0] seed;

wire QInit, QRandomize, QWrite, QS1C, QF1C, QS2C, QF2C, QRemCards, QHideCards, QWin;
output WriteEnable;
output [3:0] dataLoc;
output [5:0] dataOut;
reg [3:0] dataLoc;
reg [5:0] dataOut;
output [9:0] state;
reg [9:0] state;
assign {QWin, QHideCards, QRemCards, QF2C, QS2C, QF1C, QS1C, QWrite, QRandomize, QInit} = state;

reg [3:0] CARD1;
reg [3:0] CARD1_loc;
reg [3:0] CARD2;
reg [3:0] CARD2_loc;

reg [3:0] NUM_MATCHES;
output [3:0] numMatches;
reg[1:0] state_counter;
reg[24:0] clock_counter;

localparam
	INIT 			= 10'b0000000001,
	RANDOMIZE	= 10'b0000000010,
	WRITE			= 10'b0000000100,
	S1C  			= 10'b0000001000,
	F1C  			= 10'b0000010000,
	S2C  			= 10'b0000100000,
	F2C  			= 10'b0001000000,
	REM_CARDS  	= 10'b0010000000,
	HIDE_CARDS 	= 10'b0100000000,
	WIN			= 10'b1000000000,
	UNK			= 10'bXXXXXXXXXX;

//----------------------STATE ASSIGNMENT----------------//
wire [7:0] random;
wire random_done;
wire [3:0] temp_random;
reg flag;
reg done_random;
reg [3:0] addr [0:15];
reg [3:0] nums_generated;
reg [3:0] nums_written;
reg [3:0] address_count;
reg [1:0] temp_count;
integer i;
reg [63:0] random_numbers;
reg seed_enable;
lsfr_8bit_rand_num_gen    rand_generator
		  (.clk(Clk),
			.reset(Start),
			.ce(Clk), 
			.seed(seed), 
			.lfsr(random),
			.lsfr_done(random_done));
			


always @ (posedge Clk, posedge Reset)
	begin
		if(Reset)
			begin
				state <= INIT;
				CARD1 <= 4'bXXX;
				CARD2 <= 4'bXXX;
				NUM_MATCHES <= 4'bXXXX;
				state_counter <= 2'bXX;
				NUM_MATCHES <= 4'b0000;
				state_counter <= 2'bXX;
				clock_counter <= 24'dX;
				nums_written <= 4'bXXXX;
				address_count <= 4'bXXXX;
				temp_count <= 2'bXX;
				done_random <= 1'bX;
				dataOut <= 6'bXXXXXX;
				dataLoc <= 4'bXXXX;
			end
		else
			begin
			case(state)
				INIT:
					begin
						CARD1 <= 4'b0000;
						CARD2 <= 4'b0000;
						NUM_MATCHES <= 4'b0000;
						state_counter <= 2'b00;
						clock_counter <= 24'd0;
						nums_written <= 4'b0000;
						address_count <= 4'b0000;
						temp_count <= 2'b00;
						done_random <= 0;
						dataLoc <= 4'b0000;
						dataOut <= 6'b000000;
						if(Start)
							state <= RANDOMIZE;
					end
				RANDOMIZE:
					begin
						if(!done_random)
						begin: CHECK_IF_RANDOM_EXISTS
							integer i;
							flag = 0;
							//$display("doing my best");
							for(i = 0; i < address_count; i = i+1)
							begin
								//$display("Addr[i]: %d\tRandom[3:0]: %d", addr[i], random[3:0]);
								if(addr[i] == random[3:0])
									flag = 1;
							end
							if(!flag)
							begin
								addr[address_count] <= random[3:0];
								address_count <= address_count+1;
								if(address_count == 4'b1111)
									done_random <= 1;
							end
						end
						
						if(done_random)
						begin
							state <= WRITE;
							address_count <= 4'b0001;
							//setup for first write
							dataLoc <= addr[0];
							dataOut <= {2'b01, 4'b0001};
							nums_written <= 4'b0001;
							temp_count <= 2'b01;
						end
						
					end
				WRITE:
					begin
						if(address_count == 4'b0000)
							state <= S1C;
						
						address_count <= address_count + 1;
						dataLoc <= addr[address_count];
						dataOut <= {2'b01, nums_written};
						//dataOut <= {2'b01, seed[7:4]};
						temp_count <= temp_count + 1;
						if(temp_count == 2'b01)
							begin
								temp_count <= 2'b00;
								nums_written <= nums_written + 1;
							end
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
						
						dataOut <= {2'b10, CARD2};
						dataLoc <= CARD2_loc;
						state_counter <= state_counter + 1;
						
						if(state_counter == 2'b01)
						begin
							NUM_MATCHES <= NUM_MATCHES + 1;
							if(NUM_MATCHES == num_matches-1)
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
	end
//-----------------------State Memory-------------------//


	assign WriteEnable = QWrite || QF1C || QF2C || QHideCards || QRemCards;
	assign numMatches = NUM_MATCHES;
endmodule
