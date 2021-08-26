`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:28:29
// Design Name: 
// Module Name: CMP
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


module CMP(
    input [1:0] forwardcmpsrcA, forwardcmpsrcB,
    input [31:0] qa, qb, alu_outM, resultW,
    input branch,j,
    output zero,    
    output reg [31:0] cmp_a,
    output reg [31:0] cmp_b,
    output[1:0] pcsrc
    );

    always @(*) begin
        case(forwardcmpsrcA)
            0: cmp_a <= qa;
            1: cmp_a <= resultW;
            2: cmp_a <= alu_outM;
        endcase
        
        case(forwardcmpsrcB)
            0: cmp_b <= qb;
            1: cmp_b <= resultW;
            2: cmp_b <= alu_outM;
        endcase
    end
    
    assign zero =(cmp_a == cmp_b) ? 1 : 0;
    assign pcsrc[0] = j;//2'b01
    assign pcsrc[1] = branch && zero;//2'b10，相等跳转

endmodule
