`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/04 09:08:53
// Design Name: 
// Module Name: stall_solve
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

//清零主控制信号也就是E级寄存器传递的值
module stall_solve(
    input nop,
    input regwrite,
    input[2:0] aluc,
    input alusrc,
    input regdst,
    input memtoreg,
    input memwrite,
    input[1:0] extop,
    input branch,
    input memread,
    output regwriteD,
    output[2:0] alucD,
    output alusrcD,
    output regdstD,
    output memtoregD,
    output memwriteD,
    output[1:0] extopD,
    output branchD,
    output memreadD

    );
    assign regwriteD = nop ? 0 : regwrite;
    assign alucD = nop ? 0 : aluc;
    assign alusrcD = nop ? 0 : alusrc;
    assign regdstD = nop ? 0 : regdst;
    assign memtoregD = nop ? 0 : memtoreg;
    assign memwriteD = nop ? 0 : memwrite;
    assign extopD = nop ? 0 : extop;
    assign branchD = nop ? 0 : branch;
    assign memreadD = nop ? 0 : memread;
    
endmodule
