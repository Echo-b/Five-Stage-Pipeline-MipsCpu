`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/04 08:46:44
// Design Name: 
// Module Name: MFA
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
module MFA(
    input[`ForwardBus] forwardalu_A,
    input[`DataBus] a_in,
    input[`DataBus] resultW ,
    input[`DataBus] alu_outM,
    output reg[`DataBus] alu_a
    );
    always @(*) begin
        case(forwardalu_A)
            `Normal_Input: alu_a <= a_in;
            `W2E_ALU: alu_a <= resultW;//W向E转发ALU结果
            `M2E_ALU: alu_a <= alu_outM;//M向E转发ALU结果
        endcase
    end
    
endmodule
