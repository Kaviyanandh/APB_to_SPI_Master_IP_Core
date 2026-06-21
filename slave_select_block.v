module spi_slave_select(
    input pclk,presetn,mstr_i,spiswai_i,send_data_i,
    input [1:0]spimode_i,
    input [11:0]baudRateDivisor_i, 
    output reg receive_data_o,ss_o, 
    output tip_o);
 
    wire [15:0]target; 
    reg rcv; 
    reg [15:0]count; 

    assign target= (4'd8)*(baudRateDivisor_i); 
    assign tip_o=~ss_o; 

    always @(posedge pclk or negedge presetn) begin 
        if(!presetn) 
            receive_data_o<=1'b0; 
        else 
            receive_data_o<=rcv; 
    end 
 
    always@(posedge pclk or negedge presetn) begin 
        if(!presetn) begin 
            ss_o<=1'b1; 
            count<=16'hffff; 
            rcv<=1'b0; 
        end 
        else begin 
            if(mstr_i && !spiswai_i && (spimode_i==2'b00||spimode_i==2'b01))begin 
                if(send_data_i) begin 
                    ss_o<=1'b0; 
                    rcv<=1'b0; 
                    count<=16'd0; 
                end 
                else if (count<=target-1'b1) begin 
                    ss_o<=1'b0; 
                    count<=count+1'd1; 
                        if(count==target-1'b1) 
                            rcv<=1'b1; 
                        else 
                            rcv<=1'b0; 
                end 
                else begin 
                    ss_o<=1'b1; 
                    rcv<=1'b0; 
                    count<=16'hffff; 
                end 
            end 
            else begin 
                ss_o<=1'b1; 
                rcv<=1'b0; 
                count<=16'hffff; 
            end 
        end 
    end 
endmodule