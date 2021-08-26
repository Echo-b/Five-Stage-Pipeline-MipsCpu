`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:28:58
// Design Name: 
// Module Name: pipelinecpu
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


module pipelinecpu(
    input clk, 
    input reset
    );
    wire [31:0] is,dm_outM, alu_outM, a, alu_b, resultW, pc, cmp_a, cmp_b;
	wire [4:0] write_regW,write_regM;
	
	wire regwriteW, nop, pcwrite, zero, stall;
    wire  if_idwrite,regwrite, memtoreg, memwrite, branch, alusrc, regdst, memread;
    wire [2:0] aluc;
    wire [1:0] extop;
    
    wire regwriteD, memtoregD, memwriteD, branchD, alusrcD, regdstD, memreadD;
    wire [2:0] alucD;
    wire [1:0] extopD;
    
    wire regwriteE, memtoregE, memwriteE, branchE, alusrcE, regdstE, memreadE;
    wire [2:0] alucE;
    wire [1:0] extopE;
    
    wire regwriteM, memtoregM, memwriteM, branchM;
    
    wire  memtoregW;
    
      
    wire [31:0]  qa, qb,  b, ep_immD, ep_immE, pc_plus4F, pc_plus4D, pc_plus4E, alu_outE,  alu_outW, write_dataE, pc_branchD, write_dataM, dm_outW;
    wire [31:0] npc;
    wire [31:0] alu_a, alu_b1;
   
    wire [4:0] ra, rsE, rtE, rdE, rb, rd, write_regE;
    wire [5:0] op, func;
    wire [15:0] imm;
    wire [31:0] mem_adr, rf_data, jump_adr;
    wire  j;
    
    wire stall_rs, stall_rt, stall_rs0_E1, stall_rs0_E2, stall_rs1_E2, stall_rs0_M1, stall_rt0_E1, stall_rt0_E2, stall_rt1_E2, stall_rt0_M1;
    wire Tuse_rs0, Tuse_rs1, Tuse_rt0, Tuse_rt1, Tuse_rt2;
    wire [1:0] Tnew, Tnew_E, Tnew_M;
    
    wire [1:0] pcsrc;
    wire [1:0] forwardcmpsrcA, forwardcmpsrcB;
    wire [1:0] forwardalu_A, forwardalu_B;
    
//IF
   NPC npc_(
        .pcsrc(pcsrc),
        .jump_adr(jump_adr),//跳转
        .pc_plus4F(pc_plus4F),//加4
        .pc_branchD(pc_branchD),//指令拼接
        .npc(npc)
    );

    PC pc_(
        .clk(clk), 
        .reset(reset), 
        .pcwrite(pcwrite), 
        .adr(npc), 
        .data(pc)
    );
    IM im(
        .in_adr(pc), 
        .is(is), 
        .j(j)
    );
    assign pc_plus4F = pc + 4;
    assign jump_adr[31:28] = pc_plus4F[31:28];
    assign jump_adr[27:0] = is[25:0] << 2;
    wire flush;
    IfToId if_id(
        .clk(clk), 
        .reset(reset), 
        .flush(flush),
        .if_idwrite(if_idwrite), 
        .is(is), 
        .op(op), 
        .func(func),
        .rs(ra), 
        .rt(rb), 
        .rd(rd), 
        .imm(imm), 
        .adr(j_adr), 
        .pc_plus4F(pc_plus4F), 
        .pc_plus4D(pc_plus4D)
    );
    
//ID
    HazardUnit Hazard(
        .stall(stall), 
        .pcwrite(pcwrite), 
        .if_idwrite(if_idwrite), 
        .nop(nop)
    );
    Ctrl ctrl(
        .func(func), 
        .op(op), 
        .regwrite(regwrite), 
        .memtoreg(memtoreg), 
        .memwrite(memwrite), 
        .branch(branch), 
        .aluc(aluc), 
        .alusrc(alusrc), 
        .regdst(regdst), 
        .extop(extop), 
        .memread(memread), 
        .Tuse_rs0(Tuse_rs0), 
        .Tuse_rs1(Tuse_rs1), 
        .Tuse_rt0(Tuse_rt0), 
        .Tuse_rt1(Tuse_rt1), 
        .Tuse_rt2(Tuse_rt2), 
        .Tnew(Tnew)
    );
    Rf rf(
        .clk(clk), 
        .reset(reset), 
        .we(regwriteW), 
        .ra(ra), 
        .rb(rb), 
        .rw(write_regW), 
        .rd(resultW), 
        .qa(qa), 
        .qb(qb)
    );
    exp Ex(
        .extop(extopD), 
        .imm(imm), 
        .ep_imm(ep_immD)
    ); 
   CMP cmp(
        .forwardcmpsrcA(forwardcmpsrcA), 
        .forwardcmpsrcB(forwardcmpsrcB), 
        .qa(qa), 
        .qb(qb), 
        .alu_outM(alu_outM), 
        .resultW(resultW), 
        .zero(zero), 
        .branch(branch),
        .j(j),
        .cmp_a(cmp_a), 
        .cmp_b(cmp_b),
        .pcsrc(pcsrc)
    );
   stall_solve inst_clr(
        .nop(nop),
        .regwrite(regwrite),
        .aluc(aluc),
        .alusrc(alusrc),
        .regdst(regdst),
        .memtoreg(memtoreg),
        .memwrite(memwrite),
        .extop(extop),
        .branch(branch),
        .memread(memread),
        .regwriteD(regwriteD),
        .alucD(alucD),
        .alusrcD(alusrcD),
        .regdstD(regdstD),
        .memtoregD(memtoregD),
        .memwriteD(memwriteD),
        .extopD(extopD),
        .branchD(branchD),
        .memreadD(memreadD)
    );
    assign pc_branchD = (ep_immD << 2) + pc_plus4D;
    assign flush = (pcsrc==2|j) ? 1 : 0;

    IdToEx ID_EX(
        .clk(clk), 
        .reset(reset),
        .regwriteD(regwriteD), 
        .memtoregD(memtoregD), 
        .memwriteD(memwriteD), 
        .alucD(alucD), 
        .alusrcD(alusrcD), 
        .regdstD(regdstD), 
        .extopD(extopD), 
        .memreadD(memreadD),
        .regwriteE(regwriteE), 
        .memtoregE(memtoregE), 
        .memwriteE(memwriteE), 
        .alucE(alucE), 
        .alusrcE(alusrcE), 
        .regdstE(regdstE), 
        .extopE(extopE), 
        .memreadE(memreadE),
        .qa(qa), 
        .qb(qb), 
        .a(a), 
        .b(b), 
        .rsD(ra), 
        .rtD(rb), 
        .rdD(rd), 
        .rsE(rsE), 
        .rtE(rtE), 
        .rdE(rdE), 
        .ep_immD(ep_immD), 
        .ep_immE(ep_immE), 
        .pc_plus4D(pc_plus4D), 
        .pc_plus4E(pc_plus4E),
        .Tnew(Tnew), 
        .Tnew_E(Tnew_E)
    );
    
//EXE
    Foward foward(
        .rs(ra), 
        .rt(rb), 
        .rsE(rsE), 
        .rtE(rtE), 
        .write_regM(write_regM), 
        .write_regW(write_regW), 
        .regwriteM(regwriteM), 
        .regwriteW(regwriteW), 
        .forwardalu_A(forwardalu_A), 
        .forwardalu_B(forwardalu_B), 
        .forwardcmpsrcA(forwardcmpsrcA), 
        .forwardcmpsrcB(forwardcmpsrcB)
    );
     MFA mfa(
        .forwardalu_A(forwardalu_A),
        .a_in(a),
        .resultW(resultW),
        .alu_outM(alu_outM),
        .alu_a(alu_a)
    );
    MFB mfb(
        .forwardalu_B(forwardalu_B),
        .b_in(b),
        .resultW(resultW),
        .alu_outM(alu_outM),
        .alu_b1(alu_b1)
    );
    assign alu_b = alusrcE ? ep_immE : alu_b1;
    ALU alu(
        .a_in(alu_a), 
        .b_in(alu_b), 
        .aluc(alucE), 
        .alu_out(alu_outE)
    );
    assign write_regE = regdstE ? rtE : rdE;
    
    ExToMem EX_MEM(
        .clk(clk), 
        .reset(reset),
        .regwriteE(regwriteE), 
        .memtoregE(memtoregE), 
        .memwriteE(memwriteE),
        .regwriteM(regwriteM), 
        .memtoregM(memtoregM), 
        .memwriteM(memwriteM),
        .alu_outE(alu_outE), 
        .alu_outM(alu_outM),
        .write_dataE(alu_b1), 
        .write_dataM(write_dataM), 
        .write_regE(write_regE), 
        .write_regM(write_regM), 
        .Tnew_E(Tnew_E), 
        .Tnew_M(Tnew_M)
    );
    
//MEM
    DM dm(
        .clk(clk), 
        .reset(reset), 
        .we(memwriteM), 
        .addr(alu_outM), 
        .d_in(write_dataM), 
        .d_out(dm_outM)
    );
    
    MemToWb MEM_WB(
        .clk(clk), 
        .reset(reset),
        .regwriteM(regwriteM), 
        .memtoregM(memtoregM),
        .regwriteW(regwriteW), 
        .memtoregW(memtoregW),
        .alu_outM(alu_outM), 
        .alu_outW(alu_outW),
        .dm_outM(dm_outM), 
        .dm_outW(dm_outW),
        .write_regM(write_regM), 
        .write_regW(write_regW)
    );
    
//WB

    assign resultW = memtoregW ? dm_outW : alu_outW;
    
    //依据策略矩阵生成stall
    stall_creat Stall_Creat(
        .Tuse_rs0(Tuse_rs0),
        .Tuse_rs1(Tuse_rs1),
        .Tuse_rt0(Tuse_rt0),
        .Tuse_rt1(Tuse_rt1),
        .Tuse_rt2(Tuse_rt2),
        .ra(ra),
        .rb(rb),
        .Tnew_E(Tnew_E),
        .Tnew_M(Tnew_M),
        .regwriteE(regwriteE),
        .memwriteM(memwriteM),
        .write_regE(write_regE),
        .write_regM(write_regM),
        .stall_rs0_E1(stall_rs0_E1),
        .stall_rs0_E2(stall_rs0_E2),
        .stall_rs0_M1(stall_rs0_M1),
        .stall_rt0_E1(stall_rt0_E1),
        .stall_rt0_E2(stall_rt0_E2),
        .stall_rt0_M1(stall_rt0_M1),
        .stall_rt1_E2(stall_rt1_E2),
        .stall_rs(stall_rs),
        .stall_rt(stall_rt),
        .stall(stall)
    );
    
endmodule
