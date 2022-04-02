`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/25 16:53:12
// Design Name: 
// Module Name: eShed
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

module eShed(

			 clk,
			 rst,
			 Task,
			 edg,
			 en2SIMD,
			 addr2Edge,//待修改
			 addr2Feature1,//
			 addr2Feature2,//
			 en2Feature,
			 feature_start,
			 feature_stop
		 
			);
//-----------------------------------------------------
//端口声明
//------------------------------------------------------
input clk;
input rst;
input Task;//连接EdgeFIFO的empty信号取反
input  [23:0] edg;

output [63:0] en2SIMD;
output [4:0]  addr2Edge;//获取边表
output [11:0] addr2Feature1;//获取src特征
output [11:0] addr2Feature2;//获取dst特征
output [7:0]  en2Feature;//8个RAM的读使能
output [8:0] w_RAM_start;
output [8:0] w_RAM_stop;


//-----------------------------------------------------
//状态定义
//------------------------------------------------------
reg [1:0] current_state;
reg [1:0] next_state;

localparam IDLE = 00;
localparam S1 = 01;
localparam S2 = 10;
localparam S3 = 11;

// reg counter;//记录拿了多少个边,
//-----------------------------------------------------
//连线声明
//------------------------------------------------------

//模块状态
reg ini;
reg need64;
reg done;
//模块连出
reg [11:0]  feature_start;//开始特征维度
reg [11:0]  feature_stop;//结束特征维度

//S1
wire w_ini_in;
wire [11:0] w_Fin1;
wire [11:0] w_F_start1;
wire [11:0] w_F_stop1;

//S2
wire [11:0] w_Fin2;
reg  [11:0] Fin2;
assign w_Fin2 = Fin2;

wire [11:0] w_F_start21;
// wire [11:0] w_F_stop21;
wire [11:0] w_F_stop22;
wire w_need64;
//S3
wire [11:0] w_Fin3;
reg  [11:0] Fin3;
assign w_Fin3 = Fin3;

wire [11:0] w_F_start3;
wire [11:0] w_F_stop3;
wire [5:0]  w_core3;
wire w_done;
wire [5:0]  w_en_SIMD;
//decoder_664
reg [5:0] en_SIMD;
assign w_en_SIMD = en_SIMD;
//En_RAM
wire [11:0] w_feature_start;
wire [11:0] w_feature_stop;
assign w_feature_start = feature_start;
assign w_feature_stop  = feature_stop;

//-----------------------------------------------------
//模块例化
//------------------------------------------------------
//取特征的区间为[last_F,F1-1]					 
 S1_calculation U_S1Cal(
						.Fin(w_Fin1),
						.ini_in(w_ini_in),
						.last_F(w_F_start1),
						.F1(w_F_stop1)
					 );
					 
//e_i取[last_F,F21-1],e_i+1取[0,F22-1]
S2_calculation U_S2Cal(					
						.Fin(w_Fin2),
						.last_F(w_F_start21),
						// .F21(w_F_stop21),//需要输出吗？肯定是全取完
						.F22(w_F_stop22),
						.needMT64(w_need64)
					);
					
//取[last_F,F3-1]					
S3_calculation U_S3Cal(
						.Fin(w_Fin3),//来自S1或S2，状态机中完成选择
						.last_F(w_F_start3),
						.F3(w_F_stop3),//取[last_F,F3-1]
						.core3(w_core3),
						.done(w_done)
					 );
					 
//使能信号给64个SIMD核
decoder_664 U_decoder(
						.din(w_en_SIMD),
						.dout(en2SIMD)
					 );
					 
//使能信号给FeatureBuffer
En_RAM U_ERAM(
			  .feature_start(w_feature_start),
			  .feature_stop(w_feature_stop),
			  .Enable(en2Feature),
			  .RAM_start(w_RAM_start),
			  .RAM_stop(w_RAM_stop)
			);
//-----------------------------------------------------
//三段状态机
//------------------------------------------------------
//第一个进程，同步时序，次态迁移到现态
always @(posedge clk or negedge rst)//异步复位
begin
	if(!rst) current_state <= IDLE;
	else current_state <= next_state;
end

//第二个进程，组合逻辑，状态转移条件判断
always @(current_state)//带自循环的咋办？
begin
	next_state = IDLE;//初始化
	case(current_state)
	IDLE: 
		begin
	    if (Task == 1)
			next_stage = S1;
		end
		
	S1:
		begin
	    if (Task == 0)
			next_state = S3;
		else 
			next_state = S2;
		end
			
	S2:
		begin
	    if (w_need64 == 1) 
			next_state = S1;
			else begin
				if(Task == 1)
					next_state = S2;
				else 
					next_state = S3;
			end
		end
		
    S3: 
		begin
	    if (done == 1)
			next_stage = IDLE;
		end
	endcase
end

//第三个进程，同步时序，次态寄存器输出
always @(posedge clk or negedge rst)
begin
   //初始化

   case(next_state)
   
   IDLE:
		begin
			ini <= 1'b1;
			done <= 1'b0;
			need64 <= 1'b0;
			en_SIMD <= 6'b00_0000;
			feature_start <= w_F_start1;
		end
		
   S1:
		begin
			ini <= 0;
			done <= 1'b0;
			need64 <= 1'b0;
			en_SIMD <= 6'b11_1111;
			feature_start <= w_F_start1;
			feature_stop  <= w_F_stop1 - 1'b1;
		end
		
   S2:
		begin
			ini <= 0;
			done <= 1'b0;
			need64 <= w_need64;
			en_SIMD <= 6'b11_1111;
			Fin2 <= (current_state ==  S1) ? w_F_stop1 : w_F_stop22;
			feature_start <= w_F_start21;
			feature_stop  <= w_F_stop22 - 1'b1;
		end
		
   S3:
		begin
			ini <= 0;
			done <= w_done;
			need64 <= 1'b0;
			en_SIMD <= w_core3;
			Fin3 <= (current_state ==  S1) ? w_F_stop1 : w_F_stop22;
			feature_start <= w_F_start3;
			feature_stop  <= w_F_stop3 - 1'b1;
		end
		
	endcase
end

endmodule
