`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/25 22:43:29
// Design Name: 
// Module Name: S1_calculation
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


module S1_calculation(
						Fin,//F22输出
						ini_in,
						last_F,
						F1
					 );
					 
input ini_in;
input [11:0] Fin;
output reg [11:0]  last_F;
output reg [11:0]  F1;//取特征的区间为[last_F,F1-1]

reg [11:0] last_F;

localparam SIMD_num = 64;
localparam lane_num =32;
localparam feature_num = 2048;//64*32


always @ (Fin)
begin
	last_F = ini_in ? 0 : Fin;
	need_F = feature_num;
	F1 = last_F + need_F;
end

endmodule
