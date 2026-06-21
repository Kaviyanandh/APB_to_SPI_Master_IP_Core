module Baud_rate_generator( 
    input pclk, 
    input presetn, 
    input [1:0]spi_mode_i, 
    input spiswai_i, 
    input [2:0]sppr_i, 
    input [2:0]spr_i, 
    input cpol_i,
    input cpha_i,
    input ss_i, 
    output reg sclk, 
    output reg mosi_send_sclk_o, 
    output reg mosi_send_sclk0_o, 
    output reg miso_recive_sclk_o, 
    output reg miso_recive_sclk0_o, 
    output [11:0]BaudrateDivisor_o 
); 

    wire pre_sclk; 
    reg [11:0]count; 
    wire spimode; 

    assign BaudrateDivisor_o = ((sppr_i + 1'b1) * 2**((spr_i + 1'b1))); 
    assign pre_sclk = (cpol_i == 1) ? 1'b1 : 1'b0; 
 
    always @(posedge pclk or negedge presetn) begin 
        if (!presetn) 
            sclk <= pre_sclk; 
        else if ((spi_mode_i == 2'b00 || spi_mode_i == 2'b01) && !ss_i && !spiswai_i) begin 
            if (count == ((BaudrateDivisor_o) / 2) - 1'b1) 
                sclk <= ~sclk; 
            else 
                sclk <= sclk; 
        end 
        else 
            sclk <= pre_sclk; 
    end

    always @(posedge pclk or negedge presetn) begin 
        if (!presetn) 
            count <= 0; 
        else if ((spi_mode_i == 2'b00 || spi_mode_i == 2'b01) && !ss_i && !spiswai_i) begin 
            if (count == ((BaudrateDivisor_o) / 2) - 1'b1) 
                count <= 0; 
            else 
                count <= count + 1'b1; 
        end 
        else 
            count <= count; 
    end 
 
    assign spimode = ((~cpha_i & cpol_i) || (cpha_i & ~cpol_i)); 
 
    always @(posedge pclk or negedge presetn) begin 
        if (!presetn) begin 
            mosi_send_sclk_o  <= 0; 
            mosi_send_sclk0_o <= 0; 
        end
        else if (!spimode) begin 
            if (sclk) begin 
                if (count == (BaudrateDivisor_o / 2) - 2'b10) 
                    mosi_send_sclk_o <= 1'b1; 
                else 
                    mosi_send_sclk_o <= 1'b0; 
            end 
            else 
                mosi_send_sclk_o <= 1'b0; 
        end  
        else begin 
            if (!sclk) begin 
                if (count == (BaudrateDivisor_o / 2) - 2'b10) 
                    mosi_send_sclk0_o <= 1'b1; 
                else 
                    mosi_send_sclk0_o <= 1'b0; 
            end 
            else 
                mosi_send_sclk0_o <= 1'b0; 
        end 
    end 
 
    always @(posedge pclk or negedge presetn) begin 
        if (!presetn) begin 
            miso_recive_sclk_o  <= 0; 
            miso_recive_sclk0_o <= 0; 
        end 
        else if (!spimode) begin 
            if (sclk) begin 
                if (count == (BaudrateDivisor_o / 2) - 1'b1) 
                    miso_recive_sclk0_o <= 1'b1; 
                else 
                    miso_recive_sclk0_o <= 1'b0; 
            end 
            else 
                miso_recive_sclk0_o <= 1'b0; 
        end 
        else begin 
            if (!sclk) begin 
                if (count == (BaudrateDivisor_o / 2) - 1'b1) 
                    miso_recive_sclk_o <= 1'b1; 
                else 
                    miso_recive_sclk_o <= 1'b0; 
            end 
            else 
                miso_recive_sclk_o <= 1'b0; 
        end 
    end 
 
endmodule