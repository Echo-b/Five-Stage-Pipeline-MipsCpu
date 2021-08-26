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

`include "stddef.v"
module NPC(
    input[`PcSrcBus] pcsrc,
    input[`InstBus] pc_plus4F,
    input[`ExtAdrBus] jump_adr,
    input[`InstBus] pc_branchD,
    output reg[`InstBus] npc
    );
    always @(*) begin
        case(pcsrc)
        2'b00: npc <= pc_plus4F;
        2'b01: npc <= jump_adr;
        2'b10: npc <= pc_branchD;
        default:; 
        endcase
    end
endmodule
