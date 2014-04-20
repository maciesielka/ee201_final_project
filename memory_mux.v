`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:30:20 04/15/2014 
// Design Name: 
// Module Name:    memory_mux 
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
module memory_mux(digit, index_Y, spo
    );
	 
input [3:0] digit;
input [5:0] index_Y;
reg [63:0] temp;
output [63:0] spo;

wire [63:0] data1;
wire [63:0] data2;
wire [63:0] data3;
wire [63:0] data4;
wire [63:0] data5;
wire [63:0] data6;
wire [63:0] data7;
wire [63:0] data8;
wire [63:0] data9;

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

async_rom_9 mem9 (
      .a(index_Y), // input [6 : 0] a
      .spo(data9) // output [127 : 0] spo
);

always @ (digit, data1, data2, data3, data4, data5, data6, data7, data8, data9)
begin
	case(digit)
		4'b0000: temp = data1; //blank
		4'b0001: temp = data2;
		4'b0010: temp = data3;
		4'b0011: temp = data4;
		4'b0100: temp = data5;
		4'b0101: temp = data6;
		4'b0110: temp = data7;
		4'b0111: temp = data8;
		4'b1000: temp = data9;
		default: temp = 127'd0;
	endcase
end

assign spo = temp;
endmodule
