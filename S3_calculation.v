`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/26 16:41:41
// Design Name: 
// Module Name: S3_calculation
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


module S3_calculation(
						last_ID,
						ID3,
						core22,
						core3
					 );
					 
input  [11:0] last_ID;//来自S1的输出ID1
input  [5:0] core22;
output [11:0] ID3;
output [5:0] core3;

assign core3 = (3703 - 2048 - core22 << 5) >> 5 + 1;
assign ID3 = core2 << 5;
 
endmodule
