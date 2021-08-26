`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:24:06
// Design Name: 
// Module Name: DM
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


module DM(
    input clk, reset,
    input we,
    input [31:0] addr,
    input [31:0] d_in,
    output [31:0] d_out
    );
    
    reg [31:0] ram[255:0];
    integer i;
    
    assign d_out = ram[addr];
    
    always @(posedge clk, posedge reset) begin
	    if (reset)
            for (i = 0; i < 256; i = i + 1)
		        ram[i] <= 0;
	    else if (we == 1)
		    ram[addr] <= d_in;
    end
endmodule
