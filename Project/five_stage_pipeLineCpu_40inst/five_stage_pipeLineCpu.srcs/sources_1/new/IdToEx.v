`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:21:00
// Design Name: 
// Module Name: IdToEx
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
module IdToEx(
    input clk, reset,
    input regwriteD,
    input memtoregD,
    input memwriteD,
    input[`SWBus] din_storeD,
    output reg[`SWBus] din_storeE,
    input[`LWBus] dout_loadD,
    output reg[`LWBus] dout_loadE,
    input shamtsrcD,
    output reg shamtsrcE,
    input jalD,
    output reg jalE,
    input [`AluBus] alucD,
    input alusrcD,
    input regdstD,
    input [`ExtOpBus] extopD,
    input memreadD,
    output reg regwriteE,
    output reg memtoregE,
    output reg memwriteE,
    output reg [`AluBus] alucE,
    output reg alusrcE,
    output reg regdstE,
    output reg [`ExtOpBus] extopE,
    output reg memreadE,
    input [`DataBus] qa, qb,
    output reg [`DataBus] a, b,
    input [`DecodeRegBus] rsD, rtD, rdD,shamtD,
    output reg [`DecodeRegBus] rsE, rtE, rdE,shamtE,
    input [`DataBus] ep_immD,
    output reg [`DataBus] ep_immE,
    input [`InstBus] pc_plus4D,
    output reg [`InstBus] pc_plus4E,
    input [`TnewBus] Tnew,
    output reg [`TnewBus] Tnew_E
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteE <= `DISABLE;
            memtoregE <= `DISABLE;
            memwriteE <= `DISABLE;
            alucE <= `DISABLE;
            alusrcE <= `DISABLE;
            regdstE <= `DISABLE;
            extopE <= `DISABLE;
            memreadE <= `DISABLE;
            shamtsrcE<=`DISABLE;
            a <= `DISABLE;
            b <= `DISABLE;
            rsE <= `DISABLE;
            rtE <= `DISABLE;
            rdE <= `DISABLE;
            ep_immE <= `DISABLE;
            pc_plus4E <= `DISABLE;
            jalE<=`DISABLE;
            shamtE<=`DISABLE;
            din_storeE<=`DISABLE;
            dout_loadE<=`DISABLE;
            Tnew_E <= `DISABLE;
        end
        else begin
            regwriteE <= regwriteD;
            memtoregE <= memtoregD;
            memwriteE <= memwriteD;
            alucE <= alucD;
            alusrcE <= alusrcD;
            regdstE <= regdstD;
            extopE <= extopD;
            memreadE <= memreadD;
            a <= qa;
            b <= qb;
            rsE <= rsD;
            rtE <= rtD;
            rdE <= rdD;
            jalE<=jalD;
            din_storeE<=din_storeD;
            dout_loadE<=dout_loadD;
            ep_immE <= ep_immD;
            pc_plus4E <= pc_plus4D;
            shamtE<=shamtD;
            shamtsrcE<=shamtsrcD;
            Tnew_E <= Tnew;
        end
    end
endmodule
