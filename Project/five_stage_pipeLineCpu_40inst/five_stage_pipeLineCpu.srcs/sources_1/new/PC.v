`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:27:11
// Design Name: 
// Module Name: PC
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
module PC(
    input clk, reset,
    input pcwrite,
    input [`InstBus] adr,
    output [`DataBus] data 
    );
    reg [`InstBus] inst;
    
    assign data = inst;

    always @(posedge clk, posedge reset) begin
        if (reset) 
            inst <= `DISABLE;
        else if (pcwrite) 
            inst <= adr;
    end
endmodule
