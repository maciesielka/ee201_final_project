`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:54 04/13/2013 
// Design Name: 
// Module Name:    lsfr_8bit_rand_num_gen 
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
module lsfr_8bit_rand_num_gen(
    clk,
    reset,
    ce,
	 seed,
     lfsr,
     lsfr_done
    );
	input clk, reset, ce;
	input [7:0] seed;
	output [15:0] lfsr;
	output lsfr_done;
	reg [15:0] lfsr, lfsr_done;
	wire d0,lfsr_equal;
	
	xnor(d0,lfsr[15],lfsr[14],lfsr[12],lfsr[3]);
	assign lfsr_equal = (lfsr == 16'h8000);
	reg [15:0] counter;
	
	always @(posedge clk, posedge reset)
	begin
		if (reset) 
		begin
			counter <= 15'dX;
			lfsr <= counter+{8'd0,seed};
			lfsr_done <= 1'b0;
		end
		else
		begin
			counter <= counter + 1'b1;
			if (ce)
			begin
				lfsr <= lfsr_equal ? (counter+{8'd0,seed}) : {lfsr[14:0],d0};
			end
			
			lfsr_done <= lfsr_equal;
		end
	end
	
endmodule
