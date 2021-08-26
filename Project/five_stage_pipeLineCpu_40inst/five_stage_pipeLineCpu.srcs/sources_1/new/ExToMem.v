`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:17:48
// Design Name: 
// Module Name: ExToMem
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
module ExToMem(
    input clk, reset,
    input regwriteE,
    input memtoregE,
    input memwriteE,       
    output reg regwriteM,
    output reg memtoregM,
    output reg memwriteM, 
    input [`DecodeRegBus] rtE,
    output reg [`DecodeRegBus] rtM,      
    input [`DataBus] alu_outE,
    output reg [`DataBus] alu_outM,
    input [`DataBus] write_dataE,
    output reg [`DataBus] write_dataM,
    input [`DecodeRegBus] write_regE,
    output reg [`DecodeRegBus] write_regM,
    input[`SWBus] din_storeE,
    output reg[`SWBus] din_storeM,
    input[`LWBus] dout_loadE,
    output reg[`LWBus] dout_loadM,
    input [`TnewBus] Tnew_E,
    output reg [`TnewBus] Tnew_M
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteM <= `DISABLE;
            memtoregM <= `DISABLE;
            memwriteM <= `DISABLE;
            alu_outM <= `DISABLE;
            rtM <= `DISABLE;
            write_dataM <= `DISABLE;
            write_regM <= `DISABLE;
            din_storeM<=`DISABLE;
            dout_loadM<=`DISABLE;
            Tnew_M <= `DISABLE;

        end
        else begin
            regwriteM <= regwriteE;
            memtoregM <= memtoregE;
            memwriteM <= memwriteE;
            rtM <= rtE;
            alu_outM <= alu_outE;
            write_dataM <= write_dataE;
            write_regM <= write_regE;
            din_storeM<=din_storeE;
            dout_loadM<=dout_loadE;
            if (Tnew_E > 0) 
                Tnew_M <= Tnew_E - 1;
        end
    end
endmodule
