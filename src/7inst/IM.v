`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:26:19
// Design Name: 
// Module Name: IM
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


module IM(
    input [31:0] in_adr,
    output j,
    output [31:0] is
    );
    reg[31:0] mem [127:0] ;//32*128
    integer i;
    initial begin
        for(i=0;i<128;i=i+1)begin
            mem[i]=32'h00000000;
        end
    end
    initial begin
        $readmemh("D:/Desktop/Project/five_stage_pipeLineCpu/code.txt",mem);
    end
    assign is=mem[in_adr];
    assign j=~is[31]&~is[30]&~is[29]&~is[28]&is[27]&~is[26];//000010
    //jump指令
   
endmodule
