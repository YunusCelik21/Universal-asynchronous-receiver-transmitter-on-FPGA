`timescale 1ns / 1ps

module transmitter(input logic clk,
                   input logic load,
                   input logic send,
                   input logic[7:0] data,
                   output logic[7:0] most_recent_loaded,
                   output logic TX,
                   output logic[7:0] TXBUF[3:0]);
                   
    parameter DATA_BITS = 8;
    parameter PARITY_BITS = 1;
    parameter STOP_BITS = 1;
    parameter PARITY = 1'b1; // 0 == even parity, 1 == odd parity
    
    reg[2:0] N = 3'b000; reg[2:0] S;
    reg parity_bit;
    
    reg[3:0] bit_counter = 4'b0000; 
    reg bit_counter_clr = 0;
    reg bit_counter_en = 0;
    
    reg TXBUF_clr = 1;
    reg TXBUF_shift = 0;
    
    memory_array mem(TXBUF_shift, TXBUF_clr, data, TXBUF);
    assign most_recent_loaded = TXBUF[0];
    
    always_ff @(posedge clk) begin 
        TXBUF_clr = 0;
        TXBUF_shift <= load;
        
        if (bit_counter_clr) begin
            bit_counter <= 4'b0000;
        end    
        else if (bit_counter_en) begin
            bit_counter <= bit_counter + 1;
        end
                
        S <= N;
    end
    
    always_comb begin 
        case (S)
            3'b000: begin
                TX = 1;
                if (send)
                    N = 3'b001;
                else
                    N = 3'b000;
            end
            
            3'b001: begin
                TX = 0;
                bit_counter_clr = 1;
                parity_bit = PARITY; 
                N = 3'b010;
            end
            
            3'b010: begin
                TX = TXBUF[3][bit_counter];
                bit_counter_clr = 0;
                bit_counter_en = 1;
                if (bit_counter == 4'b0111) begin
                    N = 3'b011;
                end
                else begin
                    N = 3'b010;
                end
                    
                if (data[bit_counter] == 1'b1) begin
                    parity_bit = ~parity_bit;
                end
            end
            
            3'b011: begin
                // assuming parity bits is 1 for now
                TX = parity_bit;
                N = 3'b100;
                bit_counter_en = 0;
            end
            
            3'b100: begin
                // assuming stp bits is 1 for now
                TX = 1;
                if (send) begin
                    N = 3'b100;
                end
                else begin
                    N = 3'b000;
                end
                
            end

        endcase
    end
    
endmodule