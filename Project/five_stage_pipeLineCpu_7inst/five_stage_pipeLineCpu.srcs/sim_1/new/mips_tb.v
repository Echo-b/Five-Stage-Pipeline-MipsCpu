`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 21:11:44
// Design Name: 
// Module Name: mips_tb
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


module mips_tb;
    reg clk;
    reg reset;
    
    pipelinecpu uut(
        .clk(clk),
        .reset(reset)
    );
    initial
	begin
	  clk = 0;
	  reset = 1;
	  #1;
	  reset = 0;
	  forever #1 clk = ~clk;
	end	
	

endmodule
