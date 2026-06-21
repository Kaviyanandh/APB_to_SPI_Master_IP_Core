module top_module_tb(); 
    reg pclk,presetn; 
    reg [2:0]paddr_i; 
    reg psel_i,penable_i,pwrite_i; 
    reg [7:0]pwdata_i; 
    reg miso_i; 
    
    wire [7:0] prdata_o; 
    wire pready_o,pslverr_o,mosi_o; 
    wire ss_o,sclk_o,spi_interrupt_request; 
 
    top_module DUT (
        pclk,
        presetn,
        paddr_i,
        psel_i,
        penable_i,
        pwrite_i,
        pwdata_i,
        miso_i,
        prdata_o,
        pready_o,
        pslverr_o,
        mosi_o,
        ss_o,
        sclk_o,
        spi_interrupt_request); 
  
 
    always begin 
        #20 pclk=1'b0;   
        #20 pclk=~pclk; 
    end 
 
    task reset(); 
        begin 
            @(negedge pclk); 
                presetn=1'b0; 
            @(negedge pclk); 
                presetn=1'b1; 
        end 
    endtask 
 
    task spi_config_reg(input [7:0]data, input [2:0]addr); 
    begin 
        @(negedge pclk); 
            paddr_i=addr; 
            pwdata_i=data; 
            psel_i=1'b1; 
            penable_i=1'b0; 
            pwrite_i=1'b1; 
        @(negedge pclk); 
            penable_i=1'b1; 
        wait(!pready_o) 
        @(negedge pclk); 
            psel_i=1'b0; 
            penable_i=1'b0; 
        @(negedge pclk); 
    end 
    endtask 
 
    task spi_config_sr(input [2:0]addr); 
    begin 
        @(negedge pclk); 
            paddr_i=addr; 
            psel_i=1'b1; 
            penable_i=1'b0; 
            pwrite_i=1'b0; 
        @(negedge pclk); 
            penable_i=1'b1; 
        wait(!pready_o) 
        @(negedge pclk); 
            psel_i=1'b0; 
            penable_i=1'b0; 
        @(negedge pclk); 
    end 
    endtask 
  
    task initialize(); 
    begin 
        {presetn,paddr_i,psel_i,penable_i,pwrite_i,pwdata_i,miso_i}=0; 
    end 
    endtask 
 
    initial begin 
        initialize(); 
        reset(); 
        miso_i=1'b1; 
        spi_config_reg(8'b0101_0111,3'd0); 
        spi_config_reg(8'b01010101,3'd1); 
        spi_config_reg(8'b0000_0000,3'd2); 
        spi_config_reg(8'b1101_1011,3'd5); 
        spi_config_sr(3'd3); 
        spi_config_sr(3'd0); 
        spi_config_sr(3'd1); 
        spi_config_sr(3'd2); 
        spi_config_sr(3'd5); 
    end 
 
    initial begin 
        #5000; 
        $finish; 
    end 
endmodule 
 
