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

`include "stddef.v"
module pipelinecpu(
    input clk, 
    input reset
    );
    wire [`DataBus] is,dm_outM, alu_outM, a, alu_b, resultW, pc, cmp_a, cmp_b;
	wire [`DecodeRegBus] write_regW,write_regM;
	
	wire regwriteW, nop, pcwrite, zero, stall;
    wire  if_idwrite,regwrite, memtoreg, memwrite,  alusrc, regdst, memread;
    wire [`BranchBus]branchD,branch;
    wire [`AluBus] aluc;
    wire [`ExtOpBus] extop;
    
    wire regwriteD, memtoregD, memwriteD, alusrcD, regdstD, memreadD;
    wire [`AluBus] alucD;
    wire [`ExtOpBus] extopD;
    
    wire regwriteE, memtoregE, memwriteE, branchE, alusrcE, regdstE, memreadE;
    wire [`AluBus] alucE;
    wire [`ExtOpBus] extopE;
    
    wire regwriteM, memtoregM, memwriteM, branchM;
    
    wire  memtoregW;
    
      
    wire [`DataBus]  qa, qb,  b, ep_immD, ep_immE, alu_outE,  alu_outW, write_dataE, write_dataM, dm_outW;
    wire [`InstBus] npc, pc_plus4F, pc_plus4D, pc_plus4E, pc_branchD;
    wire [`DataBus] alu_a, alu_b1;
   
    wire [`DecodeRegBus] ra, rsE, rtE, rdE, rb, rd, write_regE;
    wire [`OpBus] op;
    wire [`FuncBus] func;
    wire [`ImmBus] imm;
    wire [`ExtAdrBus] jump_adr;
    
    wire stall_rs, stall_rt, stall_rs0_E1, stall_rs0_E2, stall_rs1_E2, stall_rs0_M1, stall_rt0_E1, stall_rt0_E2, stall_rt1_E2, stall_rt0_M1;
    wire Tuse_rs0, Tuse_rs1, Tuse_rt0, Tuse_rt1, Tuse_rt2;
    wire [`TnewBus] Tnew, Tnew_E, Tnew_M;
    wire[`ExtAdrBus] j_adr;
    wire [`PcSrcBus] pcsrc;
    wire [`ForwardBus] forwardcmpsrcA, forwardcmpsrcB;
    wire [`ForwardBus] forwardalu_A, forwardalu_B;
    
    wire equal_zero;
    wire grater_than_zero;
    wire less_than_zero;
    // wire stall_rs0_E3,stall_rt0_E3;
    wire[`ShamtBus] shamtD,shamtE;
    wire shamtsrc,shamtsrcD,shamtsrcE;

    wire[`SWBus]din_store,din_storeD,din_storeE,din_storeM;
    wire[`LWBus]dout_load,dout_loadD,dout_loadE,dout_loadM;

    wire jal,jalD,jalE;
    wire j,jD;
    wire jr,jrD;

    wire[`DecodeRegBus] rtM;
    wire forward_DM;
//IF
    assign jump_adr[`DataHighFourBitRange] = jrD? cmp_a[`DataHighFourBitRange]:pc_plus4D[`DataHighFourBitRange];
    assign jump_adr[`DataLowTwentyEightBitRange] = jrD? cmp_a[`DataLowTwentyEightBitRange]:j_adr << 2;
    assign pc_plus4F = pc + 4; 
   NPC npc_(
        .pcsrc(pcsrc),
        .jump_adr(jump_adr),//跳转
        .pc_plus4F(pc_plus4F),//加4
        .pc_branchD(pc_branchD),//
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
        .is(is)
    );
   

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
        .shamt(shamtD),
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
        .shamtsrc(shamtsrc), 
        .din_store(din_store),
        .dout_load(dout_load),
        .Tuse_rs0(Tuse_rs0), 
        .Tuse_rs1(Tuse_rs1), 
        .Tuse_rt0(Tuse_rt0), 
        .Tuse_rt1(Tuse_rt1), 
        .Tuse_rt2(Tuse_rt2), 
        .j(j),
        .jal(jal),
        .jr(jr),
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
    assign pc_branchD = (ep_immD << 2) + pc_plus4D;
    CMP cmp(
        .forwardcmpsrcA(forwardcmpsrcA), 
        .forwardcmpsrcB(forwardcmpsrcB), 
        .qa(qa), 
        .qb(qb), 
        .alu_outM(alu_outM), 
        .resultW(resultW), 
        .zero(zero), 
        .branchD(branchD),
        .j(j),
        .jal(jal),
        .jr(jr),
        .equal_zero(equal_zero),
        .grater_than_zero(grater_than_zero),
        .less_than_zero(less_than_zero),
        // .not_equal(not_equal),
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
        .shamtsrc(shamtsrc),
        .din_store(din_store),
        .dout_load(dout_load),
        .j(j),
        .jal(jal),
        .jr(jr),
        .jD(jD),
        .jalD(jalD),
        .jrD(jrD),
        .din_storeD(din_storeD),
        .dout_loadD(dout_loadD),
        .shamtsrcD(shamtsrcD),
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
 
    assign flush = (pcsrc) ? 1 : 0;

    IdToEx ID_EX(
        .clk(clk), 
        .reset(reset),
        .regwriteD(regwriteD), 
        .memtoregD(memtoregD), 
        .memwriteD(memwriteD), 
        .alucD(alucD), 
        .din_storeD(din_storeD),
        .dout_loadD(dout_loadD),
        .alusrcD(alusrcD), 
        .regdstD(regdstD), 
        .extopD(extopD), 
        .memreadD(memreadD),
        .jalD(jalD),
        .jalE(jalE),
        .din_storeE(din_storeE),
        .dout_loadE(dout_loadE),
        .shamtD(shamtD),
        .shamtE(shamtE),
        .shamtsrcD(shamtsrcD),
        .shamtsrcE(shamtsrcE),
        .regwriteE(regwriteE), 
        .memtoregE(memtoregE), 
        .memwriteE(memwriteE), 
        .alucE(alucE), 
        .alusrcE(alusrcE), 
        .regdstE(regdstE), 
        .extopE(extopE), 
        .memreadE(memreadE),
        .qa(cmp_a), 
        .qb(cmp_b), 
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
        .rtM(rtM),
        .forward_DM(forward_DM), 
        .write_regM(write_regM), 
        .write_regW(write_regW), 
        .regwriteM(regwriteM), 
        .regwriteW(regwriteW), 
        .forwardalu_A(forwardalu_A), 
        .forwardalu_B(forwardalu_B), 
        .forwardcmpsrcA(forwardcmpsrcA), 
        .forwardcmpsrcB(forwardcmpsrcB)
    );
    wire[`DataBus] alu_a1;
    MFA mfa(
        .forwardalu_A(forwardalu_A),
        .a_in(a),
        .resultW(resultW),
        .alu_outM(alu_outM),
        .alu_a(alu_a)
    );
    assign alu_a1=shamtsrcE?shamtE:alu_a;
    MFB mfb(
        .forwardalu_B(forwardalu_B),
        .b_in(b),
        .resultW(resultW),
        .alu_outM(alu_outM),
        .alu_b1(alu_b1)
    );
    wire[`DataBus]alu_out;
    // wire sign_flagE;
    assign alu_b = alusrcE ? ep_immE : alu_b1;
    ALU alu(
        .a_in(alu_a1), 
        .b_in(alu_b), 
        .aluc(alucE), 
        // .sign_flag(sign_flagE),
        .alu_out(alu_out)
    );
    assign write_regE = jalE? 31: (regdstE ? rtE : rdE);
    assign alu_outE =jalE? pc_plus4E : alu_out;
    ExToMem EX_MEM(
        .clk(clk), 
        .reset(reset),
        .regwriteE(regwriteE), 
        .memtoregE(memtoregE), 
        .memwriteE(memwriteE),
        .din_storeE(din_storeE),
        .dout_loadE(dout_loadE),
        .din_storeM(din_storeM),
        .dout_loadM(dout_loadM),
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
    wire[`DataBus] dm_in_data;
    assign dm_in_data = forward_DM ? resultW : write_dataM;
//MEM
    DM dm(
        .clk(clk), 
        .reset(reset), 
        .we(memwriteM), 
        .addr(alu_outM), 
        .d_in(dm_in_data), 
        .din_store(din_storeM),
        .dout_load(dout_loadM),
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
