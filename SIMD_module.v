`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/14 11:23:57
// Design Name: 
// Module Name: SIMD_module
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


//例化64个TOP
module SIMD_module(
					clk,
					rst,
					Imma,
					Immb,
					Instr,
					Result_i,
					Addr,
					Result_o
					);
//--------------------------------------------------------------------   
//-------------------------/参数声明
//--------------------------------------------------------------------										
localparam SIMD_num = 64;
localparam lane_num = 32;
localparam feature_size = 8;
localparam data_size = 16384;  //SIMD_num*lane_num*feature_size
localparam Instr_size = 512;   //(per_op_size+(per_addr_size-5))*64
localparam per_Addr_size = 5; //1bit tag + 5bit index + 6bit offset 只要5位就可以直接映射
localparam per_opcode_size = 1;//每个SIMD核一个opcpde
localparam per_tag_size = 1;//每个核一个tag来判断聚合是否结束
localparam Instr_group_size = 8;//per_op_size+per_tag_size+per_Addr_size
localparam buffer_entry_num = 32;

//--------------------------------------------------------------------   
//-------------------------//模块输入输出端口声明
//--------------------------------------------------------------------
input clk;
input rst;
input  [data_size-1 : 0] Imma;
input  [data_size-1 : 0] Immb;
input  [Instr_size-1 : 0] Instr;
input  [data_size-1 : 0] Result_i;
output [(per_Addr_size + per_opcode_size) * SIMD_num - 1 : 0] Addr;
output [data_size-1 : 0] Result_o;

//--------------------------------------------------------------------   
//-------------------------子模块输入输出连线声明
//--------------------------------------------------------------------	

wire [SIMD_num-1 : 0] op;
wire [SIMD_num-1 : 0] tag;
wire [data_size-1: 0] Src_A;
wire [data_size-1: 0] Src_B;
wire [buffer_entry_num*per_Addr_size-1 : 0] d_a;//32×5-1=159
wire [data_size-1: 0] d_o;
wire [SIMD_num-1 : 0] state;
wire [SIMD_num-1 : 0] d_R;
wire [SIMD_num-1 : 0] d_W;

//--------------------------------------------------------------------   
//------------------------------模块例化
//--------------------------------------------------------------------	
	genvar j;	
	generate			
		for(j=0; j<data_size; j=j+feature_size)begin: ImmNd_o //必须起名字，必须加begin-end
			assign Imma[j+feature_size-1 : j] = (counter==0)? Instr[  j+feature_size-1 : j ] : Result_i[  j+feature_size-1 : j ];
			assign Immb[j+feature_size-1 : j] = Instr[  j+feature_size-1 : j ];  
			assign d_o[j+feature_size-1 : j] = Result_i[ j+feature_size-1 : j ];
		end
	endgenerate
	
		
	genvar i;
	generate		
		for(i=0; i<SIMD_num; i=i+1)begin: instanM
		
			assign op[i] = Instr[8*i+7];//乘法必须显示写出！！不可以8i
			assign d_a[8*i+5 : 8*i] = Instr[8*i+5 : 8*i];//前面不知道写啥
			assign tag[i] = Instr[8*i+6];
			
			SIMD_top SIMD_i(
					 .clk(clk),
					 .rst(rst),
					 .opcode(op[i]),
					 .tag(tag[i]),
					 .Src_A(Src_A[256*i+256 : 256*i]),
					 .Src_B(Src_B[256*i+256 : 256*i]),//
					 .data_address(d_a[8*i+5 : 8*i]),//奇数和偶数不一样了？ 	
					 .data_out(d_o[256*i+256 : 256*i]),	
					 .state(state[i]),              
					 .data_R(d_R[i]),
					 .data_W(d_W[i])
					);
		end
		
	endgenerate

endmodule
