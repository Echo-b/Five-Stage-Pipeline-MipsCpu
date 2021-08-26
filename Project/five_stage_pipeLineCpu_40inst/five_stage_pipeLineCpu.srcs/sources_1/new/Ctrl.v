`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:23:03
// Design Name: 
// Module Name: Ctrl
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
    wire r = (op == `R_OP);
    wire add =(r && func ==   `Add_Op  ); 
    wire sub  =( r && func == `Sub_Op  );
    wire subu =( r && func == `Subu_Op );
    wire slt  =( r && func == `Slt_Op  );
    wire addu =( r && func == `Addu_Op );
    wire or_  =( r && func == `Or_Op   );
    wire and_ =( r && func == `And_Op  );
    wire xor_ =( r && func == `Xor_Op  );
    wire nor_ =( r && func == `Nor_Op  );
    assign jr =( r && func == `Jr_Op   );
    wire sll  =( r && func == `Sll_Op  );
    wire srl  =( r && func == `Srl_Op  );
    wire sra  =( r && func == `Sra_Op  );
    wire sllv =( r && func == `Sllv_Op );
    wire srlv =( r && func == `Srlv_Op );
    wire srav =( r && func == `Srav_Op );
    wire addi = (op  == `Addi_Op );
    wire lui  = (op  == `Lui_Op  );
    wire ori  = (op  == `Ori_Op  );
    wire xori = (op   == `Xori_Op );
    wire addiu = (op  == `Addiu_Op);
    wire andi  = (op  == `Andi_Op );
    wire lw    = (op  == `Lw_Op   );
    wire sw    = (op  == `Sw_Op   );
    wire lb    = (op  == `Lb_Op   );
    wire lbu   = (op == `Lbu_Op  );
    wire lh    = (op == `Lh_Op   );
    wire lhu   = (op  == `Lhu_Op  );
    wire beq =( op ==  `Beq_Op  );
    assign j = (op ==  `J_Op    );
    wire sb    = (op ==  `Sb_Op   );
    wire sh    =(op ==  `Sh_Op   );
    wire bgtz  = (op ==  `Bgtz_Op );
    wire bgez  = (op ==  `Bgez_Op );
    wire slti  = (op ==  `Slti_Op );
    wire bne   = (op ==  `Bne_Op  );
    wire blez  = (op ==  `Blez_Op );
    assign jal  = (op == `Jal_Op  );
   
    
    // wire null   =(op == 6'b000000 && func==6'b000000);

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
