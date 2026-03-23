module imm_gen (
    input [31:0] inst,
    output reg [31:0] imm,
    output  [1:0] is_i_r
);
    assign is_i_r=(inst[6:0]==7'b0010011)?2'b01:(inst[6:0]==7'b0110011||inst[6:0]==7'b1100011)?2'b10:2'd0;
    always @(*) begin
        case (inst[6:0])
            7'b0110111: imm={inst[31:12],12'b0};   //U
            7'b0010111: imm={inst[31:12],12'b0};   //U
            7'b1101111: imm={{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};   //J
            7'b1100111: imm={{21{inst[31]}},inst[30:20]};   //jalr
            7'b0010011: imm={{21{inst[31]}},inst[30:20]};   //I
            7'b0000011: imm={{21{inst[31]}},inst[30:20]};   //I
            7'b0100011: imm={{21{inst[31]}},inst[30:25],inst[11:7]};   //S
            7'b1100011: imm={{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};   //B        
            default: imm=0;
        endcase
    end
endmodule