`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:47:43
// Design Name: 
// Module Name: NPC
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


module NPC(
    input[1:0] pcsrc,
    input[31:0] pc_plus4F,
    input[31:0] jump_adr,
    input[31:0] pc_branchD,
    output reg[31:0] npc
    );
    always @(*) begin
        case(pcsrc)
        2'b00: npc <= pc_plus4F;
        2'b01: npc <= jump_adr;
        2'b10: npc <= pc_branchD;
        
        endcase
    end
endmodule
