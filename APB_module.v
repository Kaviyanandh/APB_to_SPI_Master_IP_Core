module APB_slave(
 input pclk,presetn,
 input [2:0]paddr_i, 
 input pwrite_i,
 input psel_i,penable_i, 
 input [7:0]pwdata_i,
 input ss_i,
 input [7:0]miso_data, 
 input receive_data_i,tip_i, 
 
 output reg [7:0]prdata,
 output mstr_o,cpol_o,cpha_o,lsbfe_o, 
 output spiswai_o, 
 output [2:0]sppr_o,spr_o, 
 output reg spi_interrupt_reqest, 
 output pready,pslverr,
 output reg send_data_o, 
 output reg [7:0]mosi_data_o, 
 output reg [1:0]spi_mode_o);
 
 reg [7:0] SPI_CR1,SPI_CR2,SPI_BR,SPI_DR; 
 wire [7:0]SPI_SR; 
 wire spie,spe,sptie,ssoe; 
 wire modf; 
 wire modfen; 
 wire spif,sptef; 
 wire wr_enb,rd_enb; 
  
 reg [2:0]state, next_state; 
 reg [1:0]next_mode; 
 
 parameter  idle=3'd3, 
            setup=3'd4, 
            enable=3'd5, 
            spi_run=2'd0, 
            spi_wait=2'd1, 
            spi_stop=2'd2; 
 
 parameter cr2_mask=8'b00011011; 
 parameter br_mask=8'b01110111; 
  
 assign pready= (state==enable)? 1'b1:1'b0;

 assign wr_enb= (state==enable && pwrite_i)? 1'b1:1'b0; 
 assign rd_enb= (state==enable && !pwrite_i)? 1'b1:1'b0; 

 assign pslverr= (state==enable)? (~tip_i): 1'b0;
 
 assign SPI_SR= (!presetn)? 8'b00100000: {spif,1'b0,sptef,modf,4'd0}; 

 assign modf= (~ss_i) & mstr_o & modfen & (~ssoe); 
 assign sptef= (SPI_DR == 8'd0)? 1'b1: 1'b0; 
 assign spif= (SPI_DR != 8'd0)? 1'b1:1'b0; 
  
    always @(*) begin 
        if(!rd_enb) 
            prdata=8'd0; 
        else begin 
            case(paddr_i) 
                3'd0:prdata=SPI_CR1; 
                3'd1:prdata=SPI_CR2; 
                3'd2:prdata=SPI_BR; 
                3'd3:prdata=SPI_SR; 
                3'd5:prdata=SPI_DR; 
                default:prdata=8'd0; 
            endcase 
        end 
    end 
  
  
    assign lsbfe_o = SPI_CR1[0]; 
    assign ssoe = SPI_CR1[1]; 
    assign cpha_o = SPI_CR1[2]; 
    assign cpol_o = SPI_CR1[3]; 
    assign mstr_o = SPI_CR1[4]; 
    assign sptie = SPI_CR1[5]; 
    assign spe = SPI_CR1[6]; 
    assign spie = SPI_CR1[7]; 
    assign modfen = SPI_CR2[4]; 
    assign spiswai_o = SPI_CR2[1]; 
    assign sppr_o = SPI_BR[6:4]; 
    assign spr_o = SPI_BR[2:0]; 
  
  
    always @(*) begin 
        if(~spie & ~sptie) 
            spi_interrupt_reqest=1'b0; 
        else begin 
            if(~sptie & spie) 
                spi_interrupt_reqest= spif | modf; 
            else begin 
                if (sptie & ~spie) 
                    spi_interrupt_reqest=sptef; 
                else 
                    spi_interrupt_reqest=spif | modf | sptef; 
                end 
        end 
    end 
 
    always @(posedge pclk or negedge presetn) begin 
        if(!presetn) 
            state<=idle; 
        else 
            state<=next_state; 
    end 
 
    always @(*) begin 
        next_state=idle; 
            case(state) 
                idle:begin 
                    if(psel_i && !penable_i) 
                        next_state=setup; 
                    else 
                        next_state=idle; 
                end 
                setup: begin 
                    if(psel_i && !penable_i) 
                        next_state=setup; 
                    else if(psel_i && penable_i) 
                        next_state=enable; 
                    else 
                        next_state=idle; 
                end 
                enable:begin 
                    if(psel_i) 
                        next_state=setup; 
                    else 
                        next_state=idle; 
                end 
            endcase 
    end 
 
    always @(posedge pclk or negedge presetn) begin 
        if(!presetn) 
            spi_mode_o<=spi_run; 
        else 
            spi_mode_o<=next_mode; 
    end 
 
    always @(*) begin 
        next_mode=spi_run; 
        case(spi_mode_o) 
            spi_run:begin 
                if(!spe) 
                    next_mode=spi_wait; 
                else 
                    next_mode=spi_run; 
                end 
            spi_wait:begin 
                if(spiswai_o) 
                    next_mode=spi_stop; 
                else if(spe) 
                    next_mode=spi_run; 
                else 
                    next_mode=spi_wait; 
            end 
            spi_stop:begin 
                if(!spiswai_o) 
                    next_mode=spi_wait; 
                else if(spe) 
                    next_mode=spi_run; 
                else 
                    next_mode=spi_stop; 
            end 
        endcase 
    end 
 
    always @(posedge pclk or negedge presetn)begin 
        if(!presetn) 
            send_data_o<=0; 
        else begin 
            if(wr_enb) 
                send_data_o<=1'd0; 
            else begin 
                if((SPI_DR == pwdata_i) && (SPI_DR != miso_data) && (spi_mode_o == spi_run || spi_mode_o == spi_wait)) 
                    send_data_o<=1'b1; 
                else 
                    send_data_o<=1'd0; 
            end 
        end 
    end 
  
    always @(posedge pclk or negedge presetn)begin 
        if(!presetn) 
            mosi_data_o<=8'd0; 
        else begin 
            if((SPI_DR==pwdata_i) && (SPI_DR != miso_data) && (spi_mode_o == spi_run || spi_mode_o == spi_wait)) 
                mosi_data_o<=SPI_DR; 
        else 
            mosi_data_o<=mosi_data_o; 
        end 
    end 
 
    always @(posedge pclk or negedge presetn)begin 
        if(!presetn) begin 
            SPI_CR1<=8'h04; 
            SPI_CR2<=8'd0; 
            SPI_BR<=8'd0; 
            SPI_DR<=8'd0; 
        end 
        else begin 
            if(!wr_enb) begin 
                SPI_CR1<=SPI_CR1; 
                SPI_CR2<=SPI_CR2; 
                SPI_BR<=SPI_BR; 
                if((SPI_DR==pwdata_i) && (SPI_DR != miso_data) && (spi_mode_o == spi_run || spi_mode_o == spi_wait)) 
                    SPI_DR<=8'd0; 
            else begin 
                if(receive_data_i && (spi_mode_o == spi_run || spi_mode_o == spi_wait)) 
                    SPI_DR<=miso_data; 
                else 
                    SPI_DR<=SPI_DR; 
            end 
        end 
        else begin 
            SPI_CR1<= (paddr_i==3'd0)? pwdata_i : SPI_CR1; 
            SPI_CR2<= (paddr_i==3'd1)? (pwdata_i & cr2_mask): SPI_CR2; 
            SPI_BR<= (paddr_i==3'd2)? (pwdata_i & br_mask): SPI_BR; 
            SPI_DR<= (paddr_i==3'd5)? pwdata_i:SPI_DR; 
        end 
    end 
end 
endmodule 
