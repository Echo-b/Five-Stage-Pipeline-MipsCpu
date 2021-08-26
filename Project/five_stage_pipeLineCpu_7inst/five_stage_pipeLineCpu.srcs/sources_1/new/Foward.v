`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:26:00
// Design Name: 
// Module Name: Foward
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


module Foward(
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rsE,
    input [4:0] rtE,
   // input [4:0] rtM,
    input [4:0] write_regM,
    input [4:0] write_regW,
    input regwriteM,
    input regwriteW,
    output reg [1:0] forwardalu_A,
    output reg [1:0] forwardalu_B,
    output reg [1:0] forwardcmpsrcA,
    output reg [1:0] forwardcmpsrcB
    //output reg forward_DM
    );
    `define M2E_ALU 2 //M向E转发ALU结果
    `define W2E_ALU 1 //W向E转发ALU结果
    
    always @ (*) begin
        forwardalu_A <= 0;
        forwardalu_B <= 0;
        forwardcmpsrcA <= 0;
        forwardcmpsrcB <= 0;
        //forward_DM<=0;
        
        if (write_regM == rsE && regwriteM && write_regM!=0) forwardalu_A <= `M2E_ALU; //读写寄存器相同，写使能有效，写寄存器不是零
        else if (write_regW == rsE && regwriteW &&write_regW!=0) forwardalu_A <= `W2E_ALU;

        if (write_regM == rtE && regwriteM && write_regM!=0) forwardalu_B <= `M2E_ALU;
        else if (write_regW == rtE && regwriteW &&write_regW!=0) forwardalu_B <= `W2E_ALU;
        
        if (write_regM == rs && regwriteM &&write_regM!=0) forwardcmpsrcA <= `M2E_ALU;
        else if (write_regW == rs && regwriteW &&write_regW!=0) forwardcmpsrcA <= `W2E_ALU;

        if (write_regM == rt && regwriteM &&write_regM!=0) forwardcmpsrcB <= `M2E_ALU;
        else if (write_regW == rt && regwriteW &&write_regW!=0) forwardcmpsrcB <= `W2E_ALU;
         
       // if (write_regW == rtM && regwriteW) forward_DM <= 1;
    end
    
endmodule
