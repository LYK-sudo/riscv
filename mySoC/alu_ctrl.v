module alu_ctrl (
    input [3:0] funct,
    input [1:0] is_i_r,
    //input [1:0] aluOp,
    output [3:0] alu_op
);
    assign alu_op=((is_i_r==1&&funct[2:0]==3'b101)||is_i_r==2)?funct:(is_i_r==1)?{1'b0,funct[2:0]}:4'd0;
    // always @(*) begin
    //     if((is_i_r==1&&funct[2:0]==3'b101)||is_i_r==2)alu_op=funct;
    //     else if(is_i_r==1)alu_op={1'b0,funct[2:0]};
    //     else alu_op=0;
    // end
endmodule