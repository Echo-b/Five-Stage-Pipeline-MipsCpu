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


module Ctrl(
    input [5:0] func,
    input [5:0] op,
    output regwrite,
    output [2:0] aluc,
    output alusrc,
    output regdst,
    output memtoreg,
    output memwrite,
    output [1:0] extop,
    output branch,
    output memread,
    output Tuse_rs0, Tuse_rs1, Tuse_rt0, Tuse_rt1, Tuse_rt2,
    output reg [1:0] Tnew
    );
    //r   
    wire r = (op == 6'b000000);
    wire add =(r && func == 6'b100000); 
    wire and_ = (r && func == 6'b100100);
 
    
 //i   
    wire addi = (op == 6'b001000);
    wire lui = (op == 6'b001111);
    wire ori = (op == 6'b001101);
 
    wire lw = (op == 6'b100011);
    wire sw = (op == 6'b101011);
    
    wire beq =( op == 6'b000100);
  
    
//j  
    wire j = (op == 6'b000010);
  
	 
    assign regwrite = add |and_ |addi  |lw |ori|lui;
    assign aluc[2] = 0;
    assign aluc[1] = and_ |ori;
    assign aluc[0] = and_ | beq;
    assign alusrc = addi | lw |  sw|ori|lui;
    assign regdst = ~r;
    assign memtoreg = lw ; 
    assign memwrite = sw;
    assign extop[1] = lui;//移位扩展
    assign extop[0] = addi  | lw  | sw | beq;//符号位扩展
    assign branch = beq;//相等跳转
    assign memread = lw ;

    assign Tuse_rs0 = beq;
    assign Tuse_rs1 = add |and_|addi | lw | sw ;

    assign Tuse_rt0 = beq;
    assign Tuse_rt1 = add | and_;
    assign Tuse_rt2 = sw;

    always @ (*) begin
        if (add | and_ | addi|ori )
            Tnew <= 1;
        else if (lw|lui) 
            Tnew <= 2;
        else Tnew <= 0;
    end
    
endmodule
