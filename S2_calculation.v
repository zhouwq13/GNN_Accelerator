`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/26 16:54:59
// Design Name: 
// Module Name: S2_calculation
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


module S2_calculation(					
						last_ID,
						core21,
						core22,
						ID21,
						ID22,
						m,
						need64
							);
//-----------------------------------------------------
//端口声明
//------------------------------------------------------
input  [11:0] last_ID;//来自S1的ID输出
output [11:0] ID21;
output [11:0] ID22;//记录读到哪个状态了
output [5:0] core21;
output [5:0] core21;
output [5:0] m;
output 		 need64;
//-----------------------------------------------------
//参数声明
//------------------------------------------------------
localparam all_feature = 12'd3703;
localparam all_core = 10'd64;
//-----------------------------------------------------
//计算
//------------------------------------------------------
assign core21 = (all_feature - (all_core  << 5) ) >> 5 + 1;//右移是向下取整的，所以加一
assign core22 = all_core - core21;
assign ID21 = core21 << 5;
assign ID22 = core22 << 5;
assign m = (all_features - ID) >> 5 + 1;
assign (m >= 64) ? need64 == 1 : need64 == 0;

endmodule

