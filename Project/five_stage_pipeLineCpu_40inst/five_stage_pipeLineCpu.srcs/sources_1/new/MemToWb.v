`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:27:40
// Design Name: 
// Module Name: MemToWb
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
module MemToWb(
    input clk, reset,
    input regwriteM,
    input memtoregM,
    output reg regwriteW,
    output reg memtoregW,
    input [`DataBus] alu_outM,
    output reg [`DataBus] alu_outW,
    input [`DataBus] dm_outM,
    output reg [`DataBus] dm_outW,
    input [`DecodeRegBus] write_regM,
    output reg [`DecodeRegBus] write_regW
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteW <= `DISABLE;
            memtoregW <= `DISABLE;
            alu_outW <= `DISABLE;
            dm_outW <= `DISABLE;
            write_regW <= `DISABLE;
        end
        else begin
            regwriteW <= regwriteM;
            memtoregW <= memtoregM;
            alu_outW <= alu_outM;
            dm_outW <= dm_outM;
            write_regW <= write_regM;
        end
    end
endmodule
