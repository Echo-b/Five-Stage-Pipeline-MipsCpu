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

`include "stddef.v"
module exp(
    input [`ExtOpBus] extop,
    input [`ImmBus] imm,
    output reg [`DataBus] ep_imm
    );
    always @(extop, imm) begin
	    case(extop) 
	        2'b00: 
	            ep_imm <= imm;
	        2'b01:
                ep_imm<={{`ImmLocBit{imm[`ImmHighestBit]}},imm}; 
	        2'b10: 
	            ep_imm <= imm << `ImmShiftBitNum;//lui
		    default: 
		        ep_imm <= imm;
	    endcase
    end
    
endmodule
