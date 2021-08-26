`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/03 20:24:06
// Design Name: 
// Module Name: DM
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
