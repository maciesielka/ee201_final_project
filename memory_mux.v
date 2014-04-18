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
module memory_mux(addr, digit, spo
    );
input [6:0] addr;
input [3:0] digit;

output [127:0] spo;

wire [127:0] data1;
wire [127:0] data2;
wire [127:0] data3;
wire [127:0] data4;
wire [127:0] data5;
wire [127:0] data6;
wire [127:0] data7;
wire [127:0] data8;
wire [127:0] data9;

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

/*case(digit)
	begin
		4'b0000: assign spo = data1;
		4'b0001: assign spo = data2;
		4'b0010: assign spo = data3;
		4'b0011: assign spo = data4;
		4'b0100: assign spo = data;
		4'b0101:
		4'b0110:
		4'b0111:
		4'b1000:
		4'b1001:
		default: assign spo = data9;
	end
endcase*/

endmodule
