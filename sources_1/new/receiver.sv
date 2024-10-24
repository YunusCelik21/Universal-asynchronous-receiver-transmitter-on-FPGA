`timescale 1ns / 1ps

module receiver(input logic clk,
                input logic RX,
                output logic[7:0] oldest_received,
                output logic[7:0] RXBUF[3:0]);
    
    parameter DATA_BITS = 8;
    parameter PARITY_BITS = 1;
    parameter STOP_BITS = 1;
    parameter PARITY = 1; // 0 == even parity, 1 == odd parity
    
    reg[2:0] N = 3'b000; reg[2:0] S;
    
    reg[3:0] bit_counter = 4'b0000;
    reg bit_counter_en = 0;
    reg bit_counter_clr = 0;
    reg[7:0] received_data;
    reg parity_bit;    
    
    reg RXBUF_clr = 1;
    reg RXBUF_shift = 0;
    
    memory_array mem(RXBUF_shift, RXBUF_clr, received_data, RXBUF);
    assign oldest_received = RXBUF[3];
    
    always_ff @(posedge clk) begin
         RXBUF_clr <= 0;
            
         if (bit_counter_clr)
            bit_counter <= 4'b0000;   
         else if (bit_counter_en)
            bit_counter <= bit_counter + 1;
         
         if (S == 3'b010)
            received_data[bit_counter] <= RX; 
         
         S <= N;
    end
    
    always_comb begin
        case(S)
            3'b000: begin
                RXBUF_shift = 0;
                N = 3'b001;
            end
            
            3'b001: begin
                bit_counter_clr = 1;
                if (RX == 1'b0)
                    N = 3'b010;
                else
                    N = 3'b001;
            end
            
            3'b010: begin
                bit_counter_clr = 0;
                // starts to recieve data
                if (bit_counter == 4'b0111) 
                    N = 3'b011;
                else 
                    N = 3'b010;
                     
                bit_counter_en = 1;
            end
            
            3'b011: begin
                bit_counter_en = 0;
                parity_bit = RX;
                N = 3'b100;
            end
            
            3'b100: begin
                // receives stop bit
                RXBUF_shift = 1;
                N = 3'b000;
            end
        endcase
    end
endmodule
