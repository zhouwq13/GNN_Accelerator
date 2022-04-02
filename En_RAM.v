`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/01 22:29:44
// Design Name: 
// Module Name: En_RAM
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


module En_RAM(
			  feature_start,
			  feature_stop,
			  Enable,
			  RAM_start,
			  RAM_stop
			);
				
input [11:0] feature_start;
input [11:0] feature_stop;//输入的是真实的维度数
output reg [7:0] Enable;//输出RAM分块的使能
output reg [8:0] RAM_start;//输出的是第一个使能的RAM块的，块内计算的起始特征数
output reg [8:0] RAM_stop;

localparam RAM_width = 10'd512;

reg [2:0] RAM_start_in;
reg [2:0] RAM_stop_in;
reg [2:0] tmp;//记录差值

wire [2:0] w_start_in;
wire [7:0] w_start_out;
wire [2:0] w_stop_in;
wire [7:0] w_stop_out;

assign w_start_in = RAM_start_in;
assign w_stop_in  = RAM_stop_in;
assign w_in_1 = w_start_in + 3'd1;
assign w_in_2 = w_start_in + 3'd2;
assign w_in_3 = w_start_in + 3'd3;
assign w_in_4 = w_start_in + 3'd4;
assign w_in_5 = w_start_in + 3'd5;
assign w_in_6 = w_start_in + 3'd6;

//-----------------------------------------------------
//模块例化
//------------------------------------------------------
decoder_38 U_in(
					.din(w_start_in),
					.dout(w_start_out)
				 );
				 
decoder_38 U_out(
					.din(w_stop_in),
					.dout(w_stop_out)
				 );
				 
				 
decoder_38 U_1(
					.din(w_in_1),
					.dout(w_out_1)
				 );
				 
decoder_38 U_2(
					.din(w_in_2),
					.dout(w_out_2)
				 );
decoder_38 U_3(
					.din(w_in_3),
					.dout(w_out_3)
				 );
				 
decoder_38 U_4(
					.din(w_in_4),
					.dout(w_out_4)
				 );
decoder_38 U_5(
					.din(w_in_5),
					.dout(w_out_5)
				 );
decoder_38 U_6(
					.din(w_in_6),
					.dout(w_out_6)
				 );
//-----------------------------------------------------
//模块例化
//------------------------------------------------------				 
always@(*)
begin	
	//真实维度ID除512，求第一个和最后一个需要使能的RAM分块
	RAM_start_in = feature_start >> 9; 
	RAM_stop_in  = feature_stop  >> 9;
	//中间差几个数就是几个RAM块需要使能
	tmp = feature_stop - feature_start;
	//第一个和最后一个RAM分块中，需要取哪个特征（起始）
	RAM_start = feature_start % RAM_width;
	RAM_stop  = feature_stop % RAM_width;
	
	case(tmp)
	3'd1:
		 Enable = w_start_out ^ w_stop_out;
	3'd2:
		 Enable = w_start_out ^ w_stop_out ^ w_in_1;
	3'd3:
		 Enable = w_start_out ^ w_stop_out ^ w_in_1 ^ w_in_2;
	3'd4:
		 Enable = w_start_out ^ w_stop_out ^ w_in_1 ^ w_in_2 ^ w_in_3;
	3'd5:
		 Enable = w_start_out ^ w_stop_out ^ w_in_1 ^ w_in_2 ^ w_in_3 ^ w_in_4;
	3'd6:
		 Enable = w_start_out ^ w_stop_out ^ w_in_1 ^ w_in_2 ^ w_in_3 ^ w_in_4 ^ w_in_5;
	3'd7:
		 Enable = w_start_out ^ w_stop_out ^ w_in_1 ^ w_in_2 ^ w_in_3 ^ w_in_4 ^ w_in_5 ^ w_in_6;
	default:
		 Enable = 8'b0;
	endcase
	
end
	
endmodule
