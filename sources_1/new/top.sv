`timescale 1ns / 1ps

module top(input logic clk,
           input logic load,
           input logic send,
           input logic left,
           input logic right,
           input logic switch_memory, 
           input logic transfer_mode, // 0 == regular, 1 == contiuous - leftmost switch
           input logic[7:0] data, // rightmost 8 switches
           output logic[15:0] buffers,
           output logic[0:6] seg,
           output logic[3:0] an);
           
    wire clk_115_200Hz;
    wire clk_100Hz;
      
    reg TX_RX_LINE;
    reg[7:0] TXBUF[3:0];
    reg[7:0] RXBUF[3:0];
    clk_gen c1(clk, clk_115_200Hz);
    clk_gen_100Hz c2(clk, clk_100Hz);
    
    reg shift_left = 0;
    reg shift_right = 0;
    reg change_memory = 0;
    
    reg load_mode; reg send_mode; reg[7:0] data_mode;
    reg[3:0] counter = 4'b0000; reg counter_en = 0; reg counter_clr = 0;
    reg[1:0] counter_send = 2'b00; reg counter_send_en = 0; reg counter_send_clr = 0; 
    reg[2:0] N = 3'b000; reg[2:0] S;
    
    transmitter t(clk_115_200Hz, load_mode, send_mode, data_mode, buffers[7:0], TX_RX_LINE, TXBUF);
    receiver r(clk_115_200Hz, TX_RX_LINE, buffers[15:8], RXBUF);
    seven_segment s(clk_100Hz, left, right, switch_memory, TXBUF, RXBUF, seg, an);
    
    always @(posedge clk_115_200Hz) begin
        S <= N;
        
        if (counter_clr) begin
            counter <= 4'b00;
        end
        else if (counter_en) begin
            counter <= counter + 1;
        end 
        
        if (counter_send_clr) begin
            counter_send <= 2'b00;
        end
        else if (counter_send_en) begin
            counter_send <= counter_send + 1;
        end
    end
    
    always_comb begin
        case (S)
            3'b000: begin
                if (transfer_mode && send) begin
                    data_mode = 8'b0000_0000;
                    load_mode = 0;
                    send_mode = 0;
                    
                    counter_en = 0;
                    counter_clr = 1;
                    
                    counter_send_en = 0;
                    counter_send_clr = 1;
                    N = 3'b001;
                end
                else begin                    
                    data_mode = data;
                    load_mode = load;
                    send_mode = send;
                    N = 3'b000;
                end
            end
            
            3'b001: begin
                counter_clr = 0;
                counter_send_clr = 0;
                counter_send_en = 0;
                
                if (counter < 4'b1101) begin // wait for 13 cycles to make sure data is send
                    counter_en = 1;                    
                    send_mode = 1;
                    load_mode = 0;
                    N = 3'b001;   
                end
                else begin                    
                    counter_en = 0;
                    send_mode = 0;
                    load_mode = 0;
                    N = 3'b010;
                end           
            end
            
            3'b010: begin
                counter_clr = 1;
                counter_send_en = 1;
                send_mode = 0;
                load_mode = 1; // discard the send byte and move to the other one
                
                if (counter_send < 2'b11) begin // wait for all 4 bytes to be send
                    N = 3'b001;
                end
                else begin
                    counter_send_en = 0;
                    N = 3'b011;
                end          
            end
            
            3'b011: begin
                if (send) begin
                    N = 3'b011;
                end
                else begin
                    N = 3'b000;
                end 
            end
        endcase
    end
endmodule