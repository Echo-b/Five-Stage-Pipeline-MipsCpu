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

`include "stddef.v"
module HazardUnit(
    input stall,
    output reg pcwrite,
    output reg if_idwrite,
    output reg nop
    );
    always @ * begin
        pcwrite = `ENABLE;
        if_idwrite = `ENABLE;
        nop = `DISABLE;
        if (stall) begin
            pcwrite = `DISABLE;//pc不使能，pc停在当前指令
            if_idwrite = `DISABLE;//D级寄存器不写,停在当前指令
            nop = `ENABLE;//做后续信号的清空
        end
    end
endmodule
