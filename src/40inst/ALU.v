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

`include "stddef.v"
module ALU(
    input [`DataBus] a_in, b_in,
    input [`AluBus] aluc,
    output reg [`DataBus] alu_out
    );
    always @(*) begin
	    case(aluc) 
	        4'b0000: alu_out <= a_in + b_in; 
	        4'b0001: alu_out <= a_in - b_in;
	        4'b0010: alu_out <= a_in | b_in;
	        4'b0011: alu_out <= a_in & b_in;
	        4'b0100: alu_out <= a_in ^ b_in;
	        4'b0101: alu_out <= ~(a_in | b_in);
            4'b0110: begin
                if(($signed(a_in)) < ($signed(b_in)))begin
                    alu_out <= 1;
                end
            end
            4'b0111:alu_out<=b_in << a_in[`AluShamtRange];
            4'b1000:alu_out<=b_in >> a_in[`AluShamtRange];
            4'b1001:alu_out <= ($signed(b_in)) >>> a_in[`AluShamtRange];
		    default: alu_out <= a_in + b_in; 
	    endcase
    end
   
endmodule
