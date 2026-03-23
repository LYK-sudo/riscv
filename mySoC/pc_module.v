//`timescale 1ns / 1ps


module pc_module(
    input clk,
    input rst,
    input stall,
    //input [31:0] rst_pc,
    input [31:0] data_in,
    input ebreak,
    output reg[31:0] pc_out
);

    //initial pc_out=32'h00400000;
    reg flag;
    always @(posedge clk) begin
        
        if(rst==1'b1)begin
            pc_out<=32'h00000000-4;
            flag<=0;
        end    
        else if(ebreak||flag)begin
            pc_out<=pc_out;
            flag<=1;
        end
        else if(!stall)
            pc_out<=data_in;
        
    end

endmodule
