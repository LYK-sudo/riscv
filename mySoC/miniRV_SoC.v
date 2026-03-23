// Add your code here, or replace this file.
`timescale 1ns / 1ps
module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,
    output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output              debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output wire [31:0]  debug_wb_value

);

    wire [31:0] read_data,inst,pc,c,r2;
    wire [2:0] funct3;
    wire wmem;
   
    // cpu cpu(
    //     .clk(fpga_clk),
    //     .rst(fpga_rst),
    //     .read_data(read_data),
    //     .inst(inst),
    //     .pc(pc),
    //     .c(c),
    //     .r2(r2),
    //     .funct3(funct3),
    //     .wmem(wmem),
    //     .wreg(debug_wb_ena),
    //     .debug_wb_reg(debug_wb_reg),
    //     .debug_wb_value(debug_wb_value)
    // );
    cpu cpu(
        .clk(fpga_clk),
        .rst(fpga_rst),
        .read_data(read_data),
        .inst(inst),

        .pca(pc),
        .addra(c),
        .dina(r2),
        .funct3(funct3),
        .w_data(wmem),
        .debug_wb_have_inst(debug_wb_have_inst),
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_ena(debug_wb_ena),
        .debug_wb_reg(debug_wb_reg),
        .debug_wb_value(debug_wb_value)
    );
    //assign debug_wb_have_inst=0;
    IROM Mem_IROM (
        .a          (pc[15:2]),
        .spo        (inst)
    );
    
    DM Mem_DRAM (
        .clk        (fpga_clk),
        .addr          (c[15:0]),
        .spo        (read_data),
        .we         (wmem),
        .d          (r2),
        .funct3     (funct3)
    );

    
endmodule


// `timescale 1ns / 1ps

// `include "defines.vh"

// module miniRV_SoC (
//     input  wire         fpga_rst,   // High active
//     input  wire         fpga_clk,

//     output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
//     output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
//     output              debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
//     output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
//     output wire [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
// //`endif
// );

//     wire        pll_lock;
//     wire        pll_clk;
//     wire        cpu_clk;


//     wire [15:0] inst_addr;

//     wire [31:0] inst;


//     wire [31:0] Bus_rdata;
//     wire [31:0] Bus_addr;
//     wire        Bus_wen;
//     wire [31:0] Bus_wdata;
    
    
//     assign cpu_clk = fpga_clk;

    
//     myCPU Core_cpu (
//         .cpu_rst            (fpga_rst),
//         .cpu_clk            (cpu_clk),

//         // Interface to IROM
//         .inst_addr          (inst_addr[15:2]),
//         .inst               (inst),

//         // Interface to Bridge
//         .Bus_addr           (Bus_addr),
//         .Bus_rdata          (Bus_rdata),
//         .Bus_wen            (Bus_wen),
//         .Bus_wdata          (Bus_wdata)

//         ,// Debug Interface
//         .debug_wb_have_inst (debug_wb_have_inst),
//         .debug_wb_pc        (debug_wb_pc),
//         .debug_wb_ena       (debug_wb_ena),
//         .debug_wb_reg       (debug_wb_reg),
//         .debug_wb_value     (debug_wb_value)
//     );
    
//     IROM Mem_IROM (
//         .a          (inst_addr[15:2]),
//         .spo        (inst)
//     );

//     DRAM Mem_DRAM (
//         .clk        (cpu_clk),
//         .a          (Bus_addr[15:2]),
//         .spo        (Bus_rdata),
//         .we         (Bus_wen),
//         .d          (Bus_wdata)
//     );
    
//     // TODO: 在此实例化你的外设I/O接口电路模块
//     //


// endmodule
