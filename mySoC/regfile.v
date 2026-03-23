module regfile (
    input clk,
    input wreg,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] data_in,
    output [31:0] r1,
    output [31:0] r2
);
    reg [31:0] regs[1:31];
    integer i;
    initial begin
        //regs[0]=32'd0;
        for (i=1;i<32;i=i+1) begin
            regs[i]=0;
        end
        regs[2]=32'h7fffeffc;
        regs[3]=32'h10008000;
    end

    always @(posedge clk) begin
        if(wreg&&rd!=0)regs[rd]<=data_in;
    end
 
    // assign r1=rs1==0?0:regs[rs1];
    // assign r2=rs2==0?0:regs[rs2];

    assign r1=(rs1==5'd0)?32'd0:
                (wreg&&(rd==rs1))?data_in:regs[rs1];
    
    assign r2=(rs2==5'd0)?32'd0:
                (wreg&&(rd==rs2))?data_in:regs[rs2];

endmodule