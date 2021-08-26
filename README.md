# 基于形式化验证方法的五级流水CPU设计与实现

<!-- TOC -->

- [基于形式化验证方法的五级流水CPU设计与实现](#基于形式化验证方法的五级流水cpu设计与实现)
  - [设计阶段](#设计阶段)
  - [一、实验目的](#一实验目的)
  - [二、设计思路](#二设计思路)
    - [（一）实验原理](#一实验原理)
    - [（二）冲突问题解决思路](#二冲突问题解决思路)
      - [冒险产生原因及分析解决](#冒险产生原因及分析解决)
        - [数据冒险](#数据冒险)
        - [控制冒险](#控制冒险)
  - [三、各功能部件具体实现](#三各功能部件具体实现)
      - [四个流水寄存器](#四个流水寄存器)
        - [IF -> ID](#if---id)
        - [ID -> EX](#id---ex)
        - [EX -> MEM](#ex---mem)
        - [MEM -> WB](#mem---wb)
      - [冒险控制单元](#冒险控制单元)
      - [主控单元](#主控单元)
      - [寄存器](#寄存器)
      - [运算器](#运算器)
      - [存储器](#存储器)
      - [转发控制单元](#转发控制单元)
      - [各级转发点](#各级转发点)
      - [暂停信号生成](#暂停信号生成)
      - [指令清除](#指令清除)
      - [符号扩展](#符号扩展)
      - [PC](#pc)
      - [NPC](#npc)
  - [四、测试结果](#四测试结果)
    - [7 Inst](#7-inst)
    - [40 Inst](#40-inst)
  - [五、开发环境](#五开发环境)

<!-- /TOC -->

## 设计阶段
- [x] 7指令mips指令运行
- [x] 40指令mips指令运行
- [ ] 中断未实现
- [ ] 异常未实现

## 一、实验目的
1. 掌握流水线(Pipelined)处理器的思想； 
2. 掌握单周期处理中执行阶段的划分； 
3. 了解流水线处理器遇到的冒险； 
4. 掌握数据转发、流水线暂停等冒险解决方式。


## 二、设计思路
整体思路图
![design_image](https://i.loli.net/2021/08/24/hjCEUmO6KNxBd2o.png)
<hr>
流水线功能部件规划

![image.png](https://i.loli.net/2021/08/26/d6xnrL3voZ28H9E.png)

### （一）实验原理
下图为单周期的原理图，我们此次的流水cpu将从单周期原理图入手，逐步分析加入流水cpu所需原件。第一步我们主要做的改动就是在每个执行阶段加入级间寄存器，作用时传递译码完成后的数据和控制信号。从执行过程来看每一条指令携带着本条指令所需的所有控制信号和所需数据，通过级间寄存器时，用掉本阶段需要用的信号，不用的继续往下一级传递。同时因为指令携带着自己所需的数据和控制信号，因此不同的阶段可以执行不同的指令。即不断的重复取指，译码，执行，访存，写回5个阶段，在没有冲突的情况下，每个阶段都有不同的指令在执行，大大的提高了效率。

![image](https://i.loli.net/2021/08/24/49bXyjhgfINVLBE.png)

除了流水寄存器外，我们还需要加入控制器，控制器部分与单周期相同，但由于改为五级流水线后，每一个阶段所需要的控制信号仅为一部分，控制器产生信号的阶段为译码阶段，产生控制信号后，依次通过级间寄存器传到下一阶段，若当前阶段需要的信号，则不需要继续传递到下一阶段。另外，考虑到指令间数据的相关性等，我们还需要进行着诸如转发，流水暂停等操作来解决。这也就需要加入一个控制冒险单元来生成暂定stall信号或者flush控制信号，用于暂停指令或者消除控制冒险。此部分下面近一步阐释。下图为加入控制冒险单元后的五级流水原理图。

![image](https://i.loli.net/2021/08/24/whX4CIrv7Uq9mFy.png)

### （二）冲突问题解决思路
#### 冒险产生原因及分析解决
在流水线 CPU 中，并不是能够完全实现并行执行。在单周期中由于每条指令执行完毕才会执行下一条指令，并不会遇到冒险问题，而在流水线处理器中，由于当前指令可能取决于前一条指令的结果，但此时前一条指令并未执行到产生结果的阶段，这时候，就产生了冒险。冒险分为：
1. **数据冒险** ：寄存器中的值还未写回到寄存器堆中，下一条指令已经需要从寄存器堆中读取数据； 
2. **控制冒险**：下一条要执行的指令还未确定，就按照 PC 自增顺序执行了本不该执行的指令(由分支指令引起)
##### 数据冒险

![image.png](https://i.loli.net/2021/08/24/SF8BiyCDkn1lPj7.png)

分析上述指令，不难发现，and、or、sub均需要使用$s0的数据，但是add指令需要在写回阶段才能将数据写回到寄存器堆。此时三条指令要么正在译码要么已经经过译码阶段，所用到的寄存器堆数据均不是最新计算出的，因此结果就都是不正确的了。
以上就是数据冒险的特点，数据冒险有以下解决方式： 
1. 在编译时插入空指令；
2. 在编译时对指令执行顺序进行重排； 
3. 在执行时进行数据转发； 
4. 在执行时，暂停处理器当前阶段的执行，等待结果。 
由于我们未进行编译层的处理，需要在运行时进行解决，故采用3、4解决方案。

**数据转发**

![image.png](https://i.loli.net/2021/08/24/Pm32ehH14AzXEBg.png)

从图中分析，可以发现，我们所需要用到的数据在执行阶段就已经由alu计算出，因此我们不需要等待数据更新到寄存器，我们可以直接将计算出的数据转发到下一条指令的执行阶段，根据相应的控制信号便可以选择出正确的数据。从而达到数据转发的目的。
数据转发的伪代码如下：
```verilog
//第一个转发点
if ((rsE != 0) AND (rsE == WriteRegM) AND RegWriteM) 
    then ForwardALUA = M2E_ALU //2 M阶段向E阶段转发ALU计算的结果
else if ((rsE != 0) AND (rsE == WriteRegW) AND RegWriteW) 
    then ForwardALUA = W2E_ALU //1 W阶段向E阶段转发ALU计算的结果
else 
    ForwardALUA = Normal_Read_Data //0 正常从寄存器中读取的数据

//第二个转发点
if ((rtE != 0) AND (rtE == WriteRegM) AND RegWriteM) 
    then ForwardALUB = M2E_ALU //2 M阶段向E阶段转发ALU计算的结果
else if ((rtE != 0) AND (rtE == WriteRegW) AND RegWriteW) 
    then ForwardALUB = W2E_ALU //1 W阶段向E阶段转发ALU计算的结果
else 
    ForwardALUB = Normal_Read_Data //0 正常从寄存器中读取的数据
```
ALU的两路输入均存在转发点，因此用一个三路的多路选择器就可，加入后如下图。

![image](https://i.loli.net/2021/08/24/tAFjXwqg6Nh2kS3.png)

**流水线暂停**

![image.png](https://i.loli.net/2021/08/24/6k8stgDzMRFE1ed.png)

多数情况下，数据前推能解决很大一部分数据冒险的问题，然而在上图中，lw指令在访存阶段才能够从数据存储器读取数据，此时 and 指令已经完成 ALU 计算，无法进行数据转发。在这种情况下，必须使流水线暂停，等待数据读取后，再转发到执行阶段。

流水线暂定信号实现方式：**转发策略矩阵**。引入指令集的Tnew和Tuse
- Tnew:使用哪一个部件来产生寄存器的新值，从D级开始看，逐级递减，直到为0.
- Tuse:还需要几个时钟周期才用到寄存器的值，从E级开始看

![image](https://i.loli.net/2021/08/24/b98CHLYmoDl6GgS.png)

转发策略矩阵的伪代码如下：
```verilog
    //Tuse_rs0 0=>beq jr j
    // Tnew_E==1 ALU运算类指令

    //Tuse_rs0 0=>beq jr j
    // Tnew_E==2  lw

    //Tuse_rs0 0=>beq jr j
    // Tnew_M==1  lw

    //Tuse_rs1 cal_r cal_i 运算类指令
    // Tnew_E==1  lw
                    // beq        cal              equal/not equal    true/false
    stall_rs0_E1 = Tuse_rs0 AND (Tnew_E == 1) AND (ra == write_regE) AND regwriteE;
    stall_rs0_E2 = Tuse_rs0 AND (Tnew_E == 2) AND (ra == write_regE) AND regwriteE;
    stall_rs1_E2 = Tuse_rs1 AND (Tnew_E == 2) AND (ra == write_regE) AND regwriteE;
    stall_rs0_M1 = Tuse_rs0 AND (Tnew_M == 1) AND (ra == write_regM) AND memwriteM;

    stall_rt0_E1 = Tuse_rt0 AND (Tnew_E == 1) AND (rb == write_regE) AND regwriteE;
    stall_rt0_E2 = Tuse_rt0 AND (Tnew_E == 2) AND (rb == write_regE) AND regwriteE;
    stall_rt1_E2 = Tuse_rt1 AND (Tnew_E == 2) AND (rb == write_regE) AND regwriteE;
    stall_rt0_M1 = Tuse_rt0 AND (Tnew_M == 1) AND (rb == write_regM) AND memwriteM;

    stall_rs = stall_rs0_E1 OR stall_rs0_E2 OR stall_rs1_E2 ;
    stall_rt = stall_rt0_E1 OR stall_rt0_E2 OR stall_rt1_E2 ;

    stall = stall_rs OR stall_rt;
```
产生控制信号stall后，流水线中暂定的实现分三步：
1. 设置 PC触发器使能端不使能 
2. 设置 Fetch->Decode 阶段级间寄存器使能端不使能
3. Decode->Exexcute 阶段级间寄存器清除(避免后续阶段的执行，等待完成后 方可继续执行后续阶段)

解决数据冒险之后，当前数据通路如下

![image](https://i.loli.net/2021/08/24/whX4CIrv7Uq9mFy.png)

##### 控制冒险
控制冒险是分支指令引起的冒险。在五级流水线当中，分支指令在第 4 阶段 才能够决定是否跳转；而此时，前三个阶段已经导致三条指令进入流水线开始执行，这时需要将这三条指令产生的影响全部清除。

![image.png](https://i.loli.net/2021/08/24/4E1ywPpIrNLuajb.png)

将分支指令的判断提前至译码阶段，此时能够减少两条指令的执行；

![image.png](https://i.loli.net/2021/08/24/6wY79m1WnsdHvha.png)

在寄存器读出数据后添加一个判断相等的模块（cmp），即可提前判断beq

![image.png](https://i.loli.net/2021/08/24/FWVT2NdBPljDGzX.png)

此时cmp的两路输入，存在转发点，因此处理方式和ALU类似，加入一个多路选择器即可解决。
cmp的两个转发点的转发控制信号生成伪代码：

```verilog
//第一个转发点
if ((rs != 0) AND (rs == WriteRegM) AND RegWriteM) 
    then ForwardCMPA = M2E_ALU //2 M阶段向E阶段转发ALU计算的结果
else if ((rs != 0) AND (rs == WriteRegW) AND RegWriteW) 
    then ForwardCMPA = W2E_ALU //1 W阶段向E阶段转发ALU计算的结果
else 
    ForwardCMPA = Normal_Read_Data //0 正常从寄存器中读取的数据

//第二个转发点
if ((rt != 0) AND (rt == WriteRegM) AND RegWriteM) 
    then ForwardCMPB = M2E_ALU //2 M阶段向E阶段转发ALU计算的结果
else if ((rt != 0) AND (rt == WriteRegW) AND RegWriteW) 
    then ForwardCMPB = W2E_ALU //1 W阶段向E阶段转发ALU计算的结果
else 
    ForwardCMPB = Normal_Read_Data //0 正常从寄存器中读取的数据

```
解决后，此时数据通路如下，至此我们的分析和图形搭建就结束，下一步即正式的编码环节。

![image.png](https://i.loli.net/2021/08/24/fDQR9HNOUFGeJ6S.png)

## 三、各功能部件具体实现
主要功能部件：
宏定义模块
```verilog
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

```
#### 四个流水寄存器

##### IF -> ID
- RTL图

![image.png](https://i.loli.net/2021/08/24/GW74s5xXubiQm8D.png)

- 代码
```verilog
`include "stddef.v"
module IfToId(
    input clk, reset,
    input if_idwrite,
    input flush,
    input [`InstBus] is,
    input [`InstBus] pc_plus4F,
    output [`OpBus] op,
    output [`FuncBus] func,
    output [`DecodeRegBus] rs,
    output [`DecodeRegBus] rt,
    output [`DecodeRegBus] rd,
    output [`ShamtBus] shamt,
    output [`ImmBus] imm,
    output [`AddrBus] adr,
    output reg [`InstBus] pc_plus4D
    );
    reg [`InstBus] instruct;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruct <= `DISABLE;
            pc_plus4D <= `DISABLE;
        end
        else if(flush)begin
            instruct<=`DISABLE; 
        end
        else if(if_idwrite) begin
            instruct <= is;
            pc_plus4D <= pc_plus4F;
        end
    end
    
    assign op = instruct [`OpRange];
    assign func = instruct [`FuncRange];
    assign rs = instruct [`RsRange];
    assign rt = instruct [`RtRange];
    assign rd = instruct [`RdRange];
    assign imm = instruct [`ImmRange];
    assign adr = instruct [`AdrRange];
    assign shamt =instruct[`ShamtRange];
    
endmodule

```
##### ID -> EX
- RTL图

![image.png](https://i.loli.net/2021/08/24/gzOrwFLpGWkTDSQ.png)

- 代码
```verilog
`include "stddef.v"
module IdToEx(
    input clk, reset,
    input regwriteD,
    input memtoregD,
    input memwriteD,
    input[`SWBus] din_storeD,
    output reg[`SWBus] din_storeE,
    input[`LWBus] dout_loadD,
    output reg[`LWBus] dout_loadE,
    input shamtsrcD,
    output reg shamtsrcE,
    input jalD,
    output reg jalE,
    input [`AluBus] alucD,
    input alusrcD,
    input regdstD,
    input [`ExtOpBus] extopD,
    input memreadD,
    output reg regwriteE,
    output reg memtoregE,
    output reg memwriteE,
    output reg [`AluBus] alucE,
    output reg alusrcE,
    output reg regdstE,
    output reg [`ExtOpBus] extopE,
    output reg memreadE,
    input [`DataBus] qa, qb,
    output reg [`DataBus] a, b,
    input [`DecodeRegBus] rsD, rtD, rdD,shamtD,
    output reg [`DecodeRegBus] rsE, rtE, rdE,shamtE,
    input [`DataBus] ep_immD,
    output reg [`DataBus] ep_immE,
    input [`InstBus] pc_plus4D,
    output reg [`InstBus] pc_plus4E,
    input [`TnewBus] Tnew,
    output reg [`TnewBus] Tnew_E
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteE <= `DISABLE;
            memtoregE <= `DISABLE;
            memwriteE <= `DISABLE;
            alucE <= `DISABLE;
            alusrcE <= `DISABLE;
            regdstE <= `DISABLE;
            extopE <= `DISABLE;
            memreadE <= `DISABLE;
            shamtsrcE<=`DISABLE;
            a <= `DISABLE;
            b <= `DISABLE;
            rsE <= `DISABLE;
            rtE <= `DISABLE;
            rdE <= `DISABLE;
            ep_immE <= `DISABLE;
            pc_plus4E <= `DISABLE;
            jalE<=`DISABLE;
            shamtE<=`DISABLE;
            din_storeE<=`DISABLE;
            dout_loadE<=`DISABLE;
            Tnew_E <= `DISABLE;
        end
        else begin
            regwriteE <= regwriteD;
            memtoregE <= memtoregD;
            memwriteE <= memwriteD;
            alucE <= alucD;
            alusrcE <= alusrcD;
            regdstE <= regdstD;
            extopE <= extopD;
            memreadE <= memreadD;
            a <= qa;
            b <= qb;
            rsE <= rsD;
            rtE <= rtD;
            rdE <= rdD;
            jalE<=jalD;
            din_storeE<=din_storeD;
            dout_loadE<=dout_loadD;
            ep_immE <= ep_immD;
            pc_plus4E <= pc_plus4D;
            shamtE<=shamtD;
            shamtsrcE<=shamtsrcD;
            Tnew_E <= Tnew;
        end
    end
endmodule

```
##### EX -> MEM
- RTL图

![ex_mem_rtl.png](https://i.loli.net/2021/08/26/RHweuaDTstAEnpz.png)

- 代码
```verilog
`include "stddef.v"
module ExToMem(
    input clk, reset,
    input regwriteE,
    input memtoregE,
    input memwriteE,       
    output reg regwriteM,
    output reg memtoregM,
    output reg memwriteM, 
    input [`DecodeRegBus] rtE,
    output reg [`DecodeRegBus] rtM,      
    input [`DataBus] alu_outE,
    output reg [`DataBus] alu_outM,
    input [`DataBus] write_dataE,
    output reg [`DataBus] write_dataM,
    input [`DecodeRegBus] write_regE,
    output reg [`DecodeRegBus] write_regM,
    input[`SWBus] din_storeE,
    output reg[`SWBus] din_storeM,
    input[`LWBus] dout_loadE,
    output reg[`LWBus] dout_loadM,
    input [`TnewBus] Tnew_E,
    output reg [`TnewBus] Tnew_M
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteM <= `DISABLE;
            memtoregM <= `DISABLE;
            memwriteM <= `DISABLE;
            alu_outM <= `DISABLE;
            rtM <= `DISABLE;
            write_dataM <= `DISABLE;
            write_regM <= `DISABLE;
            din_storeM<=`DISABLE;
            dout_loadM<=`DISABLE;
            Tnew_M <= `DISABLE;

        end
        else begin
            regwriteM <= regwriteE;
            memtoregM <= memtoregE;
            memwriteM <= memwriteE;
            rtM <= rtE;
            alu_outM <= alu_outE;
            write_dataM <= write_dataE;
            write_regM <= write_regE;
            din_storeM<=din_storeE;
            dout_loadM<=dout_loadE;
            if (Tnew_E > 0) 
                Tnew_M <= Tnew_E - 1;
        end
    end
endmodule

```
##### MEM -> WB
- RTL图

![image.png](https://i.loli.net/2021/08/24/FVpXYu6isCtWrwa.png)

- 代码
```verilog
`include "stddef.v"
module MemToWb(
    input clk, reset,
    input regwriteM,
    input memtoregM,
    output reg regwriteW,
    output reg memtoregW,
    input [`DataBus] alu_outM,
    output reg [`DataBus] alu_outW,
    input [`DataBus] dm_outM,
    output reg [`DataBus] dm_outW,
    input [`DecodeRegBus] write_regM,
    output reg [`DecodeRegBus] write_regW
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            regwriteW <= `DISABLE;
            memtoregW <= `DISABLE;
            alu_outW <= `DISABLE;
            dm_outW <= `DISABLE;
            write_regW <= `DISABLE;
        end
        else begin
            regwriteW <= regwriteM;
            memtoregW <= memtoregM;
            alu_outW <= alu_outM;
            dm_outW <= dm_outM;
            write_regW <= write_regM;
        end
    end
endmodule

```
#### 冒险控制单元
- RTL图

![image.png](https://i.loli.net/2021/08/24/5S1pmHifAqV9F3L.png)

- 代码
```verilog
`include "stddef.v"
module HazardUnit(
    input stall,
    output reg pcwrite,
    output reg if_idwrite,
    output reg nop
    );
    always @ (*) begin
        pcwrite = `ENABLE;
        if_idwrite = `ENABLE;
        nop = `DISABLE;
        if (stall) begin
            pcwrite = `DISABLE;//pc不使能，pc停在当前指令
            if_idwrite = `DISABLE;//D级寄存器不写,停在当前指令
            nop = `ENABLE;//做后续信号的清空
        end
    end
endmodule

```
#### 主控单元
- RTL图

![ctrl_rtl.png](https://i.loli.net/2021/08/26/WCq9ly3faM64n72.png)

- 代码
```verilog
`include "stddef.v"
module Ctrl(
    input [`FuncBus] func,
    input [`OpBus] op,
    output regwrite,
    output [`AluBus] aluc,
    output alusrc,
    output regdst,
    output memtoreg,
    output memwrite,
    output [`ExtOpBus] extop,
    output [`BranchBus] branch,
    output memread,
    output shamtsrc,
    output [`SWBus] din_store,
    output [`LWBus] dout_load,
    output j, jal, jr,
    output Tuse_rs0, Tuse_rs1, Tuse_rt0, Tuse_rt1, Tuse_rt2,
    output reg [`TnewBus] Tnew
    );
//r   
    wire r =(op == `R_OP);
    wire add  =(r && func == `Add_Op); 
    wire sub  =(r && func == `Sub_Op );
    wire subu =(r && func == `Subu_Op);
    wire slt  =(r && func == `Slt_Op );
    wire addu =(r && func == `Addu_Op);
    wire or_  =(r && func == `Or_Op  );
    wire and_ =(r && func == `And_Op );
    wire xor_ =(r && func == `Xor_Op );
    wire nor_ =(r && func == `Nor_Op );
    assign jr =(r && func == `Jr_Op  );
    wire sll  =(r && func == `Sll_Op );
    wire srl  =(r && func == `Srl_Op );
    wire sra  =(r && func == `Sra_Op );
    wire sllv =(r && func == `Sllv_Op);
    wire srlv =(r && func == `Srlv_Op);
    wire srav =(r && func == `Srav_Op);
    wire addi  = (op  == `Addi_Op );
    wire lui   = (op  == `Lui_Op  );
    wire ori   = (op  == `Ori_Op  );
    wire xori  = (op  == `Xori_Op );
    wire addiu = (op  == `Addiu_Op);
    wire andi  = (op  == `Andi_Op );
    wire lw    = (op  == `Lw_Op   );
    wire sw    = (op  == `Sw_Op   );
    wire lb    = (op  == `Lb_Op   );
    wire lbu   = (op  == `Lbu_Op  );
    wire lh    = (op  == `Lh_Op   );
    wire lhu   = (op  == `Lhu_Op  );
    wire beq   = (op  ==  `Beq_Op );
    assign j   = (op  ==  `J_Op   );
    wire sb    = (op  ==  `Sb_Op  );
    wire sh    = (op  ==  `Sh_Op  );
    wire bgtz  = (op  ==  `Bgtz_Op);
    wire bgez  = (op  ==  `Bgez_Op);
    wire slti  = (op  ==  `Slti_Op);
    wire bne   = (op  ==  `Bne_Op );
    wire blez  = (op  ==  `Blez_Op);
    assign jal = (op  == `Jal_Op  );
   

    assign regwrite = jal|lb|lbu|lh|lhu|srl|srlv|sll|sllv|sra|srav|andi|nor_|xor_|xori|or_|addu|slt|sub|subu|add |and_ | addi |addiu  |lw |ori |lui |slti;
    assign aluc[3] = srlv|srav|srl|sra;
    assign aluc[2] = nor_|slti|slt|xori|xor_|sll|sllv;
    assign aluc[1] = and_ |ori|slti|slt|or_|andi|sll|sllv;
    assign aluc[0] = and_ |sub|subu|nor_|andi|srav|sll|sllv|sra ;
    assign alusrc = sb|sh|lb|lbu|lh|lhu|andi|addi | lw |  sw |ori |lui|addiu|xori|slti;
    assign regdst = ~r/*jal||lb|lbu|lh|lhu||addiu|ori|xori|andi*/;
    assign memtoreg = lb|lbu|lh|lhu|lw ; 
    assign memwrite = sw|sh|sb;
    assign extop[1] = lui;//移位扩展
    assign extop[0] = sb|sh|lb|lbu|lh|lhu|addi|addiu  | lw  | sw | beq |bgtz |bgez |blez |bne|slti;//符号位扩展
    
    //assign branch = beq | bgtz |bgez |blez |bne;//跳转

    assign branch[2] = bgtz | bgez;
    assign branch[1] = bne | blez | bgez;
    assign branch[0] = beq | blez;

    assign memread = lb|lbu|lh|lhu|lw ;
    assign shamtsrc = sll | srl | sra;

    //din_store 2 =>sb
    //din_store 1 =>sh
    //din_store 0 =>sw

    //dout_load 3'b100 => lbu
    //dout_load 3'b011 => lhu
    //dout_load 3'b010 => lb
    //dout_load 3'b001 => lh
    //dout_load 3'b000 => lw
    
    assign din_store[1] = sb;
    assign din_store[0] = sh;
    assign dout_load[2] = lbu;
    assign dout_load[1] = lb | lhu;
    assign dout_load[0] = lh | lhu;

    assign Tuse_rs0 = beq | bne | blez | bgtz | bgez | jr;
    assign Tuse_rs1 = sllv | srlv | srav | add | addu | sub | subu | and_ | or_ | xor_ | nor_ | slt | addi | addiu | ori | xori | andi | lui | slti | lw | lb | lh | lbu | lhu | sw | sb | sh | lbu;
 
    assign Tuse_rt0 = beq | bne;
    assign Tuse_rt1 = sll | srl | sra | sllv | srlv | srav | add | addu | sub | subu | and_ | or_ | xor_ | nor_ | slt;
    assign Tuse_rt2 = sw | sb | sh;


    always @ (*) begin
        if (jal|srl|srlv|srl|srlv|sra|srav|andi|nor_|xor_|xori|or_|addu|addu|subu|sub| and_ | addi |ori |slti|lui|addiu)
            Tnew <= 1;
        else if (lb|lbu|lh|lhu|lw) 
            Tnew <= 2;
        else Tnew <= 0;
    end
    
endmodule

```
#### 寄存器
- RTL图

![image.png](https://i.loli.net/2021/08/24/xcK5HlTaInGms2z.png)

- 代码
```verilog
`include "stddef.v"
module Rf(
    input clk, reset,
    input we,
    input [`DecodeRegBus] ra, rb, rw,
    input [`DataBus] rd,
    output[`DataBus] qa, qb
);
    
    reg [`DataBus] register[`RegNum-1:0];
    integer i;
    
    always @(posedge clk, posedge reset) begin
        if (reset)
            for (i = 0; i < `RegNum; i = i + 1)
		        register[i] <= `DISABLE;
	    else if ((rw != `RegZero) && we)
	        register[rw] <= rd;
    end
    
    assign qa = (ra == `RegZero) ? `DataInit : register[ra];
    assign qb = (rb == `RegZero) ? `DataInit : register[rb];
    
endmodule
```
#### 运算器
- RTL图

![alu_rtl.png](https://i.loli.net/2021/08/26/pkLVeEi35Wxg9db.png)

- 代码
```verilog
`include "stddef.v"
module ALU(
    input [`DataBus] a_in, b_in,
    input [`AluBus] aluc,
    output reg [`DataBus] alu_out
    );
    always @(*) begin
	    case(aluc) 
	        4'b0000: alu_out <= a_in + b_in; 
	        4'b0001: alu_out <= a_in - b_in;
	        4'b0010: alu_out <= a_in | b_in;
	        4'b0011: alu_out <= a_in & b_in;
	        4'b0100: alu_out <= a_in ^ b_in;
	        4'b0101: alu_out <= ~(a_in | b_in);
            4'b0110: begin
                if(($signed(a_in)) < ($signed(b_in)))begin
                    alu_out <= 1;
                end
            end
            4'b0111:alu_out<=b_in << a_in[`AluShamtRange];
            4'b1000:alu_out<=b_in >> a_in[`AluShamtRange];
            4'b1001:alu_out <= ($signed(b_in)) >>> a_in[`AluShamtRange];
		    default: alu_out <= a_in + b_in; 
	    endcase
    end
endmodule
```
#### 存储器
- RTL图

![image.png](https://i.loli.net/2021/08/24/y49CNTRJGhiPp2o.png)

- 代码
```verilog
`include "stddef.v"
module DM(
    input clk, reset,
    input we,
    input[`SWBus] din_store,
    input[`LWBus] dout_load,
    input [`ExtAdrBus] addr,
    input [`DataBus] d_in,
    output reg[`DataBus] d_out
    );

    reg [`RAMBus] ram[`RAMNum-1:0];
    integer i;
    

    //dout_load 3'b100 => lbu
    //dout_load 3'b011 => lhu
    //dout_load 3'b010 => lb
    //dout_load 3'b001 => lh
    //dout_load 3'b000 => lw
    always @(*) begin
        case(dout_load)
            3'b000: begin
                d_out[`RAMHighEightBitRange] <= ram[addr + 3];
                d_out[`RAMMiddleHighEightBitRange] <= ram[addr + 2];
                d_out[`RAMMiddleLowEightBitRange] <= ram[addr + 1];
                d_out[`RAMLowEightBitRange] <= ram[addr];
            end
            3'b001: begin
                d_out[`RAMMiddleLowEightBitRange] <= ram[addr + 1];
                d_out[`RAMLowEightBitRange] <= ram[addr];
                d_out[`RAMHighSixTeenBitRange] <= {16{ram[addr + 1][7]}};//signed_ext
            end
            3'b010: begin
                d_out[`RAMLowEightBitRange] <= ram[addr][`RAMLowEightBitRange];
                d_out[`RAMHighTwentyFourBitRange] <=  {24{ram[addr + 1][7]}}; //signed_ext
            end
            3'b011: begin
                d_out[`RAMMiddleLowEightBitRange] <= ram[addr + 1];
                d_out[`RAMLowEightBitRange] <= ram[addr];
                d_out[`RAMHighSixTeenBitRange] <= 0;                      //zero_ext
            end
            3'b100:begin
                d_out <= ram[addr][`RAMLowEightBitRange]; 
                d_out[`RAMHighTwentyFourBitRange] <= 0;                        //zero_ext
            end    
        endcase
    end
    always @(posedge clk, posedge reset) begin
	    if (reset)
            for (i = 0; i < `RAMNum; i = i + 1)
		        ram[i] <= `DISABLE;
	    else if (we == 1)begin
            //din_store 2 =>sb
            //din_store 1 =>sh
            //din_store 0 =>sw
            case(dout_load)
                2'b00: begin
		            ram[addr + 3] <= d_in[`RAMHighEightBitRange];
		            ram[addr + 2] <= d_in[`RAMMiddleHighEightBitRange];
		            ram[addr + 1] <= d_in[`RAMMiddleLowEightBitRange];
		            ram[addr] <= d_in[`RAMLowEightBitRange];
		        end
		        2'b01: begin
		            ram[addr + 1] <= d_in[`RAMMiddleLowEightBitRange];
		            ram[addr] <= d_in[`RAMLowEightBitRange];
		        end
		        2'b10: ram[addr] <= d_in[`RAMLowEightBitRange];
            endcase
        end
    end
endmodule

```

- RTL图

![image.png](https://i.loli.net/2021/08/24/dwgY2H97ItMjab4.png)

```verilog
`include "stddef.v"
module IM(
    input [`ExtAdrBus] in_adr,
    output [`InstBus] is
    );
    reg[`DataBus] mem [`MemNum-1:0] ;//32*1024
    integer i;
    initial begin
        for(i=0;i<`MemNum;i=i+1)begin
            mem[i]=`DataInit;
        end
    end
    initial begin
        $readmemh("code.txt",mem);
    end
    assign is=mem[in_adr[9:2]];    //按字编址改为按字节编址
   
endmodule
```
#### 转发控制单元
- RTL图

![image.png](https://i.loli.net/2021/08/24/E3IZxDzHSvMQq7i.png)

- 代码
```verilog
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
```
#### 各级转发点
- RTL图

![mfa_mfb_rtl.png](https://i.loli.net/2021/08/26/JrLehtAjc5zvN3R.png)

- 代码
```verilog
`include "stddef.v"
module MFA(
    input[`ForwardBus] forwardalu_A,
    input[`DataBus] a_in,
    input[`DataBus] resultW ,
    input[`DataBus] alu_outM,
    output reg[`DataBus] alu_a
    );
    always @(*) begin
        case(forwardalu_A)
            `Normal_Input: alu_a <= a_in;
            `W2E_ALU: alu_a <= resultW;//W向E转发ALU结果
            `M2E_ALU: alu_a <= alu_outM;//M向E转发ALU结果
        endcase
    end
    
endmodule

```
```verilog
`include "stddef.v"
module MFB(
    input[`ForwardBus] forwardalu_B,
    input[`DataBus] b_in,
    input[`DataBus] resultW,
    input[`DataBus] alu_outM,
    output reg[`DataBus] alu_b1
    );
    always @(*) begin
        case(forwardalu_B)
            `Normal_Input: alu_b1 <= b_in;
            `W2E_ALU: alu_b1 <= resultW;//W向E转发ALU结果
            `M2E_ALU: alu_b1 <= alu_outM;//M向E转发ALU结果
        endcase
    end
endmodule

```
- RTL图

![image.png](https://i.loli.net/2021/08/24/ZaSHjYMO8l6rymt.png)

- 代码
```verilog
`include "stddef.v"
module CMP(
    input [`ForwardBus] forwardcmpsrcA, forwardcmpsrcB,
    input [`DataBus] qa, qb, alu_outM, resultW,
    input j,jal,jr,
    input [`BranchBus] branchD,
    output zero,
    output equal_zero,
    output grater_than_zero,
    output less_than_zero,
    // output not_equal,
    output reg [`DataBus] cmp_a,
    output reg [`DataBus] cmp_b,
    output[`PcSrcBus] pcsrc
    );

    always @(*) begin
        case(forwardcmpsrcA)
            2'b00: cmp_a <= qa;
            2'b01: cmp_a <= resultW;//转发
            2'b10: cmp_a <= alu_outM;//转发
        endcase
        
        case(forwardcmpsrcB)
            2'b00: cmp_b <= qb;
            2'b01: cmp_b <= resultW;//转发
            2'b10: cmp_b <= alu_outM;//转发
        endcase
    end
  
    // assign grater_than_zero=(cmp_a>0)?1:0;
    // assign equal_zero=(cmp_a==0)?1:0;
    // assign less_than_zero=(cmp_a<0)?1:0;
    assign zero =(cmp_a == cmp_b) ? 1 : 0;
    // assign not_equal=(cmp_a!=cmp_b)?1:0;
    assign equal_zero = ($signed(cmp_a))  == 0;
    assign grater_than_zero = ($signed(cmp_a)) > 0;
    assign less_than_zero = ($signed(cmp_a))  < 0;

    // branch[2] = bgtz | bgez;
    // branch[1] = bne | blez | bgez;
    // branch[0] = beq | blez;
    assign pcsrc[0] = j|jal|jr;//2'b01
    assign pcsrc[1] = (branchD == 1 && zero)  //beq
                    ||(branchD == 2 && zero == 0)  //bne
                    ||(branchD == 3 && (equal_zero | less_than_zero)) //blez
                    ||(branchD == 4 && grater_than_zero)  //bgtz
                    ||(branchD == 6 && equal_zero);//bgez
endmodule
```
#### 暂停信号生成
- RTL图

![stall_creat_rtl.png](https://i.loli.net/2021/08/26/XJpt9sVLGZRNfmd.png)

- 代码
```verilog
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
    
    assign stall_rs0_M1 = Tuse_rs0 & (Tnew_M == 1) & (ra == write_regM) & memwriteM;
   
    assign stall_rt0_E1 = Tuse_rt0 & (Tnew_E == 1) & (rb == write_regE) & regwriteE;
    assign stall_rt0_E2 = Tuse_rt0 & (Tnew_E == 2) & (rb == write_regE) & regwriteE;
    assign stall_rt1_E2 = Tuse_rt1 & (Tnew_E == 2) & (rb == write_regE) & regwriteE;
    assign stall_rt0_M1 = Tuse_rt0 & (Tnew_M == 1) & (rb == write_regM) & memwriteM;

    assign stall_rs = stall_rs0_E1 | stall_rs0_E2 | stall_rs1_E2 ;
    assign stall_rt = stall_rt0_E1 | stall_rt0_E2 | stall_rt1_E2 ;

    assign stall = stall_rs | stall_rt;
endmodule

```
#### 指令清除
- RTL图

![inst_clr_rtl.png](https://i.loli.net/2021/08/26/GQ4mxFPur9t3Zp1.png)

- 代码
```verilog
`include "stddef.v"
//清零主控制信号也就是E级寄存器传递的值
module stall_solve(
    input nop,
    input regwrite,
    input[`AluBus] aluc,
    input alusrc,
    input regdst,
    input memtoreg,
    input memwrite,
    input[`ExtOpBus] extop,
    input [`BranchBus]branch,
    input memread,
    input shamtsrc,
    input jal,
    input j,
    input jr,
    input [`SWBus] din_store,
    input [`LWBus] dout_load,
    output jalD,
    output jrD,
    output jD,
    output [`SWBus] din_storeD,
    output [`LWBus] dout_loadD,
    output shamtsrcD,
    output regwriteD,
    output[`AluBus] alucD,
    output alusrcD,
    output regdstD,
    output memtoregD,
    output memwriteD,
    output[`ExtOpBus] extopD,
    output [`BranchBus] branchD,
    output memreadD

    );
    assign regwriteD = nop ? `DISABLE : regwrite;
    assign alucD = nop ? `DISABLE : aluc;
    assign alusrcD = nop ? `DISABLE : alusrc;
    assign regdstD = nop ? `DISABLE : regdst;
    assign memtoregD = nop ? `DISABLE : memtoreg;
    assign memwriteD = nop ? `DISABLE : memwrite;
    assign extopD = nop ? `DISABLE : extop;
    assign branchD = nop ? `DISABLE : branch;
    assign memreadD = nop ? `DISABLE : memread;
    assign shamtsrcD=nop?`DISABLE:shamtsrc;
    assign din_storeD=nop?`DISABLE:din_store;
    assign dout_loadD=nop?`DISABLE:dout_load;
    assign jD = nop ? `DISABLE : j;
    assign jalD = nop ? `DISABLE : jal;
    assign jrD = nop ? `DISABLE : jr;
    
endmodule
```
#### 符号扩展
- RTL图

![image.png](https://i.loli.net/2021/08/24/yT5rHtI3VofJAvh.png)

- 代码
```verilog
`include "stddef.v"
module exp(
    input [`ExtOpBus] extop,
    input [`ImmBus] imm,
    output reg [`DataBus] ep_imm
    );
    always @(extop, imm) begin
	    case(extop) 
	        2'b00: 
	            ep_imm <= imm;
	        2'b01:
                ep_imm<={{`ImmLocBit{imm[`ImmHighestBit]}},imm}; 
	        2'b10: 
	            ep_imm <= imm << `ImmShiftBitNum;//lui
		    default: 
		        ep_imm <= imm;
	    endcase
    end
    
endmodule
```

#### PC
- RTL图

![image.png](https://i.loli.net/2021/08/24/7GnKTpoxQUgOlcF.png)

- 代码
```verilog
`include "stddef.v"
module PC(
    input clk, reset,
    input pcwrite,
    input [`InstBus] adr,
    output [`DataBus] data 
    );
    reg [`InstBus] inst;
    
    assign data = inst;

    always @(posedge clk, posedge reset) begin
        if (reset) 
            inst <= `DISABLE;
        else if (pcwrite) 
            inst <= adr;
    end
endmodule

```

#### NPC
- RTL图

![image.png](https://i.loli.net/2021/08/24/8jhrwIBlVdXyLWm.png)

- 代码
```verilog
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
```
## 四、测试结果
### 7 Inst
![7_inst_1.jpg](https://i.loli.net/2021/08/26/do59CgfzNaIrDtR.jpg)
![7_inst_2.jpg](https://i.loli.net/2021/08/26/aDcKE1IUfBLRQG4.jpg)
![7_inst_3.jpg](https://i.loli.net/2021/08/26/STY1P3scprfBV5d.jpg)
![7_inst_4.jpg](https://i.loli.net/2021/08/26/nlbF7fpAg3UO8r4.jpg)
![7_inst_5.jpg](https://i.loli.net/2021/08/26/VBr1yOon9tMYdsm.jpg)

### 40 Inst
![image.png](https://i.loli.net/2021/08/24/hj4oUIPpS8itOAM.png)
![image.png](https://i.loli.net/2021/08/24/kqtmQSXYe5KBIxP.png)
![image.png](https://i.loli.net/2021/08/24/fndp7SeI3jo8D9y.png)
![image.png](https://i.loli.net/2021/08/24/7I5gLlr2xhmnkWe.png)
![image.png](https://i.loli.net/2021/08/24/qJmf4RoKxHskChL.png)

## 五、开发环境
- Vivado v2019.2 (64-bit)
- MARS 4.4