`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, 
					 BtnU, BtnD, BtnR, BtnL, BtnC, St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar,
					 Mt_St_we_bar, An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
					 LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	
	input ClkPort, BtnU, BtnD, BtnR, BtnL, BtnC, Sw0, Sw1;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	reg vga_r, vga_g, vga_b;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ce, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	btn_clk = DIV_CLK[21];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] positionY;
	reg [9:0] positionX;
	
	reg [1:0] selectRow;
	reg [1:0] selectCol;
	wire [9:0] selectWidth = 10'd5;
	
	wire UP;
	wire LEFT;
	wire DOWN;
	wire RIGHT;
	ee201_debouncer #(.N_dc(25)) UP_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnU), .DPB( ), .SCEN(UP), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(25)) DOWN_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnD), .DPB( ), .SCEN(DOWN), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(25)) LEFT_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnL), .DPB( ), .SCEN(LEFT), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(25)) RIGHT_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnR), .DPB( ), .SCEN(RIGHT), .MCEN(), .CCEN( ));
	
	always @(posedge clk)
		begin
			if(reset)
			begin
				selectRow <= 2'd0;
				selectCol <= 2'd0;
				positionX <= 20;
				positionY <= 20;
			end
			else if(DOWN && ~UP)
				selectRow <= selectRow+1;
			else if(UP && ~DOWN)
				selectRow <= selectRow-1;	
			else if(RIGHT && ~LEFT)
				selectCol<= selectCol+1;
			else if(LEFT && ~RIGHT)
				selectCol <= selectCol-1;
		end
	

	wire [8:0] width = 8'd64;
	wire [9:0] offset = 10'd10;

	wire row1 = CounterY >= (positionY+width*0) && CounterY < (positionY+width*1);
	wire row2 = CounterY >= (positionY+width*1+offset) && CounterY < (positionY+width*2+offset);
	wire row3 = CounterY >= (positionY+width*2+offset*2) && CounterY < (positionY+width*3+offset*2);
	wire row4 = CounterY >= (positionY+width*3+offset*3) && CounterY < (positionY+width*4+offset*3);
	
	wire col1 = CounterX >= (positionX+width*0) && CounterX < (positionX+width*1);
	wire col2 = CounterX >= (positionX+width*1+offset) && CounterX < (positionX+width*2+offset);
	wire col3 = CounterX >= (positionX+width*2+offset*2) && CounterX < (positionX+width*3+offset*2);
	wire col4 = CounterX >= (positionX+width*3+offset*3) && CounterX < (positionX+width*4+offset*3);

   wire mem1En =  row1 && col1;
   wire mem2En = row1 && col2;
	wire mem3En = row1 && col3;
	wire mem4En = row1 && col4;
	
	wire mem5En =  row2 && col1;
   wire mem6En = row2 && col2;
	wire mem7En = row2 && col3;
	wire mem8En = row2 && col4;
	
	wire [9:0] selectStartX = positionX - selectWidth;
	wire [9:0] selectStartY = positionY - selectWidth;
	wire [9:0] boxX = selectStartX+(width+offset)*selectCol;
	wire [9:0] boxY = selectStartY+(width+offset)*selectRow;
	
	wire selectEn = (CounterX >= boxX && CounterX < boxX+selectWidth && CounterY >= boxY && CounterY < boxY+width+selectWidth*2) ||
						 (CounterX >= boxX+width+selectWidth && CounterX < boxX+selectWidth*2+width && CounterY >= boxY && CounterY < boxY+width+selectWidth*2) ||
						 (CounterY >= boxY && CounterY < boxY+selectWidth && CounterX >= boxX && CounterX < boxX+width+selectWidth*2) ||
						 (CounterY >= boxY+width+selectWidth && CounterY < boxY+selectWidth*2+width && CounterX >= boxX && CounterX < boxX+width+selectWidth*2);
	
	/*wire selectEn = (( CounterX >= (positionX+(width+offset)*selectCol-selectWidth) && CounterX < (positionX+(width+offset)*selectCol) ) ||
						 ( CounterX >= (positionX+(width+offset)*(selectCol+1)-selectWidth) && CounterX < (positionX+(width+offset)*(selectCol+1)) )) &&
						 (( CounterY >= (positionY+(width+offset)*selectRow-selectWidth) && CounterX < (positionY+(width+offset)*selectRow) ) ||
						 ( CounterY >= (positionY+(width+offset)*(selectRow+1)-selectWidth) && CounterX < (positionY+(width+offset)*(selectRow+1)) ) ); */
	
	reg [5:0] index_X;
	reg [5:0] index_Y;
	wire [63:0] data1;
	wire [63:0] data2;
	wire [63:0] data3;
	wire [63:0] data4;
	wire [63:0] data5;
	wire [63:0] data6;
	wire [63:0] data7;
	wire [63:0] data8;
	
	
    //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
    async_rom mem1 (
      .a(index_Y), // input [6 : 0] a
      .spo(data1) // output [127 : 0] spo
	 );
	 async_rom_2 mem2 (
      .a(index_Y), // input [6 : 0] a
      .spo(data2) // output [127 : 0] spo
    );
	 async_rom_3 mem3 (
      .a(index_Y), // input [6 : 0] a
      .spo(data3) // output [127 : 0] spo
	 );
	 async_rom_4 mem4 (
      .a(index_Y), // input [6 : 0] a
      .spo(data4) // output [127 : 0] spo
    );
	 async_rom_5 mem5 (
      .a(index_Y), // input [6 : 0] a
      .spo(data5) // output [127 : 0] spo
	 );
	 async_rom_6 mem6 (
      .a(index_Y), // input [6 : 0] a
      .spo(data6) // output [127 : 0] spo
    );
	 async_rom_7 mem7 (
      .a(index_Y), // input [6 : 0] a
      .spo(data7) // output [127 : 0] spo
	 );
	 async_rom_8 mem8 (
      .a(index_Y), // input [6 : 0] a
      .spo(data8) // output [127 : 0] spo
    );
	 
	 wire writeEnable;
	 card_mem card_memory (
		.a({selectRow, selectCol}),
		.d(),
		.spo(),
		.we(writeEnable),
		.clk(clk)
	 );
  
    // INST_TAG_END ------ End INSTANTIATION Template ---------
	always @(posedge clk)
	begin
	   if (CounterY == 10'd480 ||
			 CounterY == (positionY) ||
			 CounterY == (positionY+(width+offset)*1) ||
			 CounterY == (positionY+(width+offset)*2) ||
			 CounterY == (positionY+(width+offset)*3) )
		    index_Y <= 7'b0;
		else if (CounterX == 10'd640)
		begin
		    index_Y <= index_Y + 1'b1;
			 index_X <= 0;
		end
			
		if (CounterX == (positionX) || 
			CounterX == (positionX+(width+offset)*1) ||
			CounterX == (positionX+(width+offset)*2) ||
			CounterX == (positionX+(width+offset)*3))
			index_X <=7'd127;
		else
			index_X <= index_X - 1'b1;
	end
	
   always @(posedge clk)
	begin
		if (inDisplayArea) // 640 x 480
		begin
			 case ( {selectEn, mem8En,mem7En,mem6En,mem5En,mem4En,mem3En,mem2En,mem1En} )
			     9'b0_0000_0001 : {vga_r,vga_g,vga_b} <= data1[index_X] ? 3'b111 : 3'b000;
			     9'b0_0000_0010 : {vga_r,vga_g,vga_b} <= data2[index_X] ? 3'b111 : 3'b000;
				  9'b0_0000_0100 : {vga_r,vga_g,vga_b} <= data3[index_X] ? 3'b111 : 3'b000;
			     9'b0_0000_1000 : {vga_r,vga_g,vga_b} <= data4[index_X] ? 3'b111 : 3'b000;
				  9'b0_0001_0000 : {vga_r,vga_g,vga_b} <= data5[index_X] ? 3'b111 : 3'b000;
			     9'b0_0010_0000 : {vga_r,vga_g,vga_b} <= data6[index_X] ? 3'b111 : 3'b000;
				  9'b0_0100_0000 : {vga_r,vga_g,vga_b} <= data7[index_X] ? 3'b111 : 3'b000;
			     9'b0_1000_0000 : {vga_r,vga_g,vga_b} <= data8[index_X] ? 3'b111 : 3'b000;
				  9'b1_0000_0000 : {vga_r,vga_g,vga_b} <= 3'b001;
				  default : {vga_r,vga_g,vga_b} <= 3'b000;
			 endcase
		end
		else
		begin	//All black background vga = 0x00
			 vga_r <= 1'b0;
			 vga_g <= 1'b0;
			 vga_b <= 1'b0;
		end
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	wire	[7:0] q;
	wire			lsfr_done;
	
	ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
			(.CLK(clk), .RESET(reset), .PB(BtnC), .DPB( ), .SCEN(ce ), .MCEN(), .CCEN( ));
	
	lsfr_8bit_rand_num_gen    rand_num_1
			(.clk(clk),.reset(reset),.ce(ce),.lfsr(q),.lsfr_done(lsfr_done));
	
	assign SSD3 = q > 8'h80 ? 1'b1 : 1'b0;
	assign SSD2 = {3'b000, ce};
	//assign SSD1 = q[7:4];
	//assign SSD0 = q[3:0];
	assign SSD1 = {2'b00, selectCol};
	assign SSD0 = {2'b00, selectRow};
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	//SSD 2 is always off...
	//assign An2 = 1'b1;
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [7:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = SSD_CATHODES;
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) //                              abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000011; // 0
			4'b0001: SSD_CATHODES = 8'b10011111; // 1
			4'b0010: SSD_CATHODES = 8'b00100101; // 2
			4'b0011: SSD_CATHODES = 8'b00001101; // 3
			4'b0100: SSD_CATHODES = 8'b10011001; // 4
			4'b0101: SSD_CATHODES = 8'b01001001; // 5
			4'b0110: SSD_CATHODES = 8'b01000001; // 6
			4'b0111: SSD_CATHODES = 8'b00011111; // 7
			4'b1000: SSD_CATHODES = 8'b00000001; // 8
			4'b1001: SSD_CATHODES = 8'b00001001; // 9
			4'b1010: SSD_CATHODES = 8'b00010001; // A
			4'b1011: SSD_CATHODES = 8'b11000001; // B
			4'b1100: SSD_CATHODES = 8'b01100011; // C
			4'b1101: SSD_CATHODES = 8'b10000101; // D
			4'b1110: SSD_CATHODES = 8'b01100001; // E
			4'b1111: SSD_CATHODES = 8'b01110001; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule
