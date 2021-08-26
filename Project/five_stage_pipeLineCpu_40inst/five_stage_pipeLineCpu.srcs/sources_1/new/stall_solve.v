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
`include "stddef.v"
//清零主控制信号也就是E级寄存器传递的值
module stall_solve(
    input nop,
    input regwrite,
    input[`AluBus] aluc,
    input alusrc,
    input regdst,
    input memtoreg,
    input memwrite,
    input[`ExtOpBus] extop,
    input [`BranchBus]branch,
    input memread,
    input shamtsrc,
    input jal,
    input j,
    input jr,
    input [`SWBus] din_store,
    input [`LWBus] dout_load,
    output jalD,
    output jrD,
    output jD,
    output [`SWBus] din_storeD,
    output [`LWBus] dout_loadD,
    output shamtsrcD,
    output regwriteD,
    output[`AluBus] alucD,
    output alusrcD,
    output regdstD,
    output memtoregD,
    output memwriteD,
    output[`ExtOpBus] extopD,
    output [`BranchBus] branchD,
    output memreadD

    );
    assign regwriteD = nop ? `DISABLE : regwrite;
    assign alucD = nop ? `DISABLE : aluc;
    assign alusrcD = nop ? `DISABLE : alusrc;
    assign regdstD = nop ? `DISABLE : regdst;
    assign memtoregD = nop ? `DISABLE : memtoreg;
    assign memwriteD = nop ? `DISABLE : memwrite;
    assign extopD = nop ? `DISABLE : extop;
    assign branchD = nop ? `DISABLE : branch;
    assign memreadD = nop ? `DISABLE : memread;
    assign shamtsrcD=nop?`DISABLE:shamtsrc;
    assign din_storeD=nop?`DISABLE:din_store;
    assign dout_loadD=nop?`DISABLE:dout_load;
    assign jD = nop ? `DISABLE : j;
    assign jalD = nop ? `DISABLE : jal;
    assign jrD = nop ? `DISABLE : jr;
    
endmodule
