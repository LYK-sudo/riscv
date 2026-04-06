module cpu (
    input clk,
    input rst,
    input [31:0] read_data,
    input [31:0] inst,
    output [31:0] pca,
    // output [31:0] c,
    // output [31:0] r2,
    output [31:0] addra,
    output [31:0] dina,
    output [2:0] funct3,
    output          w_data,
    output          debug_wb_have_inst,
    output [31:0]   debug_wb_pc,
    output          debug_wb_ena,
    output [4:0]    debug_wb_reg,
    output [31:0]   debug_wb_value
    //output ena
);
    

    wire [31:0] pc,pc4,r1,r2,imm,c;
    reg [31:0] npc,a,b,reg_wdata;
    wire is_branch,EX_pc_branch;
    wire [3:0] alu_op;
    wire branch,rmem,wmem,alu_a,alu_b,wreg,pc_imm,pcSrc;
    wire [1:0] mem_to_reg,is_i_r,EX_pc_choose;
    assign pc4=pc+4;
 //hazard   
    wire IF_flash,ID_flash,EX_flash,MEM_flash,WB_flash;
    wire IF_stall,ID_stall,EX_stall,MEM_stall,WB_stall;
    assign {IF_flash,MEM_flash,WB_flash}=3'd0;
    assign {EX_stall,MEM_stall,WB_stall}=3'd0;
    wire ID_ebreak;
   
//cpu IM ID
    assign pca=pc;
    assign addra=MEM_c;
    assign dina=wdata;
    assign funct3=MEM_control[20:18];
    //assign ena=MEM_control[30];
    assign w_data=MEM_control[27];
    assign debug_wb_have_inst=WB_control[0]&&WB_pc>=32'h00000000;
    assign debug_wb_pc=WB_pc;
    assign debug_wb_ena=WB_control[22];
    assign debug_wb_reg=WB_rd;
    assign debug_wb_value=WB_reg_wdata;
    //流水线部分
    //IF
    reg [31:0] ID_inst,ID_pc,ID_pc4;//
    reg ID_rst;
    always @(posedge clk) begin
        if(ID_flash)begin
            ID_inst<=32'b0;
            ID_pc<=32'b0;
            ID_pc4<=32'b0;
        end
        else if(!ID_stall)begin
            ID_inst<=inst;
            ID_pc<=pc;
            ID_pc4<=pc4;
        end
        ID_rst<=rst;
    end
    
    //ID
    reg [31:0] EX_pc,EX_pc4,EX_imm,EX_r1,EX_r2,EX_control,EX_pcimm;
    reg [4:0] EX_rd;
    reg [1:0] EX_is_i_r;
    reg EX_rst;
    wire [31:0] ID_pcimm;
    wire control_last;
    assign control_last=ID_inst!=0;
    assign ID_pcimm=ID_pc+imm;
    assign ID_ebreak=ID_inst==32'h00100073;
    always @(posedge clk) begin
        EX_pc<=ID_pc;
        EX_pc4<=ID_pc4;
        EX_imm<=imm;
        EX_is_i_r<=is_i_r;
        EX_r1<=r1;
        EX_r2<=r2;
        EX_rd<=ID_inst[11:7];
        EX_rst<=ID_rst;//???????????????????????????????
        EX_pcimm<=ID_pcimm;
        if(EX_flash||EX_rst)EX_control<=32'b0;
        else EX_control<={branch,rmem,mem_to_reg,wmem,alu_a,alu_b,pc_imm,pcSrc,wreg,ID_inst[30],ID_inst[14:12],ID_inst[19:15],ID_inst[24:20],ID_ebreak,6'd0,control_last};
        
    end
  
    //EX
    reg [31:0] MEM_pc,MEM_pc4,MEM_imm,MEM_c,MEM_r2,MEM_pcimm,MEM_control,MEM_forword_r2;
    reg [4:0] MEM_rd;
    //reg [1:0] MEM_pc_choose;
    //wire [31:0] EX_pcimm;
    //assign EX_pcimm=EX_pc+EX_imm;
    always @(posedge clk) begin
        MEM_pc<=EX_pc;
        MEM_pc4<=EX_pc4;
        MEM_pcimm<=EX_pcimm;
        //MEM_is_branch<=is_branch;
        MEM_c<=c;
        MEM_r2<=EX_r2;
        MEM_rd<=EX_rd;
        MEM_control<=EX_control;
        MEM_imm<=EX_imm;
        MEM_forword_r2<=forword_r2;
        //MEM_pc_choose<=EX_pc_choose;
    end

    //MEM
    reg [31:0] WB_pc,WB_pc4,WB_c,WB_read_data,WB_imm,WB_control,WB_reg_wdata;
    reg [4:0] WB_rd;
    always @(posedge clk) begin
        WB_pc<=MEM_pc;
        WB_pc4<=MEM_pc4;
        WB_c<=MEM_c;
        WB_read_data<=read_data;
        WB_rd<=MEM_rd;
        WB_control<=MEM_control;
        WB_imm<=MEM_imm;
        WB_reg_wdata<=reg_wdata;
    end



    //数据前递
    reg [31:0] forword_r1,forword_r2;
    wire [1:0] forword_a,forword_b;
    always @(*) begin
        case (forword_a)
            2'b00: forword_r1=EX_r1;
            2'b01: forword_r1=WB_reg_wdata;
            2'b10: forword_r1=reg_wdata;
            default: forword_r1=EX_r1;
        endcase
    end
    always @(*) begin
        case (forword_b)
            2'b00: forword_r2=EX_r2;
            2'b01: forword_r2=WB_reg_wdata;
            2'b10: forword_r2=reg_wdata;
            default: forword_r2=EX_r2;
        endcase
    end
    
    

   // IM IM1(.addra(pc),.inst_out(inst));
    pc_module pc1(
        .clk(clk),
        .rst(rst),
        .data_in( npc  ),
        .pc_out(pc),
        .stall(IF_stall),
        .ebreak(WB_control[7])
    );
    control control1(
        .opcode(ID_inst[6:0]),
        .branch(branch),
        .rmem(rmem),
        .mem_to_reg(mem_to_reg),
        .wmem(wmem),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .wreg(wreg),
        .pc_imm(pc_imm),
        .pcSrc(pcSrc)
    );
    regfile regfile1(
        .clk(clk),
        .wreg(   WB_control[22]    ),
        .rs1(ID_inst[19:15]),
        .rs2(ID_inst[24:20]),
        .rd(WB_rd),
        .data_in(  WB_reg_wdata   ),
        .r1(r1),.r2(r2)
    );
    imm_gen imm_gen1(
        .inst(ID_inst),
        .imm(imm),
        .is_i_r(is_i_r));
    alu alu1(
        .op(   alu_op   ),
        .a(a),
        .b( b ),
        .c( c ),
        .is_branch( is_branch  )
    );//???alu_op
    //DM DM1(.clk(clk),.wmem( MEM_control[27] ),.addra( MEM_c  ),.data_in(  MEM_r2  ),.funct3(   MEM_control[20:18]   ),.read_data(  read_data  ));
    alu_ctrl alu_ctrl1(
        .funct(EX_control[21:18]),
        .is_i_r(  EX_is_i_r  ),
        .alu_op(alu_op)
    );
    forwording forwording1(
        .rs1(EX_control[17:13]),
        .rs2(EX_control[12:8]),
        .m_rd(MEM_rd),
        .w_rd(WB_rd),
        .m_wreg(MEM_control[22]),
        .w_wreg(WB_control[22]),
        .fwda(forword_a),
        .fwdb(forword_b)
    );
    hazard hazard1(
        .EX_rd(EX_rd),
        .ID_rs1(ID_inst[19:15]),
        .ID_rs2(ID_inst[24:20]),
        .EX_rmem(EX_control[30]),
        .IF_stall( IF_stall ),
        .ID_stall( ID_stall ),
        .EX_flash( EX_flash ),
        .EX_pc_branch(EX_pc_branch),
        .ID_flash(ID_flash)
    );

//DM

    wire [7:0] load_byte;
    wire [15:0] load_half;
    reg [31:0] load_data;

    assign load_half=addra[1]?read_data[31:16]:read_data[15:0];
    assign load_byte=addra[0]?load_half[15:8]:load_half[7:0];

    always @(*) begin    //I
        case (funct3)
            3'b000: load_data = {{24{load_byte[7]}},load_byte};
            3'b001: load_data = {{16{load_half[15]}},load_half};
            3'b010: load_data = read_data;
            3'b100: load_data = {24'd0,load_byte};
            3'b101: load_data = {16'd0,load_half};
            default: load_data=0;
        endcase
    end

    //assign spo=load_data;//????????????we


    reg [31:0] wdata;

    always @(*) begin   //S
        case (funct3)
            3'b000:begin
                case (addra[1:0])
                    2'b00: wdata = {read_data[31:8],MEM_forword_r2[7:0]};
                    2'b01: wdata = {read_data[31:16],MEM_forword_r2[7:0],read_data[7:0]};
                    2'b10: wdata = {read_data[31:24],MEM_forword_r2[7:0],read_data[15:0]};
                    2'b11: wdata = {MEM_forword_r2[7:0],read_data[23:0]};
                    default: wdata=read_data;
                endcase
            end
            3'b001: wdata = addra[1]? {MEM_forword_r2[15:0],read_data[15:0]}:{read_data[31:16],MEM_forword_r2[15:0]};
            3'b010: wdata = MEM_forword_r2;
            default: wdata= read_data;
        endcase
    end


//测试输出
    integer f=0;
    always @(posedge clk) begin
        if(WB_control[7]&&!f)begin
            $display("测试结束");
            if(regfile1.regs[10]==0)$display("PASS"); // 加粗绿色
            else $display("FAILE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            f=1;
            $finish;
        end
    end



//npc    pc地址选择    
    assign EX_pc_choose=(EX_control[24]||(EX_control[31]&&is_branch))?2'b01:EX_control[23]?2'b10:2'b00;
    assign EX_pc_branch=EX_control[24]||(EX_control[31]&&is_branch)||EX_control[23];//hazard
    always @(*) begin   //npc
        case (EX_pc_choose)
            2'b00: npc=pc4;
            2'b01: npc=EX_pcimm;//jal  branch???？？？？？？？？？？？？？？？？？
            2'b10: npc=c&32'hfffffffe;//jalr不用判断直接切pc？？？？？？？？？？？？？？？？？？？？？
            default: npc=pc4;
        endcase
    end


//alu输入选择    
    always @(*) begin    //r1 pc?????(pc)
        case (EX_control[26])
            1'b0: a=forword_r1;///
            1'b1: a=EX_pc; 
            default: a=forword_r1;
        endcase
    end

    always @(*) begin    //r2 imm
        case (EX_control[25])     
            1'b0: b=forword_r2;///换
            1'b1: b=EX_imm;
            default: b=forword_r2;
        endcase
    end



//reg写回选择
    always @(*) begin
        case (MEM_control[29:28])
            2'b00: reg_wdata=MEM_c;
            2'b01: reg_wdata=load_data;
            2'b10: reg_wdata=MEM_imm;
            2'b11: reg_wdata=MEM_pc4;
            default: reg_wdata=read_data;
        endcase
    end
    
endmodule
