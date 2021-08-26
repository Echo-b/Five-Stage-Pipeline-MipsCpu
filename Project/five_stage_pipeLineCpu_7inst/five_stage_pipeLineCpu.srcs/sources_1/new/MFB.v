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


module MFB(
    input[1:0] forwardalu_B,
    input[31:0] b_in,
    input[31:0] resultW,
    input[31:0] alu_outM,
    output reg[31:0] alu_b1
    );
    always @(*) begin
        case(forwardalu_B)
            0: alu_b1 <= b_in;
            1: alu_b1 <= resultW;//W向E转发ALU结果
            2: alu_b1 <= alu_outM;//M向E转发ALU结果
        endcase
    end
endmodule


