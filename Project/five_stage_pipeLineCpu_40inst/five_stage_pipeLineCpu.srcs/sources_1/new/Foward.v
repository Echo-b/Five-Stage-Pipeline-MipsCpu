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

`include "stddef.v"
module Foward(
    input [`DecodeRegBus] rs,
    input [`DecodeRegBus] rt,
    input [`DecodeRegBus] rsE,
    input [`DecodeRegBus] rtE,
    input [`DecodeRegBus] rtM,
    input [`DecodeRegBus] write_regM,
    input [`DecodeRegBus] write_regW,
    input regwriteM,
    input regwriteW,
    output reg [`ForwardBus] forwardalu_A,
    output reg [`ForwardBus] forwardalu_B,
    output reg [`ForwardBus] forwardcmpsrcA,
    output reg [`ForwardBus] forwardcmpsrcB,
    output reg forward_DM
    );
    
    always @ (*) begin
        forwardalu_A <= `DISABLE;
        forwardalu_B <= `DISABLE;
        forwardcmpsrcA <= `DISABLE;
        forwardcmpsrcB <= `DISABLE;
        forward_DM<=`DISABLE;
        
        if (write_regM == rsE && regwriteM && write_regM!=`RegZero) forwardalu_A <= `M2E_ALU; //读写寄存器相同，写使能有效，写寄存器不是零
        else if (write_regW == rsE && regwriteW &&write_regW!=`RegZero) forwardalu_A <= `W2E_ALU;

        if (write_regM == rtE && regwriteM && write_regM!=`RegZero) forwardalu_B <= `M2E_ALU;
        else if (write_regW == rtE && regwriteW &&write_regW!=`RegZero) forwardalu_B <= `W2E_ALU;
        
        if (write_regM == rs && regwriteM &&write_regM!=`RegZero) forwardcmpsrcA <= `M2E_ALU;
        else if (write_regW == rs && regwriteW &&write_regW!=`RegZero) forwardcmpsrcA <= `W2E_ALU;

        if (write_regM == rt && regwriteM &&write_regM!=`RegZero) forwardcmpsrcB <= `M2E_ALU;
        else if (write_regW == rt && regwriteW &&write_regW!=`RegZero) forwardcmpsrcB <= `W2E_ALU;
         
        if (write_regW == rtM && regwriteW) forward_DM <= `W2E_DM; 
    end
    
endmodule
