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

`include "stddef.v"
module IM(
    input [`ExtAdrBus] in_adr,
    output [`InstBus] is
    );
    reg[`DataBus] mem [`MemNum-1:0] ;//32*1024
    integer i;
    initial begin
        for(i=0;i<`MemNum;i=i+1)begin
            mem[i]=`DataInit;
        end
    end
    initial begin
        $readmemh("code.txt",mem);
    end
    assign is=mem[in_adr[9:2]];    //按字编址改为按字节编址
   
endmodule
