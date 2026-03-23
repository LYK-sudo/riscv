module IM(
    input [31:0] addr,
    output [31:0] inst_out
);
    reg [31:0] inst_rom [0:256*32-1];
    initial begin
        //$readmemh("C:\\Users\\LYK\\Desktop\\rars\\inst",inst_rom);
        $readmemh("C:\\Users\\LYK\\Desktop\\riscv_design\\all_dan\\new_liusx\\inst_testbench.mem",inst_rom);
        //$display("test.mem success!");
    end

    assign inst_out=(addr>=32'h00400000&&addr<=32'h004fffff)?inst_rom[(addr-32'h00400000)>>2]:0;

endmodule