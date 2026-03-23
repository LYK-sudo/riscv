module control (
    input [6:0] opcode,
    output reg branch,
    output reg rmem,
    output reg [1:0] mem_to_reg,  //alu data imm pc4
    //output reg [1:0] aluOp,
    output reg wmem,
    output reg alu_a, //？？？？？？
    output reg alu_b,
    output reg wreg,
    output reg pc_imm,
    output reg pcSrc
);
    always @(*) begin
        branch=0;  //
        rmem=0;  //dara
        mem_to_reg=0;
        //aluOp=0;
        wmem=0;  //data
        alu_a=0;
        alu_b=0;
        wreg=0;
        pc_imm=0;
        pcSrc=0;
        case (opcode)
            7'b0110111: begin//lui
                wreg=1;
                mem_to_reg=2;
            end  
            7'b0010111:begin //auipc
                wreg=1;
                //mem_to_reg=0;
                alu_a=1;
                alu_b=1;
            end
            7'b1101111:begin //jal
                wreg=1;
                mem_to_reg=3;
                pc_imm=1;
            end
            7'b1100111:begin //jalr
                wreg=1;
                mem_to_reg=3;
                alu_b=1;
                pcSrc=1;  //pc=r1+imm;

            end

            7'b1100011:begin  //branch
                branch=1;
            end
            7'b0000011:begin  //load
                wreg=1;
                alu_b=1;
                rmem=1;
                mem_to_reg=1;
            end
            7'b0100011:begin  //s
                wmem=1;
                alu_b=1;
            end 
            7'b0010011:begin  //addi
                wreg=1;
                alu_b=1;
            end
            7'b0110011:begin  //add
                wreg=1;
            end
            
            //default: 
        endcase
    end
endmodule