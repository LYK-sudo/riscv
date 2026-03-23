module forwording(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] m_rd,
    input [4:0] w_rd,
    input m_wreg,
    input w_wreg,
    output [1:0] fwda,
    output [1:0] fwdb
    
);

assign fwda=(rs1==m_rd&&m_wreg&&rs1!=0)?2:(rs1==w_rd&&w_wreg&&rs1!=0)?1:0;
assign fwdb=(rs2==m_rd&&m_wreg&&rs2!=0)?2:(rs2==w_rd&&w_wreg&&rs2!=0)?1:0;


endmodule