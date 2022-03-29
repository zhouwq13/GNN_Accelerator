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
						last_ID,
						ID1
					 );
					 
input [11:0] last_ID;
output[11:0] ID1;

localparam SIMD_num = 64;
localparam lane_num =32;
localparam feature_num = 2048;//64*32

assign ID1 = last_ID + feature_num;

endmodule
