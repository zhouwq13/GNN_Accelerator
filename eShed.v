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
			 clk;
			 rst;
			 edg;
			 en2SIMD;
			 addr2Edge;
			 addr2Feature;
			 en2Feature;
			 feature_start;
			 feature_stop;
    );
//-----------------------------------------------------
//端口声明
//------------------------------------------------------
input clk;
input rst;
input  [23:0] edg;
output [63:0] en2SIMD;
output [4:0]  addr2Edge;//获取边表
output [11:0] addr2Feature1;//获取src特征
output [11:0] addr2Feature2;//获取dst特征
output [5:0]  en2Feature;//6个RAM的读使能
output [11:0] feature_start;//开始特征维度
output [11:0] feature_stop;//结束特征维度
//-----------------------------------------------------
//状态定义
//------------------------------------------------------
reg [1:0] current_state;
reg [1:0] next_state;

localparam IDLE = 00;
localparam S1 = 01;
localparam S2 = 10;
localparam S3 = 11;

reg [5:0] core1;//记录核使用状态，最多64个
reg [5:0] core21;
reg [5:0] core22;
reg [5:0] core3;

reg counter;//记录拿了多少个边,
//-----------------------------------------------------
//连线声明
//------------------------------------------------------
//模块内互联线

wire ID1; //连接ID1和两个模块的last_ID
wire ID22;			
wire core22;		 
wire lastID3;
assign lastID3 = ( current_state == S1 ) ? ID1 : ID22;
//直接输出 无内部连接的线
wire ID21;
wire core21;
wire m;
wire need64;

wire [11:0] S2E_Core//S2状态下的SIMD核使能
assign S2E_Core = { [5:0]core22, [5:0]core21};

//-----------------------------------------------------
//模块例化
//------------------------------------------------------
S1_calculation U_S1Cal(
						.last_ID(ID22),
						.ID1(ID1)
					 );
					 

//S2是 从S1或S2过来的，如果是S1过来，取特征范围【ID1+1,ID22】
S2_calculation  U_S2Cal(					
						.last_ID(ID1),
						core21,
						.core22(core22),
						ID21,
						.ID22(ID22),
						m,
						need64
							);
						
S3_calculation(
						.last_ID(lastID3),
						ID3,
						.core22(core22),
						core3
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
	     if (Task == 1)
		 next_stage = S1;
	S1:
	     if (Task == 0)
		 next_stage = S3;
		 else 
		 next_stage = S2;
	S2: 
	     if (need64 == 1)
		 next_stage = S1;
		 else 
		 next_stage = S2;
    S3: 
	     if (done == 1)
		 next_stage = IDLE;
	endcase
end

//第三个进程，同步时序，次态寄存器输出
always @(posedge clk or negedge rst)
begin
   //初始化
   
   case(next_state)
   IDLE:
   
   S1:
	  en2SIMD <= 6'b11_1111;
	  core1 <= 6'b11_1111;
	  addr2Edge <= counter;
	  addr2Feature1 <= edg[11:0];//src节点
	  addr2Feature2 <= edg[23:12];//dst节点
	  en2Feature <= 6'b00_1111; //拿的特征是第几个？？要记录前面的数
	  
   S2:
      en2SIMD <= S2E_Core;
   S3:
   
end	
endmodule
