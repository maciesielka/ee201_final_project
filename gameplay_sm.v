`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Michael Ciesielka & Henry Lau
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

output WriteEnable;
output [3:0] dataLoc;
output [5:0] dataOut;
output [3:0] numMatches;
output [9:0] state;

wire QInit, QRandomize, QWrite, QS1C, QF1C, QS2C, QF2C, QRemCards, QHideCards, QWin;

reg [3:0] dataLoc;
reg [5:0] dataOut;
reg [9:0] state;

assign {QWin, QHideCards, QRemCards, QF2C, QS2C, QF1C, QS1C, QWrite, QRandomize, QInit} = state;

//placeholders for the selected cards' data
reg [3:0] CARD1;
reg [3:0] CARD1_loc;
reg [3:0] CARD2;
reg [3:0] CARD2_loc;
reg [3:0] numMatches;
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
wire [15:0] random;
reg flag1, flag2, flag3, flag4;
reg done_random;
//4-bit wide array of 16 addresses -> for random numbers
reg [3:0] addr [0:15];
reg [3:0] nums_written; // the card number we're writing to the RAM
reg [3:0] address_count; //the number of addresses we've filled in the array
reg [1:0] temp_count; //counter for writing

//pseudo-random number generator
lsfr_8bit_rand_num_gen    rand_generator
		  (.clk(Clk),
			.reset(QInit),
			.ce(QRandomize), 
			.seed(seed), 
			.lfsr(random),
			.lsfr_done());
			
//parse 4-pseudorandom numbers from the 16-bit number
wire [3:0] temp_random1 = {random[15], random[11], random[7], random[3]};
wire [3:0] temp_random2 = {random[14], random[10], random[6], random[2]};
wire [3:0] temp_random3 = {random[13], random[9], random[5], random[1]};
wire [3:0] temp_random4 = {random[12], random[8], random[4], random[0]};

//main state machine
always @ (posedge Clk, posedge Reset)
	begin
		if(Reset)
			begin
				state <= INIT;
				
				//prevent recirculating muxes
				CARD1 <= 4'bXXX;
				CARD2 <= 4'bXXX;
				numMatches <= 4'bXXXX;
				state_counter <= 2'bXX;
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
						//intialization
						CARD1 <= 4'b0000;
						CARD2 <= 4'b0000;
						numMatches <= 4'b0000;
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
				RANDOMIZE: //this state randomizes and deposits numbers
					begin: GENERATE_ALL_NUMBERS
						if(!done_random)
						begin: KEEP_GENERATING_RANDOMS
							integer i;
							//set flags for the four random numbers
							flag1 = 0;
							flag2 = 0;
							flag3 = 0;
							flag4 = 0;
							
							//address_count is how many numbers are in the array
							for(i = 0; i < address_count; i = i+1)
							begin
								//if any random number already exists in the array
								//we can't use it
								if(addr[i] == temp_random1)
									flag1 = 1;
								if(addr[i] == temp_random2)
									flag2 = 1;
								if(addr[i] == temp_random3)
									flag3 = 1;
								if(addr[i] == temp_random4)
									flag4 = 1;
							end
							
							//fill in one address appropriately
							if(!flag1)
							begin
								addr[address_count] <= temp_random1;
								address_count <= address_count+1;
								if(address_count == 4'b1111)
									done_random <= 1;
							end else if(!flag2)
							begin
								addr[address_count] <= temp_random2;
								address_count <= address_count+1;
								if(address_count == 4'b1111)
									done_random <= 1;
							end else if(!flag3)
							begin
								addr[address_count] <= temp_random3;
								address_count <= address_count+1;
								if(address_count == 4'b1111)
									done_random <= 1;
							end else if(!flag4)
							begin
								addr[address_count] <= temp_random4;
								address_count <= address_count+1;
								if(address_count == 4'b1111)
									done_random <= 1;
							end
						end
						
						//if we've generated all addresses 4'b0000-4'b1111
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
						//we enter the state ready to perform this the 0th operation,
						//so address_count is already set to 4'b0001
						//if we wrap around, writing has finished
						if(address_count == 4'b0000)
							state <= S1C;
						
						address_count <= address_count + 1;
						dataLoc <= addr[address_count];
						dataOut <= {2'b01, nums_written}; //cards are initially hidden
						temp_count <= temp_count + 1;
						
						//allocate 2 instances of each value 2-9 to 
						//the randomly generated addresses in the array
						if(temp_count == 2'b01)
							begin
								temp_count <= 2'b00;
								nums_written <= nums_written + 1;
							end
					end
				S1C:
					begin: SHOW_1ST_CARD
						if(Select)
						begin
							state <= F1C;
							CARD1 <= CardSelectData[3:0];
							CARD1_loc <= CardSelectLoc;
							//prepare to unflip the card on next clock
							dataOut <= {2'b00, CardSelectData[3:0]};
							dataLoc <= CardSelectLoc;
						end
					end
				F1C:
					begin: FLIP_1ST_CARD
						if(!Select)
							state <= S2C;
					end
				S2C:
					begin: SELECT_2ND_CARD
						if(Select)
						begin
							state <= F2C;
							CARD2 <= CardSelectData[3:0];
							CARD2_loc <= CardSelectLoc;
							//prepare the card to unflip on next clock
							dataOut <= {2'b00, CardSelectData[3:0]};
							dataLoc <= CardSelectLoc;
						end
					end
				F2C:
					begin: FLIP_2ND_CARD
						clock_counter <= clock_counter+1;
						//create a delay in flipping the card
						//so the user can see what they've selected
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
						
						//requires two clocks -- removes two cards
						state_counter <= state_counter + 1;
						
						if(state_counter == 2'b01)
						begin
							numMatches <= numMatches + 1;
							if(numMatches == num_matches-1)
								begin //if all cards are matched
									state <= WIN;
									state_counter <= 2'b00;
								end
							else 
								begin //if the game is still on
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
						//requires two clocks to hide two cards
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
endmodule
