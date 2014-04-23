`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b,
					 BtnU, BtnD, BtnR, BtnL, BtnC, St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar,
					 Mt_St_we_bar, An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
					 LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
					 Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7);
	
	input ClkPort, BtnU, BtnD, BtnR, BtnL, BtnC, Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	reg vga_r, vga_g, vga_b;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ce, ClkPort, board_clk, clk, button_clk;
	
	BUFGP BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	//assign reset = Sw0;
	//assign start = Sw1;
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
	
	wire [7:0] seed = {Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0};

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] positionY;
	reg [9:0] positionX;
	
	reg [1:0] selectRow;
	reg [1:0] selectCol;
	wire [9:0] selectWidth = 10'd5;
	
	wire [3:0] selectCard = {selectRow, selectCol};
	
	wire UP, DOWN, LEFT, RIGHT, CENTER, CENTER_bar;
	ee201_debouncer #(.N_dc(23)) UP_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnU), .DPB( ), .SCEN(UP), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(23)) DOWN_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnD), .DPB( ), .SCEN(DOWN), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(23)) LEFT_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnL), .DPB( ), .SCEN(LEFT), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(23)) RIGHT_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnR), .DPB( ), .SCEN(RIGHT), .MCEN(), .CCEN( ));
	ee201_debouncer #(.N_dc(23)) CENTER_debounce
			(.CLK(clk), .RESET(reset), .PB(BtnC), .DPB(), .SCEN(CENTER), .MCEN(), .CCEN( ));
	
	wire writeEnable;
	wire SELECT = CENTER && (~selectCardData[5] && selectCardData[4]);
	 wire [5:0] newData;
	 wire [5:0] selectCardData;
	 wire [8:0] state;
	 wire [3:0] newDataLoc;
	 wire [3:0] numMatches;
	gameplay_sm state_machine(
		.Clk(clk), 
		.Start(CENTER), 
		.Reset(reset),
		.seed(seed),
		.Select(SELECT), 
		.CardSelectLoc(selectCard),
		.CardSelectData(selectCardData), 
		.Ack(CENTER), 
		.state(state),
		.WriteEnable(writeEnable),
		.dataOut(newData),
		.dataLoc(newDataLoc),
		.numMatches(numMatches)
    );
	
	
	always @(posedge clk)
		begin
			if(reset)
			begin
				selectRow <= 2'b00;
				selectCol <= 2'b00;
				positionX <= 20;
				positionY <= 20;
				//newData <= {2'b01, selectCardData[3:0]};
			end
			else /*if(CENTER)
				begin
					if(~selectCardData[5])
					begin
						if(selectCardData[4])
							newData <= {2'b00, selectCardData[3:0]};
						else 
							newData <= {2'b01, selectCardData[3:0]};
					end
					
				end
			else */if(DOWN && ~UP)
				selectRow <= selectRow+1;
			else if(UP && ~DOWN)
				selectRow <= selectRow-1;	
			else if(RIGHT && ~LEFT)
				selectCol<= selectCol+1;
			else if(LEFT && ~RIGHT)
				selectCol <= selectCol-1;
				
			//writeEnable <= CENTER;
			
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
	
	reg [3:0] tempCardAddr;
	reg [3:0] cardAddr;
	wire valid = (row1 || row2 || row3 || row4) && (col1 || col2 || col3 || col4);
	
	always @ (row1, row2, row3, row4, col1, col2, col3, col4, cardAddr, tempCardAddr)
	begin
		if(row1)
		begin
			case({col4, col3, col2, col1})
				4'b0001: tempCardAddr <= 4'b0000;
				4'b0010: tempCardAddr <= 4'b0001;
				4'b0100: tempCardAddr <= 4'b0010;
				4'b1000: tempCardAddr <= 4'b0011;
			endcase
		end
		else if(row2)
		begin
			case({col4, col3, col2, col1})
				4'b0001: tempCardAddr <= 4'b0100;
				4'b0010: tempCardAddr <= 4'b0101;
				4'b0100: tempCardAddr <= 4'b0110;
				4'b1000: tempCardAddr <= 4'b0111;
			endcase
		end else if(row3)
		begin
			case({col4, col3, col2, col1})
				4'b0001: tempCardAddr <= 4'b1000;
				4'b0010: tempCardAddr <= 4'b1001;
				4'b0100: tempCardAddr <= 4'b1010;
				4'b1000: tempCardAddr <= 4'b1011;
			endcase
		end else if(row4)
		begin
			case({col4, col3, col2, col1})
				4'b0001: tempCardAddr <= 4'b1100;
				4'b0010: tempCardAddr <= 4'b1101;
				4'b0100: tempCardAddr <= 4'b1110;
				4'b1000: tempCardAddr <= 4'b1111;
			endcase
		end
		cardAddr <= tempCardAddr;
	end
	
	//cursor box
	wire [9:0] selectStartX = positionX - selectWidth;
	wire [9:0] selectStartY = positionY - selectWidth;
	wire [9:0] boxX = selectStartX+(width+offset)*selectCol;
	wire [9:0] boxY = selectStartY+(width+offset)*selectRow;
	
	wire selectEn = (CounterX >= boxX && CounterX < boxX+selectWidth && CounterY >= boxY && CounterY < boxY+width+selectWidth*2) ||
						 (CounterX >= boxX+width+selectWidth && CounterX < boxX+selectWidth*2+width && CounterY >= boxY && CounterY < boxY+width+selectWidth*2) ||
						 (CounterY >= boxY && CounterY < boxY+selectWidth && CounterX >= boxX && CounterX < boxX+width+selectWidth*2) ||
						 (CounterY >= boxY+width+selectWidth && CounterY < boxY+selectWidth*2+width && CounterX >= boxX && CounterX < boxX+width+selectWidth*2);
	
	reg [5:0] index_X;
	reg [5:0] index_Y;
	
	wire [63:0] data;
	
	
    //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
	 
	 wire [5:0] memory_value;
	 
	 /*card_memory_3 card_memory (
	  .clka(clk), // input clka
	  .wea(writeEnable), // input [0 : 0] wea
	  .addra(selectCard), // input [3 : 0] addra
	  .dina(newData), // input [5 : 0] dina
	  .clkb(clk), // input clkb
	  .addrb(cardAddr), // input [3 : 0] addrb
	  .doutb(memory_value) // output [5 : 0] doutb
	);*/
	wire [4:0] addrB = writeEnable ? newDataLoc : selectCard;
	card_memory_4 card_memory (
	  .clka(clk), // input clka
	  .wea(1'b0), // input [0 : 0] wea
	  .addra(cardAddr), // input [3 : 0] addra
	  .dina(), // input [5 : 0] dina
	  .douta(memory_value), // output [5 : 0] douta
	  .clkb(clk), // input clkb
	  .web(writeEnable), // input [0 : 0] web
	  .addrb(addrB), // input [3 : 0] addrb
	  .dinb(newData), // input [5 : 0] dinb
	  .doutb(selectCardData) // output [5 : 0] doutb
	);
	 
	 reg [3:0] card_data;
	 always @ (memory_value, card_data)
	 begin
		//if it should be empty, be empty
		if(memory_value[5])
			card_data <= 4'b1111; 
		else if(memory_value[4])
			card_data <= 4'b0000;
		else
			card_data <= memory_value[3:0];
	 end
  
	memory_mux mem_mux(
		.digit(card_data), 
		.index_Y(index_Y), 
		.spo(data)
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
			index_X <=6'd63;
		else
			index_X <= index_X - 1'b1;
	end
	
   always @(posedge clk)
	begin
		if (inDisplayArea) // 640 x 480
		begin
			if(valid)
				begin
					if(memory_value[5])
						{vga_r, vga_g, vga_b} <= 3'b000;
					else
						begin
							{vga_r,vga_g,vga_b} <= data[index_X] ? 3'b111 : 3'b100;
						end
						
				end
			else if(selectEn) //draw the box
				{vga_r,vga_g,vga_b} <= 3'b001;
			else
				{vga_r,vga_g,vga_b} <= 3'b000;
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
	//wire useless = CENTER;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	//assign LD7 = CENTER;
	assign {LD7, LD6, LD5, LD4, LD3, LD2, LD1, LD0} = state[7:0];
	
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
	
	assign SSD3 = {selectCardData[3:0]};
	//assign SSD2 = {3'b000, CENTER};
	//assign SSD1 = 4'b0000;
	//assign SSD1 = q[7:4];
	//assign SSD0 = q[3:0];
	//assign SSD1 = 4'b;
	assign SSD0 = numMatches;
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	//assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An1 = 1'b1;
	assign An2 = 1'b1;
	//assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= Sw1 ? (!( (ssdscan_clk[1]) &&  (ssdscan_clk[0]))) : 1'b1;  // when ssdscan_clk = 11
	
	//SSD 2 is always off...
	//assign An2 = 1'b1;
	//assign An1 = 1'b1;
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
