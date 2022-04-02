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
						Fin,//来自S1或S2，状态机中完成选择
						last_F,
						F3,//取[last_F,F3-1]
						core3,
						done
					 );
					 
input  [11:0] Fin;//来自S1或S2的输出
output reg [11:0]  last_F;
output reg [11:0]  F3;
output reg [5:0]   core3;
output reg done;

localparam total_F = 12'd3703;//Citeseer的所有维度
localparam total_core = 10'd64;//所有核的数量
reg [11:0] need_F;

always @(Fin)
begin
	need_F = total_F - Fin;
	core3 = need_F >> 5 + 1;
	last_F = Fin;
	F3 = last_F + need_F;
	done = 1;
end

endmodule
