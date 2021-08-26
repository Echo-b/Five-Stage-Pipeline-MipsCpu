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


module PC(
    input clk, reset,
    input pcwrite,
    input [31:0] adr,
    output [31:0] data 
    );
    reg [31:0] inst;
    
    assign data = inst;

    always @(posedge clk, posedge reset) begin
        if (reset) 
            inst <= 0;
        else if (pcwrite) 
            inst <= adr;
    end
endmodule
