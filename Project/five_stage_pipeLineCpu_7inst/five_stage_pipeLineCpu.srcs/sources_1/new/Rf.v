`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:27:55
// Design Name: 
// Module Name: Rf
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


module Rf(
    input clk, reset,
    input we,
    input [4:0] ra, rb, rw,
    input [31:0] rd,
    output[31:0] qa, qb
);
    
    reg [31:0] register[31:0];
    integer i;
    
    always @(posedge clk, posedge reset) begin
        if (reset)
            for (i = 0; i < 32; i = i + 1)
		        register[i] <= 0;
	    else if ((rw != 0) && we)
	        register[rw] <= rd;
    end
    
    assign qa = (ra == 0) ? 0 : register[ra];
    assign qb = (rb == 0) ? 0 : register[rb];
    
endmodule





