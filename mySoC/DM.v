module DM # (
    ADDR_BITS = 16
)(
    input clk,
    input [ADDR_BITS - 1: 0] addr,
    input  we,
    input [31:0] d,
    input [2:0] funct3,
    output [31:0] spo,
    output  [31:0] out_data
);
    wire [ADDR_BITS - 1: 0] a;
    assign a = addr>>2;
    integer i, j, mem_file;
    // (* RAM_STYLE="BLOCK" *)
    reg [32-1:0] mem[(2**20)-1:0];
    reg [32-1:0] mem_rd[(2**20)-1:0];

    assign out_data=mem[a];
    wire [31:0] rdata;
    assign rdata=mem[a];//？？？？？？？？？？？？？？

    wire [7:0] load_byte;
    wire [15:0] load_half;
    reg [31:0] load_data;

    assign load_half=addr[1]?rdata[31:16]:rdata[15:0];
    assign load_byte=addr[0]?load_half[15:8]:load_half[7:0];

    always @(*) begin    //I
        case (funct3)
            3'b000: load_data = {{24{load_byte[7]}},load_byte};
            3'b001: load_data = {{16{load_half[15]}},load_half};
            3'b010: load_data = rdata;
            3'b100: load_data = {24'd0,load_byte};
            3'b101: load_data = {16'd0,load_half};
            default: load_data=0;
        endcase
    end

    assign spo=load_data;//????????????we


    reg [31:0] wdata;

    always @(*) begin   //S
        case (funct3)
            3'b000:begin
                case (addr[1:0])
                    2'b00: wdata = {rdata[31:8],d[7:0]};
                    2'b01: wdata = {rdata[31:16],d[7:0],rdata[7:0]};
                    2'b10: wdata = {rdata[31:24],d[7:0],rdata[15:0]};
                    2'b11: wdata = {d[7:0],rdata[23:0]};
                    default: wdata=rdata;
                endcase
            end
            3'b001: wdata = addr[1]? {d[15:0],rdata[15:0]}:{rdata[31:16],d[15:0]};
            3'b010: wdata = d;
            default: wdata= rdata;
        endcase
    end




    initial begin
        // two nested loops for smaller number of iterations per loop
        // workaround for synthesizer complaints about large loop counts
        for (i = 0; i < 2**20; i = i + 2**(20/2)) begin
            for (j = i; j < i + 2**(20/2); j = j + 1) begin
                mem[j] = 0;
            end
        end
        mem_file = $fopen(`STRINGIFY(`PATH), "r");
        if(mem_file == 0) begin
            $display("[ERROR] Open file %s failed, please check whether file exists!\n", `STRINGIFY(`PATH));
            $fatal;
        end
        $display("[INFO] Data RAM initialized with %s", `STRINGIFY(`PATH));
        $fread(mem_rd, mem_file);
        for (i = 0; i < 2**20; i = i + 2**(20/2)) begin
            for (j = i; j < i + 2**(20/2); j = j + 1) begin
                mem[j] = {{mem_rd[j][07:00]}, {mem_rd[j][15:08]}, {mem_rd[j][23:16]}, {mem_rd[j][31:24]}};
            end
        end
    end

    //assign spo = mem[a];

    always @(posedge clk) begin
        if (we) mem[a]<= wdata;
        
    end

endmodule