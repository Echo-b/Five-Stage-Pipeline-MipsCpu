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


module MFA(
    input[1:0] forwardalu_A,
    input[31:0] a_in,
    input[31:0] resultW ,
    input[31:0] alu_outM,
    output reg[31:0] alu_a
    );
    always @(*) begin
        case(forwardalu_A)
            2'b00: alu_a <= a_in;
            2'b01: alu_a <= resultW;//W向E转发ALU结果
            2'b10: alu_a <= alu_outM;//M向E转发ALU结果
        endcase
    end
    
endmodule
