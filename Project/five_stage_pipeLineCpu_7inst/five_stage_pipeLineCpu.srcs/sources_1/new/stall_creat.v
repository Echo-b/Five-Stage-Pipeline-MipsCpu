`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/04 10:55:52
// Design Name: 
// Module Name: stall_creat
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


module stall_creat(
    input stall_rs, stall_rt, stall_rs0_E1, stall_rs0_E2,
    input stall_rs1_E2, stall_rs0_M1, stall_rt0_E1, stall_rt0_E2, stall_rt1_E2, stall_rt0_M1,
    input Tuse_rs0, Tuse_rs1, Tuse_rt0, Tuse_rt1, Tuse_rt2,
    input [1:0]Tnew_E, Tnew_M,
    input [4:0]ra,rb,
    input [4:0]write_regE,
    input [4:0]write_regM,
    input regwriteE,
    input memwriteM, 
    output stall
    );
    //Tuse_rs0 0=>beq jr j
    // Tnew_E==1 ALU运算类指令

    //Tuse_rs0 0=>beq jr j
    // Tnew_E==2  lw

    //Tuse_rs0 0=>beq jr j
    // Tnew_M==1  lw

    //Tuse_rs1 cal_r cal_i 运算类指令
    // Tnew_E==1  lw

    assign stall_rs0_E1 = Tuse_rs0 & (Tnew_E == 1) & (ra == write_regE) & regwriteE;
                        // beq        cal              equal/not equal       true/false
    assign stall_rs0_E2 = Tuse_rs0 & (Tnew_E == 2) & (ra == write_regE) & regwriteE;
    assign stall_rs1_E2 = Tuse_rs1 & (Tnew_E == 2) & (ra == write_regE) & regwriteE;
    assign stall_rs0_M1 = Tuse_rs0 & (Tnew_M == 1) & (ra == write_regM) & memwriteM;

    assign stall_rt0_E1 = Tuse_rt0 & (Tnew_E == 1) & (rb == write_regE) & regwriteE;
    assign stall_rt0_E2 = Tuse_rt0 & (Tnew_E == 2) & (rb == write_regE) & regwriteE;
    assign stall_rt1_E2 = Tuse_rt1 & (Tnew_E == 2) & (rb == write_regE) & regwriteE;
    assign stall_rt0_M1 = Tuse_rt0 & (Tnew_M == 1) & (rb == write_regM) & memwriteM;

    assign stall_rs = stall_rs0_E1 | stall_rs0_E2 | stall_rs1_E2 | stall_rs0_M1;
    assign stall_rt = stall_rt0_E1 | stall_rt0_E2 | stall_rt1_E2 | stall_rt0_M1;

    assign stall = stall_rs | stall_rt;
endmodule
