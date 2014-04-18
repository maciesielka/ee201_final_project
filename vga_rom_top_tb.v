`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:37:29 12/18/2013
// Design Name:   vga_demo
// Module Name:   /home/chris/Documents/USC/2013/3_Fall/EE201_Introduction_to_Digital_Ciruits/X3_rom_square_vga_example/rom_example/vga_rom_top_tb.v
// Project Name:  rom_example
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_demo
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vga_rom_top_tb;

	// Inputs
	reg ClkPort;
	reg Sw0;
	reg Sw1;
	reg BtnU;
	reg BtnD;
	reg BtnR;
	reg BtnL;
	reg BtnC;

	// Outputs
	wire vga_h_sync;
	wire vga_v_sync;
	wire vga_r;
	wire vga_g;
	wire vga_b;
	wire St_ce_bar;
	wire St_rp_bar;
	wire Mt_ce_bar;
	wire Mt_St_oe_bar;
	wire Mt_St_we_bar;
	wire An0;
	wire An1;
	wire An2;
	wire An3;
	wire Ca;
	wire Cb;
	wire Cc;
	wire Cd;
	wire Ce;
	wire Cf;
	wire Cg;
	wire Dp;
	wire LD0;
	wire LD1;
	wire LD2;
	wire LD3;
	wire LD4;
	wire LD5;
	wire LD6;
	wire LD7;

	// Local variables
	reg reset_done;
	
	
	// Instantiate the Unit Under Test (UUT)
	vga_demo uut (
		.ClkPort(ClkPort), 
		.vga_h_sync(vga_h_sync), 
		.vga_v_sync(vga_v_sync), 
		.vga_r(vga_r), 
		.vga_g(vga_g), 
		.vga_b(vga_b), 
		.Sw0(Sw0), 
		.Sw1(Sw1), 
		.BtnU(BtnU), 
		.BtnD(BtnD), 
		.BtnR(BtnR), 
		.BtnL(BtnL), 
		.BtnC(BtnC), 
		.St_ce_bar(St_ce_bar), 
		.St_rp_bar(St_rp_bar), 
		.Mt_ce_bar(Mt_ce_bar), 
		.Mt_St_oe_bar(Mt_St_oe_bar), 
		.Mt_St_we_bar(Mt_St_we_bar), 
		.An0(An0), 
		.An1(An1), 
		.An2(An2), 
		.An3(An3), 
		.Ca(Ca), 
		.Cb(Cb), 
		.Cc(Cc), 
		.Cd(Cd), 
		.Ce(Ce), 
		.Cf(Cf), 
		.Cg(Cg), 
		.Dp(Dp), 
		.LD0(LD0), 
		.LD1(LD1), 
		.LD2(LD2), 
		.LD3(LD3), 
		.LD4(LD4), 
		.LD5(LD5), 
		.LD6(LD6), 
		.LD7(LD7)
	);
	
/////////////////////////////////
//
// 1. Specify a DUMP file for GTKWave
//
/////////////////////////////////	
	initial
		begin : DUMPFILE
			$display("dumpfile set to: dump.vcd");
			$dumpfile("dump.vcd");
			$dumpvars(0,vga_rom_top_tb);
	end

//////////////////////////////////
// 
//		2. Generate a 100Mhz Clk like
//		Nexys3 board.
//
/////////////////////////////////
	parameter CLK_PERIOD = 10; //10ns PERIOD = 100Mhz
   
	initial 
		begin : CLK_GENERATOR
		ClkPort = 0;
		forever
			begin
				#(CLK_PERIOD/2) ClkPort = ~ClkPort; 
			end
	end
	
/////////////////////////////////
//
//		3. Reset Block - using a
//		sperate block is good practice
//		Sw0 is RESET for this design
//		NOTE: hvsync_generator needs
//		to be changed to ASYNC reset!
//
/////////////////////////////////
	initial
		begin  : RESET_GENERATOR
			$display("begin RESET_GENERATOR");
			Sw0 = 1;
			reset_done = 0;
			repeat(2) @(posedge ClkPort);
			Sw0 = 0;
			repeat(5) @(posedge ClkPort);
			Sw0 = 1;
			repeat(2) @(posedge ClkPort);
			Sw0 = 0;
			reset_done = 1;
	end

/////////////////////////////////
//
//		4. Main stimulus block
//
////////////////////////////////
	initial
		begin  : STIMULUS
			// Initialize Inputs
			Sw1 = 0;
			BtnU = 0;
			BtnD = 0;
			BtnR = 0;
			BtnL = 0;
			BtnC = 0;

			// Wait for RESET, display starting msg
			wait(reset_done);
			$display("reset done, begin STIMULUS");
		        
			// Add stimulus here			 
			#1000
			capture_image;
			#1000
			
			// End with a $finish to stop simulation
			// remove if interactive simulation desired
			// ie iSim
			$display("testbench done, ending STIMULUS");
			//$finsh;

	end
      
	task capture_image;
		integer i;
		begin
			$display("Captureing image...");
		end
	endtask
	
endmodule

