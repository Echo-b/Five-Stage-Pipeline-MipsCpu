`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:26:47
// Design Name: 
// Module Name: IfToId
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
module IfToId(
    input clk, reset,
    input if_idwrite,
    input flush,
    input [`InstBus] is,
    input [`InstBus] pc_plus4F,
    output [`OpBus] op,
    output [`FuncBus] func,
    output [`DecodeRegBus] rs,
    output [`DecodeRegBus] rt,
    output [`DecodeRegBus] rd,
    output [`ShamtBus] shamt,
    output [`ImmBus] imm,
    output [`AddrBus] adr,
    output reg [`InstBus] pc_plus4D
    );
    reg [`InstBus] instruct;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruct <= `DISABLE;
            pc_plus4D <= `DISABLE;
        end
        else if(flush)begin
            instruct<=`DISABLE; 
        end
        else if(if_idwrite) begin
            instruct <= is;
            pc_plus4D <= pc_plus4F;
        end
    end
    
    assign op = instruct [`OpRange];
    assign func = instruct [`FuncRange];
    assign rs = instruct [`RsRange];
    assign rt = instruct [`RtRange];
    assign rd = instruct [`RdRange];
    assign imm = instruct [`ImmRange];
    assign adr = instruct [`AdrRange];
    assign shamt =instruct[`ShamtRange];
    
endmodule
