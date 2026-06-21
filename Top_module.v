module top_module(
    input pclk,presetn,
    input [2:0]paddr_i, 
    input psel_i,penable_i,pwrite_i, 
    input [7:0]pwdata_i,
    input miso_i,
 
    output [7:0] prdata_o, 
    output pready_o,pslverr_o,mosi_o, 
    output ss_o,sclk_o,spi_interrupt_request); 
  
    wire [1:0]spi_mode_t; 
    wire spiswai_t,cpol_t,cpha_t,mosi_send_sclk_t,mosi_send_sclk0_t,miso_recive_sclk_t,miso_recive_sclk0_t; 
    wire [11:0]BaudrateDivisor_t; 
    wire mstr_t; 
    wire [2:0]sppr_t,spr_t; 
    wire send_data_t,receive_data_t,tip_t,lsbfe_t; 
    wire [7:0]data_mosi_t; 
    wire [7:0]data_miso_t; 
 
 
    Baud_rate_generator baud_rate(
        .pclk(pclk), 
        .presetn(presetn), 
        .spi_mode_i(spi_mode_t), 
        .spiswai_i(spiswai_t), 
        .sppr_i(sppr_t), 
        .spr_i(spr_t), 
        .cpol_i(cpol_t), 
        .cpha_i(cpha_t), 
        .ss_i(ss_o), 
        .sclk(sclk_o), 
        .mosi_send_sclk_o(mosi_send_sclk_t), 
        .mosi_send_sclk0_o(mosi_send_sclk0_t), 
        .miso_recive_sclk_o(miso_recive_sclk_t), 
        .miso_recive_sclk0_o(miso_recive_sclk0_t), 
        .BaudrateDivisor_o(BaudrateDivisor_t)
    ); 
 
 
    spi_slave_select slave_select(
        .pclk(pclk), 
        .presetn(presetn), 
        .mstr_i(mstr_t), 
        .spiswai_i(spiswai_t), 
        .spimode_i(spi_mode_t), 
        .send_data_i(send_data_t), 
        .baudRateDivisor_i(BaudrateDivisor_t), 
        .receive_data_o(receive_data_t), 
        .ss_o(ss_o), 
        .tip_o(tip_t)
    ); 
  
 
    Shift_reg shift_register(
        .pclk(pclk), 
        .presetn(presetn), 
        .ss_i(ss_o), 
        .send_data_i(send_data_t), 
        .lsbfe_i(lsbfe_t), 
        .cpha_i(cpha_t), 
        .cpol_i(cpol_t), 
        .miso_receive_sclk0(miso_recive_sclk0_t), 
        .miso_receive_sclk(miso_recive_sclk_t), 
        .mosi_send_sclk0(mosi_send_sclk0_t), 
        .mosi_send_sclk(mosi_send_sclk_t), 
        .data_mosi_i(data_mosi_t), 
        .miso_i(miso_i), 
        .receive_data_i(receive_data_t), 
        .mosi_o(mosi_o), 
        .data_miso_o(data_miso_t)
    ); 
 
    APB_slave slave_interface(
        .pclk(pclk), 
        .presetn(presetn), 
        .paddr_i(paddr_i), 
        .pwrite_i(pwrite_i), 
        .psel_i(psel_i), 
        .penable_i(penable_i), 
        .pwdata_i(pwdata_i), 
        .ss_i(ss_o), 
        .miso_data(data_miso_t), 
        .receive_data_i(receive_data_t), 
        .tip_i(tip_t), 
        .prdata(prdata_o), 
        .mstr_o(mstr_t), 
        .cpol_o(cpol_t), 
        .cpha_o(cpha_t), 
        .lsbfe_o(lsbfe_t), 
        .spiswai_o(spiswai_t), 
        .sppr_o(sppr_t), 
        .spr_o(spr_t), 
        .spi_interrupt_reqest(spi_interrupt_request), 
        .pready(pready_o), 
        .pslverr(pslverr_o), 
        .send_data_o(send_data_t), 
        .mosi_data_o(data_mosi_t), 
        .spi_mode_o(spi_mode_t)
    ); 

endmodule 
 