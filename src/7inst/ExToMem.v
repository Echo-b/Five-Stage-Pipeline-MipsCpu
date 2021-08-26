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


module ExToMem(
    input clk, reset,
    input regwriteE,
    input memtoregE,
    input memwriteE,       
    output reg regwriteM,
    output reg memtoregM,
    output reg memwriteM, 
    input [4:0] rtE,
    output reg [4:0] rtM,      
    input [31:0] alu_outE,
    output reg [31:0] alu_outM,
    input [31:0] write_dataE,
    output reg [31:0] write_dataM,
    input [4:0] write_regE,
    output reg [4:0] write_regM,
    input [1:0] Tnew_E,
    output reg [1:0] Tnew_M
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteM <= 0;
            memtoregM <= 0;
            memwriteM <= 0;
            alu_outM <= 0;
            rtM <= 0;
            write_dataM <= 0;
            write_regM <= 0;
            Tnew_M <= 0;

        end
        else begin
            regwriteM <= regwriteE;
            memtoregM <= memtoregE;
            memwriteM <= memwriteE;
            rtM <= rtE;
            alu_outM <= alu_outE;
            write_dataM <= write_dataE;
            write_regM <= write_regE;
            if (Tnew_E > 0) 
                Tnew_M <= Tnew_E - 1;
        end
    end
endmodule
