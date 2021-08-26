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


module IdToEx(
    input clk, reset,
    input regwriteD,
    input memtoregD,
    input memwriteD,
    input branchD,
    input [2:0] alucD,
    input alusrcD,
    input regdstD,
    input [1:0] extopD,
    input memreadD,
    output reg regwriteE,
    output reg memtoregE,
    output reg memwriteE,
    output reg [2:0] alucE,
    output reg alusrcE,
    output reg regdstE,
    output reg [1:0] extopE,
    output reg memreadE,
    input [31:0] qa, qb,
    output reg [31:0] a, b,
    input [4:0] rsD, rtD, rdD,
    output reg [4:0] rsE, rtE, rdE,
    input [31:0] ep_immD,
    output reg [31:0] ep_immE,
    input [31:0] pc_plus4D,
    output reg [31:0] pc_plus4E,
    input [1:0] Tnew,
    output reg [1:0] Tnew_E
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteE <= 0;
            memtoregE <= 0;
            memwriteE <= 0;
            alucE <= 0;
            alusrcE <= 0;
            regdstE <= 0;
            extopE <= 0;
            memreadE <= 0;
            a <= 0;
            b <= 0;
            rsE <= 0;
            rtE <= 0;
            rdE <= 0;
            ep_immE <= 0;
            pc_plus4E <= 0;
            Tnew_E <= 0;
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
            ep_immE <= ep_immD;
            pc_plus4E <= pc_plus4D;
            Tnew_E <= Tnew;
        end
    end
endmodule
