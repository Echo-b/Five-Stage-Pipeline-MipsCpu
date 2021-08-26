`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:28:12
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] a_in, b_in,
    input [2:0] aluc,
    output reg [31:0] alu_out
    );
    always @(*) begin
	    case(aluc) 
	        3'b000: alu_out <= a_in + b_in; 
	        3'b001: alu_out <= a_in - b_in;
	        3'b010: alu_out <= a_in | b_in;
	        3'b011: alu_out <= a_in & b_in;
	        3'b100: alu_out <= a_in ^ b_in;
	        3'b101: alu_out <= ~(a_in | b_in);
		    default: alu_out <= a_in + b_in; 
	    endcase
    end
endmodule
