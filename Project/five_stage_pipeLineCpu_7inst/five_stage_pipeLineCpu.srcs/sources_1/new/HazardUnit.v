`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:20:02
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
    input stall,
    output reg pcwrite,
    output reg if_idwrite,
    output reg nop
    );
    always @ * begin
        pcwrite = 1;
        if_idwrite = 1;
        nop = 0;
        if (stall) begin
            pcwrite = 0;//pc不使能，pc停在当前指令
            if_idwrite = 0;//D级寄存器不写,停在当前指令
            nop = 1;//做后续信号的清空
        end
    end
endmodule
