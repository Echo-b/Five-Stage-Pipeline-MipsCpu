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

`include "stddef.v"
module stall_creat(
    input stall_rs, stall_rt, stall_rs0_E1, stall_rs0_E2,
    input stall_rs1_E2, stall_rs0_M1, stall_rt0_E1, stall_rt0_E2, stall_rt1_E2, stall_rt0_M1,
    input Tuse_rs0, Tuse_rs1, Tuse_rt0, Tuse_rt1, Tuse_rt2,
    input [`TnewBus]Tnew_E, Tnew_M,
    input [`DecodeRegBus]ra,rb,
    input [`DecodeRegBus]write_regE,
    input [`DecodeRegBus]write_regM,
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
    //   stall_rs1_E2 = Tuse_rs1 & (Tnew_E == 2) & (ra == write_regM) & regwriteE
    //   老师设坑，应该是write_regE而不是write_regM，因为我当前还需要一个时钟周期才会用到需要的数据，而产生还需要两个周期，如果我
    //   判断的是M阶段的话，cal类指令用到的就是还未写回之前的数据，因此我必须提前判断是否存在读写冲突，从而决定当前指令是否需要暂停。
    
    assign stall_rs0_M1 = Tuse_rs0 & (Tnew_M == 1) & (ra == write_regM) & memwriteM;
   
    assign stall_rt0_E1 = Tuse_rt0 & (Tnew_E == 1) & (rb == write_regE) & regwriteE;
    assign stall_rt0_E2 = Tuse_rt0 & (Tnew_E == 2) & (rb == write_regE) & regwriteE;
    assign stall_rt1_E2 = Tuse_rt1 & (Tnew_E == 2) & (rb == write_regE) & regwriteE;
    assign stall_rt0_M1 = Tuse_rt0 & (Tnew_M == 1) & (rb == write_regM) & memwriteM;

    assign stall_rs = stall_rs0_E1 | stall_rs0_E2 | stall_rs1_E2 ;
    assign stall_rt = stall_rt0_E1 | stall_rt0_E2 | stall_rt1_E2 ;

    assign stall = stall_rs | stall_rt;
endmodule
