`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module memory_game(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b,
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
	
	//vga counter
	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] positionY;
	reg [9:0] positionX;
	
	reg [1:0] selectRow;
	reg [1:0] selectCol;
	
	//width of cursor-box
	wire [9:0] selectWidth = 10'd5;
	wire [3:0] selectCard = {selectRow, selectCol};
	
	//debounce all buttons to run at 25MHz
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
	//only select if the card is not hidden or already flipped over
	wire SELECT = CENTER && (~selectCardData[5] && selectCardData[4]);
	 wire [5:0] newData;
	 wire [5:0] selectCardData;
	 wire [9:0] state;
	 wire [3:0] newDataLoc;
	 wire [3:0] numMatches;
	 
	 //state machine instantitation
	gameplay_sm state_machine(
		.Clk(clk), 
		.Start(CENTER), 
		.Reset(reset),
		.seed(seed), //randomization seed
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
			end 
			else if(DOWN && ~UP) //directional pad functionality
				selectRow <= selectRow+1;
			else if(UP && ~DOWN)
				selectRow <= selectRow-1;	
			else if(RIGHT && ~LEFT)
				selectCol<= selectCol+1;
			else if(LEFT && ~RIGHT)
				selectCol <= selectCol-1;
			
		end
	
	//bitmap width
	wire [8:0] width = 8'd64;
	//padding between cards
	wire [9:0] offset = 10'd10;

	//bounds for rows
	wire row1 = CounterY >= (positionY+width*0) && CounterY <= (positionY+width*1+1);
	wire row2 = CounterY >= (positionY+width*1+offset) && CounterY <= (positionY+width*2+offset+1);
	wire row3 = CounterY >= (positionY+width*2+offset*2) && CounterY <= (positionY+width*3+offset*2+1);
	wire row4 = CounterY >= (positionY+width*3+offset*3) && CounterY <= (positionY+width*4+offset*3+1);
	
	//bounds for columns
	wire col1 = CounterX >= (positionX+width*0) && CounterX <= (positionX+width*1);
	wire col2 = CounterX >= (positionX+width*1+offset) && CounterX <= (positionX+width*2+offset+1);
	wire col3 = CounterX >= (positionX+width*2+offset*2) && CounterX <= (positionX+width*3+offset*2+1);
	wire col4 = CounterX >= (positionX+width*3+offset*3) && CounterX <= (positionX+width*4+offset*3+1);
	
	reg [3:0] tempCardAddr;
	reg [3:0] cardAddr;
	
	//if we should be drawing a card -- used for VGA outputs
	wire valid = (row1 || row2 || row3 || row4) && (col1 || col2 || col3 || col4);
	
	//encode the row-col coordinates to binary 0-15
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
	
	//cursor box starting locations
	wire [9:0] selectStartX = positionX - selectWidth;
	wire [9:0] selectStartY = positionY - selectWidth;
	wire [9:0] boxX = selectStartX+(width+offset)*selectCol;
	wire [9:0] boxY = selectStartY+(width+offset)*selectRow;
	
	//if we should draw the cursor-box
	wire selectEn = (CounterX >= boxX && CounterX < boxX+selectWidth && CounterY >= boxY && CounterY < boxY+width+selectWidth*2) || //left edge
						 (CounterX >= boxX+width+selectWidth && CounterX < boxX+selectWidth*2+width && CounterY >= boxY && CounterY < boxY+width+selectWidth*2) || //right edge
						 (CounterY >= boxY && CounterY < boxY+selectWidth && CounterX >= boxX && CounterX < boxX+width+selectWidth*2) || //top edge
						 (CounterY >= boxY+width+selectWidth && CounterY < boxY+selectWidth*2+width && CounterX >= boxX && CounterX < boxX+width+selectWidth*2); //bottom edge
	
	reg [5:0] index_X;
	reg [5:0] index_Y;
	
	wire [63:0] data;
	
	
    //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
	 
	 wire [5:0] memory_value;
	 
	//if we're not writing, we'll just use the 
	//B-addr for selection data
	wire [4:0] addrB = writeEnable ? newDataLoc : selectCard;
	
	//2-input/output RAM for current state data
	//A-ports -> for VGA display
	//B-ports -> for state machine interface
	card_memory card_memory_1 (
	  .clka(clk), // input clka
	  .wea(1'b0), // input [0 : 0] wea -- use this port only for reading
	  .addra(cardAddr), // input [3 : 0] addra
	  .dina(), // input [5 : 0] dina -- use this port only for reading
	  .douta(memory_value), // output [5 : 0] douta
	  .clkb(clk), // input clkb
	  .web(writeEnable), // input [0 : 0] web
	  .addrb(addrB), // input [3 : 0] addrb
	  .dinb(newData), // input [5 : 0] dinb
	  .doutb(selectCardData) // output [5 : 0] doutb
	);
	 
	wire [3:0] card_data;
	 
	assign card_data = memory_value[5] ? 4'b1111 : (memory_value[4] ? 4'b0000 : memory_value[3:0]);
  
	//routes the right bitmap to the data bus for VGA display
	memory_mux mem_mux(
		.digit(card_data), 
		.index_Y(index_Y), 
		.spo(data)
    );
  
    // INST_TAG_END ------ End INSTANTIATION Template ---------
	always @(posedge clk)
	begin
	   if (CounterY == 10'd479 ||
			 CounterY == (positionY-1) ||
			 CounterY == (positionY+(width+offset)*1-1) ||
			 CounterY == (positionY+(width+offset)*2-1) ||
			 CounterY == (positionY+(width+offset)*3-1) )
		    index_Y <= 7'b0;
		else if (CounterX == 10'd639)
		begin
		    index_Y <= index_Y + 1'b1;
			 index_X <= 0;
		end
			
		if (CounterX == (positionX-1) || 
			CounterX == (positionX+(width+offset)*1-1) ||
			CounterX == (positionX+(width+offset)*2-1) ||
			CounterX == (positionX+(width+offset)*3-1))
			index_X <= 6'd63;
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
			else //otherwise black
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
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg[7:0] stateBinary;
	//convert the 10-bit one-hot state var to encoded-value 
	//for LED display
	always@(state, stateBinary)
		begin
			case(state)
				10'b0000000001: stateBinary <= 8'b000000001;
				10'b0000000010: stateBinary <= 8'b000000010;
				10'b0000000100: stateBinary <= 8'b000000011;
				10'b0000001000: stateBinary <= 8'b000000100;
				10'b0000010000: stateBinary <= 8'b000000101;
				10'b0000100000: stateBinary <= 8'b000000110;
				10'b0001000000: stateBinary <= 8'b000000111;
				10'b0010000000: stateBinary <= 8'b000001000;
				10'b0100000000: stateBinary <= 8'b000001001;
				10'b1000000000: stateBinary <= 8'b000001010;
				default: stateBinary <= 8'bXXXXXXXX;
			endcase
		end
	assign {LD7, LD6, LD5, LD4, LD3, LD2, LD1, LD0} = stateBinary;
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	
	assign SSD3 = selectCardData[3:0]+1;
	assign SSD0 = numMatches;
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= (!(~(ssdscan_clk[1]) && ~(ssdscan_clk[0])));  // when ssdscan_clk = 00
	assign An1 = 1'b1;
	assign An2 = 1'b1;
	assign An3	= (Sw1 && ~selectCardData[5]) ? (!( (ssdscan_clk[1]) &&  (ssdscan_clk[0]))) : 1'b1;  // when ssdscan_clk = 11
	
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
