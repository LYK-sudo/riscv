module alu (
    input [3:0] op,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] c,
    output reg is_branch
);
   always @(*) begin
        case(op)
            4'b0000:c=a+b;//add
            4'b1000:c=a-b;//sub
            4'b0001:c=a<<b[4:0];//sll
            4'b0010:c={31'd0,$signed(a)<$signed(b)};//slt
            4'b0011:c={31'd0,a<b};//sltu
            4'b0100:c=a^b; //xor
            4'b0101:c=a>>b[4:0];//srl
            4'b1101:c=$signed(a)>>>b[4:0];//sra
            4'b0110:c=a|b;//or
            4'b0111:c=a&b;//and
            default:c=32'd0;

        endcase
   end 

    //branch
   wire [2:0] funct3=op[2:0];
   always @(*) begin
        is_branch=0;
        case(funct3)
            3'b000 :is_branch=(a==b);
            3'b001 :is_branch=(a!=b);
            3'b100 :is_branch=$signed(a)<$signed(b);
            3'b101 :is_branch=$signed(a)>=$signed(b);
            3'b110 :is_branch=a<b;
            3'b111 :is_branch=a>=b;
            default:is_branch=0;
        endcase
    end

endmodule
//R
