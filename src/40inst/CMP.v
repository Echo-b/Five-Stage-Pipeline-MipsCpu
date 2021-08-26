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

`include "stddef.v"
module CMP(
    input [`ForwardBus] forwardcmpsrcA, forwardcmpsrcB,
    input [`DataBus] qa, qb, alu_outM, resultW,
    input j,jal,jr,
    input [`BranchBus] branchD,
    output zero,
    output equal_zero,
    output grater_than_zero,
    output less_than_zero,
    // output not_equal,
    output reg [`DataBus] cmp_a,
    output reg [`DataBus] cmp_b,
    output[`PcSrcBus] pcsrc
    );

    always @(*) begin
        case(forwardcmpsrcA)
            2'b00: cmp_a <= qa;
            2'b01: cmp_a <= resultW;
            2'b10: cmp_a <= alu_outM;
        endcase
        
        case(forwardcmpsrcB)
            2'b00: cmp_b <= qb;
            2'b01: cmp_b <= resultW;
            2'b10: cmp_b <= alu_outM;
        endcase
    end
  
    // assign grater_than_zero=(cmp_a>0)?1:0;
    // assign equal_zero=(cmp_a==0)?1:0;
    // assign less_than_zero=(cmp_a<0)?1:0;
    assign zero =(cmp_a == cmp_b) ? 1 : 0;
    // assign not_equal=(cmp_a!=cmp_b)?1:0;
    assign equal_zero = ($signed(cmp_a))  == 0;
    assign grater_than_zero = ($signed(cmp_a)) > 0;
    assign less_than_zero = ($signed(cmp_a))  < 0;

    assign pcsrc[0] = j|jal|jr;//2'b01
    assign pcsrc[1] = (branchD == 1 && zero) || (branchD == 2 && zero == 0) || (branchD == 3 && (equal_zero | less_than_zero)) || (branchD == 4 && grater_than_zero)  || (branchD == 6 && equal_zero);
    // assign pcsrc[1] = (branchD &&(equal_zero|less_than_zero)|grater_than_zero|equal_zero|~zero|zero );
    // assign pcsrc[1] = (branch && zero)||(branch && lager_zero)||(branch && lager_equal_zero)||(branch && less_equal_zero)||(branch && not_equal);//2'b10，相等跳转
    // assign pcsrc[1] = (branchD == 1 && zero) || (branchD == 2 && zero == 0) || (branchD == 3 && (ltz&eqz)) || (branchD == 4 &&  ) || (branchD == 6 && );
endmodule
