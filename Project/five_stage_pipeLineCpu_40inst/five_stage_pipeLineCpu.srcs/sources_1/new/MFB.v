`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/04 08:47:02
// Design Name: 
// Module Name: MFB
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
module MFB(
    input[`ForwardBus] forwardalu_B,
    input[`DataBus] b_in,
    input[`DataBus] resultW,
    input[`DataBus] alu_outM,
    output reg[`DataBus] alu_b1
    );
    always @(*) begin
        case(forwardalu_B)
            `Normal_Input: alu_b1 <= b_in;
            `W2E_ALU: alu_b1 <= resultW;//W向E转发ALU结果
            `M2E_ALU: alu_b1 <= alu_outM;//M向E转发ALU结果
        endcase
    end
endmodule


