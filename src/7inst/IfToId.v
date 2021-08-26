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


module IfToId(
    input clk, reset,
    input if_idwrite,
    input flush,
    input [31:0] is,
    input [31:0] pc_plus4F,
    output [5:0] op,
    output [5:0] func,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [15:0] imm,
    output [25:0] adr,
    output reg [31:0] pc_plus4D
    );
    reg [31:0] instruct;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruct <= 0;
            pc_plus4D <= 0;
        end
        else if(flush)begin
            instruct<=0; 
        end
        else if(if_idwrite) begin
            instruct <= is;
            pc_plus4D <= pc_plus4F;
        end
    end
    
    assign op = instruct [31:26];
    assign func = instruct [5:0];
    assign rs = instruct [25:21];
    assign rt = instruct [20:16];
    assign rd = instruct [15:11];
    assign imm = instruct [15:0];
    assign adr = instruct [25:0];
    
endmodule
