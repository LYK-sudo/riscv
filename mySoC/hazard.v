module hazard (
    input [4:0] EX_rd,
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input EX_rmem,
    output IF_stall,
    output ID_stall,
    output EX_flash,
    input EX_pc_branch,
    output ID_flash

);
    reg lw_stall;
    initial begin
        lw_stall=0;
    end
    always @(*) begin
        lw_stall=EX_rmem&&(EX_rd!=5'd0)&&((ID_rs1==EX_rd)||(ID_rs2==EX_rd));
    end 

    assign IF_stall=lw_stall;
    assign ID_stall=lw_stall;
    assign EX_flash=lw_stall||EX_pc_branch;
    assign ID_flash=EX_pc_branch;
endmodule