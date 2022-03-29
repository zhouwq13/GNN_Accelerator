`timescale 1ns / 1ps

module SIMD_add(
        input [127:0] A, //8bit,16lane
        input [127:0] B,
        input sub, //判断是否是减法
        output [127:0] Cout
				);
	

    wire [127:0] B_real = sub?(~B):B; //是否取反
	
    wire [7:0] C0 = A[7:0]    +  B_real[7:0]    + sub; //如果是减法，补码表示成取反加一
    wire [7:0] C1 = A[15:8]   +  B_real[15:8]   + sub;
    wire [7:0] C2 = A[23:16]  +  B_real[23:16]  + sub;
    wire [7:0] C3 = A[31:24]  +  B_real[31:24]  + sub;
    wire [7:0] C4 = A[39:32]  +  B_real[39:32]  + sub; 
    wire [7:0] C5 = A[47:40]  +  B_real[47:40]  + sub;
    wire [7:0] C6 = A[55:48]  +  B_real[55:48]  + sub;
    wire [7:0] C7 = A[63:56]  +  B_real[63:56]  + sub;
	wire [7:0] C8 = A[71:64]  +  B_real[71:64]  + sub; 
    wire [7:0] C9 = A[79:72]  +  B_real[79:72]  + sub;
    wire [7:0] C10 = A[87:80]   +  B_real[87:80]   + sub;
    wire [7:0] C11 = A[96:88]   +  B_real[96:88]   + sub;
    wire [7:0] C12 = A[104:96]    +  B_real[104:96]    + sub; 
    wire [7:0] C13 = A[112:104]   +  B_real[112:104]   + sub;
    wire [7:0] C14 = A[120:112]   +  B_real[120:112]   + sub;
    wire [7:0] C15 = A[128:120]   +  B_real[128:120]   + sub;
	
    assign Cout = {C15[7:0],C14[7:0],C13[7:0],C12[7:0],C11[7:0],C10[7:0],C9[7:0],C8[7:0],C7[7:0],C6[7:0],C5[7:0],C4[7:0],C3[7:0],C2[7:0],C1[7:0],C0[7:0]};

endmodule
