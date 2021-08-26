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


module MemToWb(
    input clk, reset,
    input regwriteM,
    input memtoregM,
    output reg regwriteW,
    output reg memtoregW,
    input [31:0] alu_outM,
    output reg [31:0] alu_outW,
    input [31:0] dm_outM,
    output reg [31:0] dm_outW,
    input [4:0] write_regM,
    output reg [4:0] write_regW
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteW <= 0;
            memtoregW <= 0;
            alu_outW <= 0;
            dm_outW <= 0;
            write_regW <= 0;
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
