`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:14:15
// Design Name: 
// Module Name: exp
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


module exp(
    input [1:0] extop,
    input [15:0] imm,
    output reg [31:0] ep_imm
    );
    always @(extop, imm) begin
	    case(extop) 
	        2'b00: 
	            ep_imm <= imm;
	        2'b01: 
	           begin
	            if(imm[15] == 1) ep_imm <= imm + 32'hffff0000;
	            else ep_imm <= imm;
	            end
	        2'b10: 
	            ep_imm <= imm << 16;//lui
		    default: 
		        ep_imm <= imm;
	    endcase
    end
    
endmodule
