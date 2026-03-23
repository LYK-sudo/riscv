module bht (
    input clk,
    input rst,
    input [9:0] ID_index,//pc
    //input branch,
    input update_en,//predict false
    input [9:0] update_pc,
    input pre_result,
    output predict
);
    reg [1:0] counter [0:1023];
    integer i;
    initial begin
        for(i=0;i<1024;i=i+1)
            counter[i]=2'b01;
    end

    assign predict=counter[ID_index][1];

    always @(posedge clk ) begin
        if(rst)begin
            
        end
        else if(update_en)begin
            case (counter[update_pc])
                2'b00:begin
                    if(pre_result)counter[update_pc]<=2'b01;
                    else counter[update_pc]<=2'b00;
                end 
                2'b01:begin
                    if(pre_result)counter[update_pc]<=2'b10;
                    else counter[update_pc]<=2'b00;
                end 
                2'b10:begin
                    if(pre_result)counter[update_pc]<=2'b11;
                    else counter[update_pc]<=2'b01;
                end 
                2'b11:begin
                    if(pre_result)counter[update_pc]<=2'b11;
                    else counter[update_pc]<=2'b10;
                end 
                //default: 
            endcase
        end
    end

endmodule