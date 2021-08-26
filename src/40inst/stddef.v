`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/24 14:36:32
// Design Name: 
// Module Name: stddef
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


`ifndef _STDDEF_HEADERS_
    `define _STDDEF_HEADERS_
    `define ENABLE 1'b1
    `define DISABLE 1'b0
    `define DataInit 32'h00000000
    `define  FuncBus   5:0
    `define  OpBus     5:0
    `define  AluBus    3:0
    `define  ExtOpBus  1:0
    `define  BranchBus 2:0
    `define  SWBus     1:0
    `define  LWBus     2:0
    `define  TnewBus   1:0
    `define  ForwardBus 1:0
    `define PcSrcBus 1:0
    `define DataBus 31:0
    `define RegNum 32
    `define RegZero 0
    `define RAMBus 7:0
    `define RAMNum 256
    `define RAMHighEightBitRange    31:24
    `define RAMMiddleHighEightBitRange    23:16
    `define RAMMiddleLowEightBitRange    15:8
    `define RAMLowEightBitRange    7:0 
    `define RAMHighSixTeenBitRange 31:16
    `define RAMHighTwentyFourBitRange 31:8
    `define ImmBus 15:0
    `define ImmLocBit 16
    `define ImmHighestBit 15
    `define ImmShiftBitNum 16
    `define InstBus 31:0
    `define ExtAdrBus 31:0
    `define AddrBus 25:0
    `define DecodeRegBus 4:0
    `define ShamtBus 4:0
    `define AluShamtRange 4:0
    `define ShamtRange 10:6
    `define AdrRange 25:0
    `define ImmRange 15:0
    `define RdRange 15:11
    `define RtRange 20:16
    `define RsRange 25:21
    `define FuncRange 5:0
    `define OpRange 31:26
    `define MemNum 1024
    `define M2E_ALU 2 //M向E转发ALU结果
    `define W2E_ALU 1 //W向E转发ALU结果
    `define W2E_DM  1 //W向E转发DM结果
    `define Normal_Input 0 //正常输入
    `define DataHighFourBitRange 31:28
    `define DataLowTwentyEightBitRange 27:0
    `define  R_OP  6'b000000
    `define  Add_Op   6'b100000 
    `define  Sub_Op   6'b100010
    `define  Subu_Op  6'b100011
    `define  Slt_Op   6'b101010
    `define  Addu_Op  6'b100001
    `define  Or_Op   6'b100101
    `define  And_Op  6'b100100
    `define  Xor_Op  6'b100110
    `define  Nor_Op  6'b100111 
    `define  Jr_Op    6'b001000
    `define  Sll_Op   6'b000000
    `define  Srl_Op   6'b000010
    `define  Sra_Op   6'b000011
    `define  Sllv_Op  6'b000100
    `define  Srlv_Op  6'b000110
    `define  Srav_Op  6'b000111
    `define  Addi_Op  6'b001000
    `define  Lui_Op   6'b001111
    `define  Ori_Op   6'b001101
    `define  Xori_Op  6'b001110
    `define  Addiu_Op 6'b001001
    `define  Andi_Op  6'b001100
    `define  Lw_Op    6'b100011
    `define  Sw_Op    6'b101011
    `define  Lb_Op    6'b100000
    `define  Lbu_Op   6'b100100
    `define  Lh_Op    6'b100001
    `define  Lhu_Op   6'b100101
    `define  Beq_Op   6'b000100
    `define  J_Op     6'b000010
    `define  Sb_Op   6'b101000
    `define  Sh_Op   6'b101001
    `define  Bgtz_Op  6'b000111
    `define  Bgez_Op  6'b000001
    `define  Slti_Op  6'b001010
    `define  Bne_Op  6'b000101
    `define  Blez_Op  6'b000110
    `define  Jal_Op   6'b000011
`endif  
