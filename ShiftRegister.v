module Shift_reg
(
    input pclk,presetn,
    input ss_i,
    input send_data_i, 
    input lsbfe_i,cpha_i,cpol_i, 
    input miso_receive_sclk0, 
    input miso_receive_sclk,   
    input mosi_send_sclk0, 
    input mosi_send_sclk, 
    input [7:0]data_mosi_i, 
    input miso_i,receive_data_i, 
    output reg mosi_o, 
    output [7:0]data_miso_o
); 
  
reg [7:0]shift_reg,temp; 
reg [2:0]count,count1,count2,count3; 
wire spimode; 
  
assign spimode=((~cpol_i && cpha_i)||(cpol_i && ~cpha_i)); 
assign data_miso_o = (receive_data_i)?temp:8'd0; 
 
always @(posedge pclk or negedge presetn) begin
    if(!presetn) 
    shift_reg<=8'd0;

    else begin 
    if(send_data_i) 
            shift_reg<=data_mosi_i; 
    else 
            shift_reg<=shift_reg; 
    end 
end 

always@(posedge pclk or negedge presetn) begin
    if(!presetn)begin 
        count2<=3'd0; 
        count3<=3'd7; 
        temp<=8'd0; 
    end

    else begin 
        if(ss_i) begin 
            count2<=count2; 
            count3<=count3; 
            temp<=temp; 
        end 
    else begin 
        if(spimode) begin 
            if(lsbfe_i) begin 
                if(count2<=3'd7) begin 
                    if(miso_receive_sclk0) begin 
                        count2<=count2+3'd1; 
                        temp[count2]<=miso_i; 
                    end 
                    else begin 
                        count2<=count2; 
                        temp[count2]<=temp[count2]; 
                    end 
                end 
                else begin 
                    count2<=3'd0; 
                    temp[count2]<=0; 
                end 
            end 
            else begin 
                if(count3>=3'd0) begin 
                    if(miso_receive_sclk0) begin 
                        count3<=count3-3'd1; 
                        temp[count3]<=miso_i; 
                    end 
                    else begin 
                        count3<=count3; 
                        temp[count3]<=temp[count3]; 
                    end 
                end 
                else begin 
                    count3<=3'd7; 
                    temp[count3]<=0; 
                end 
            end 
        end 
        else begin 
            if(lsbfe_i) begin 
                if(count2<=3'd7) begin 
                    if(miso_receive_sclk) begin 
                        count2<=count2+3'd1; 
                        temp[count2]<=miso_i; 
                    end 
                    else begin 
                        count2<=count2; 
                        temp[count2]<=temp[count2]; 
                    end 
                end 
                else begin 
                    count2<=3'd0; 
                    temp[count2]<=0; 
                end 
            end 
            else begin 
                if(count3>=3'd0) begin 
                    if(miso_receive_sclk) begin 
                        count3<=count3-3'd1; 
                        temp[count3]<=miso_i; 
                    end 
                    else begin 
                        count3<=count3; 
                        temp[count3]<=temp[count3]; 
                    end 
                end 
                else begin 
                    count3<=3'd7; 
                    temp[count3]<=0; 
                end 
            end 
        end 
    end 
    end 
end 
  
always@(posedge pclk or negedge presetn) begin 
    if(!presetn)begin 
        count<=3'd0; 
        count1<=3'd7; 
        mosi_o<=0; 
    end 
    else begin 
        if(ss_i) begin 
            count<=count; 
            count1<=count1; 
            mosi_o<=mosi_o; 
        end 
        else begin 
            if(spimode) begin 
                if(lsbfe_i) begin 
                    if(count<=3'd7) begin 
                        if(mosi_send_sclk) begin 
                            count<=count+3'd1; 
                            mosi_o<=shift_reg[count]; 
                        end 
                        else begin 
                            count<=count; 
                            mosi_o<=mosi_o; 
                        end 
                    end 
                    else begin 
                        count<=3'd0; 
                        mosi_o<=0; 
                    end 
                end 
            else begin 
                if(count1>=3'd0) begin 
                    if(mosi_send_sclk) begin 
                        count1<=count1-3'd1; 
                        mosi_o<=shift_reg[count1]; 
                    end 
                    else begin 
                        count1<=count1; 
                        mosi_o<=mosi_o; 
                    end 
                end 
                else begin 
                    count1<=3'd7; 
                    mosi_o<=0; 
                end 
            end 
        end 
        else begin 
            if(lsbfe_i) begin 
                if(count<=3'd7) begin 
                    if(mosi_send_sclk0) begin 
                        count<=count+3'd1; 
                        mosi_o<=shift_reg[count]; 
                    end 
                    else begin 
                        count<=count; 
                        mosi_o<=mosi_o; 
                    end 
                end 
                else begin 
                    count<=3'd0; 
                    mosi_o<=0; 
                end 
            end 
            else begin 
                if(count1>=3'd0) begin 
                    if(mosi_send_sclk0) begin 
                        count1<=count1-3'd1; 
                        mosi_o<=shift_reg[count1]; 
                    end 
                    else begin 
                        count1<=count1; 
                        mosi_o<=mosi_o; 
                    end 
                end 
                else begin 
                    count1<=3'd7; 
                    mosi_o<=0; 
                end 
            end 
        end 
    end 
  end 
end 
endmodule 
