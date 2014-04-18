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
    input clk,
    input reset,
    input ce,
    output [7:0] lfsr,
    output lsfr_done
    );

	reg [7:0] lfsr, lfsr_done;
	wire d0,lfsr_equal;
	
	xnor(d0,lfsr[7],lfsr[5],lfsr[4],lfsr[3]);
	assign lfsr_equal = (lfsr == 8'h80);
	
	always @(posedge clk, posedge reset)
	begin
		if (reset) 
		begin
			lfsr <= 8'b0;
			lfsr_done <= 1'b0;
		end
		else
		begin
			if (ce)
			begin
				lfsr <= lfsr_equal ? 8'h0 : {lfsr[6:0],d0};
			end
			
			lfsr_done <= lfsr_equal;
		end
	end
	
endmodule
