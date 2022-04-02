`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/01 22:30:30
// Design Name: 
// Module Name: decoder_38
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module decoder_38(
	input		[2:0]	din,
	output	reg [7:0]	dout
				 );
	always @(*)begin
		case(din)
			3'b000:dout<=8'b0000_0000;
			3'b001:dout<=8'b0000_0001;
			3'b010:dout<=8'b0000_0010;
			3'b011:dout<=8'b0000_0100;
			3'b100:dout<=8'b0000_1000;
			3'b101:dout<=8'b0001_0000;
			3'b110:dout<=8'b0010_0000;
			3'b111:dout<=8'b0100_0000;
			default:;
		endcase
	end
endmodule
