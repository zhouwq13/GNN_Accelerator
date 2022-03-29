`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/15 10:46:56
// Design Name: 
// Module Name: SIMD_top
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
// 输出存到Aggr Buffer，buffer直接设置成256Bit的
//////////////////////////////////////////////////////////////////////////////////
module SIMD_top(
        input clk,
        input rst,
        input opcode,		//1bit commmand 加或减
		input tag,
        input [255:0]Src_A,
		input [255:0]Src_B,	//源操作数 （8bit operand A+ 8bit operand B)×32land=共512 bit 第一回合从边调度器拿，后面中间结果都从AggrBuffer拿
        input [9:0] data_address, 	//输入指定。一个CORE一个表项，一个表项128bit 中间结果存在哪，下一回合就从哪拿,位数由AGGGRBUFFER决定
		output [127:0] data_out,	//输出 存到AggrBuffer
        output state,              //输出给边调度器
		output data_R,
        output data_W
				);
    
    //5个经典状态及空闲、阻塞 --只需要三个
    parameter [2:0] STATE_IDLE = 0;
    parameter [2:0] STATE_ID = 2;
    parameter [2:0] STATE_EX = 3;
	parameter [2:0] STATE_WB = 4;

    reg [2:0] current_state;
    // reg [9:0] current_data_address;
    reg [127:0] data_out_reg;
	    //control register 在底下ID部分解释
    reg CMD_addition;
    reg CMD_substruction;
	
	    //result register
    reg [127:0] result_reg_add;
    reg [127:0] result_reg_sub;
	reg rdata_en;
    reg wdata_en;
    assign data_R = rdata_en;
    assign data_W = wdata_en;
	
    assign data_out = CMD_addition ? result_reg_add : result_reg_sub;
    // assign data_address = current_data_address;
	assign state = current_state;
     


    wire [127:0] comp_input_A = data_in[127:0];
    wire [127:0] comp_input_B = data_in[255:128];
    
    wire [127:0] Add_output_Cout;
//--------------------------------------------------------------------   
//------------------------------模块例化
//--------------------------------------------------------------------
    SIMD_add Add(
            .A(comp_input_A),
            .B(comp_input_B),
            .sub(CMD_substruction),
            .Cout(Add_output_Cout)
				);                                      
//--------------------------------------------------------------------   
//------------------------------state machine
//--------------------------------------------------------------------
    always @(posedge clk)
    begin
        if (rst) 
        begin
            current_state <= STATE_IDLE;
            // PC <= 0;
        end
        else
        begin

			if (current_state == STATE_IDLE)
            begin
                current_state <= STATE_ID;
            end
            else if (current_state == STATE_ID)
            begin
                current_state <= STATE_EX;
            end
            else if (current_state == STATE_EX)
            begin
                current_state <= STATE_IDLE;
            end           
        end
    end         
//--------------------------------------------------------------------------------    
//--------------------------------STATE_ID 
//---------------------------------------------------------------------------------
    always @(posedge clk)
    begin
        if (rst || current_state == STATE_IDLE ) 
        begin
            CMD_addition <= 0;
            CMD_substruction <= 0;
        end
		
        else
        begin
            if (current_state == STATE_ID)
            begin

                //cmd
                CMD_addition <= (opcode == 0);//0加1减
                CMD_substruction <= (opcode == 1);

                // $display("PC: %0d : instruction = %b", PC,instruction_in);
            end            
        end
    end    
//--------------------------------------------------------------------------------------    
//----------------------------STATE_EX
//--------------------------------------------------------------------------------------    
    always @(posedge clk)//STATE_EX
    begin
        if (rst || current_state == STATE_IDLE) 
        begin
            result_reg_add <= 0;
            result_reg_sub <= 0;
			rdata_en <= 0;
            wdata_en <= 0;
            // current_data_address <= 0;
        end
        
        else if (current_state == STATE_EX)
        begin
  
            if (CMD_addition) // do addition
            begin
                result_reg_add <= Add_output_Cout;				
            end 
            
            else if (CMD_substruction) // do substruction
            begin
                result_reg_sub <= Add_output_Cout;
            end                                   
        end                    
    end
//--------------------------------------------------------------------------------------    
//----------------------------STATE_WB 这里指写进BUFFER	
//--------------------------------------------------------------------------------------   
    always @(posedge clk)//STATE_WB
    begin
        if (rst || current_state == STATE_IDLE) 
        begin
        end
        
        else if (current_state == STATE_WB)
        begin
			wdata_en <= 1;
		end
	end
	
endmodule
