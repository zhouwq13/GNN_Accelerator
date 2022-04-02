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
						Fin,//xuanze
						last_F,
						F21,
						F22,
						needMT64
							);
//-----------------------------------------------------
//端口声明
//------------------------------------------------------
input  [11:0] Fin;//来自S1或S2的输出
output reg [11:0]  last_F;
output reg [11:0]  F21;//e_i取[last_F,F21-1]
output reg [11:0]  F22;//e_i+1取[0,F22-1]
output 		  reg needMT64; //需要大于64个核计算当前边
//-----------------------------------------------------
//参数声明
//------------------------------------------------------
localparam total_F = 12'd3703;//Citeseer的所有维度
localparam total_core = 10'd64;//所有核的数量

reg [11:0] need_F21;
reg [11:0] need_F22;

//-----------------------------------------------------
//计算
//------------------------------------------------------
always @ (Fin)
begin
	//边e_i 根据特征配核
	need_F21 = total_F - Fin;
	core21 = need_F21 >> 5 + 1;//右移是向下取整的，所以加一
	last_F = Fin;
	F21 = Fin + needF21;
	//边e_i+! 根据核算特征
	core22 = total_core - core21;
	need_F22 = core22 << 5;
	F22 = 0 + need_F22;
	//判断信号
	needMT64 = (total_F - F22) > 2048 ? 1 : 0;
end

endmodule

