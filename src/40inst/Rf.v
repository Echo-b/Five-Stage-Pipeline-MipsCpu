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

`include "stddef.v"
module Rf(
    input clk, reset,
    input we,
    input [`DecodeRegBus] ra, rb, rw,
    input [`DataBus] rd,
    output[`DataBus] qa, qb
);
    
    reg [`DataBus] register[`RegNum-1:0];
    integer i;
    
    always @(posedge clk, posedge reset) begin
        if (reset)
            for (i = 0; i < `RegNum; i = i + 1)
		        register[i] <= `DISABLE;
	    else if ((rw != 0) && we)
	        register[rw] <= rd;
    end
    
    assign qa = (ra == 0) ? `DataInit : register[ra];
    assign qb = (rb == 0) ? `DataInit : register[rb];
    
endmodule





