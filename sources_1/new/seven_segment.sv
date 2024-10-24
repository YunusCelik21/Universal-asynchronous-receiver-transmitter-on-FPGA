`timescale 1ns / 1ps
module seven_segment(input logic clk,
                     input logic left,
                     input logic right, 
                     input logic switch_memory, 
                     input logic[7:0] TXBUF[3:0], 
                     input logic[7:0] RXBUF[3:0],
                     output logic[0:6] seg,
                     output logic[3:0] an);
                     
    reg[1:0] digit_selecter = 2'b00;
    reg memory = 1'b0; // 0 == TX, 1 == RX
    reg[1:0] page = 2'b00; // pages from 0 to 3
    reg[7:0] current_byte;
    
    reg[1:0] N_left = 2'b00; reg[1:0] S_left;
    reg[1:0] N_right = 2'b00; reg[1:0] S_right;
    reg[1:0] N_switch = 2'b00; reg[1:0] S_switch;
    
    always_ff @(posedge clk) begin
        if (digit_selecter == 2'b11)
            digit_selecter <= 2'b00;
        else
            digit_selecter <= digit_selecter + 1;
            
    end
    
    always @(digit_selecter) begin
        case (digit_selecter)
            2'b00: an = 4'b1110;
            2'b01: an = 4'b1101;
            2'b10: an = 4'b1011;
            2'b11: an = 4'b0111;
        endcase
    end
    
    always @(memory) begin
        case (memory)
            1'b0: current_byte = TXBUF[page];
            1'b1: current_byte = RXBUF[page]; 
        endcase
    end
    
    always @(posedge clk) begin
        if (S_left == 2'b01) begin
            if (page == 2'b00) begin
                page <= 2'b11;
            end
            else begin
                page <= page - 1;
            end
        end
        if (S_right == 2'b01) begin
            if (page == 2'b11) begin
                page <= 2'b00;
            end
            else begin
                page <= page + 1;
            end
        end
        if (S_switch == 2'b01) begin
            memory <= ~memory;
        end
        
        S_left <= N_left;
        S_right <= N_right;
        S_switch <= N_switch;
    end
    
    always @(S_switch) begin
        case (S_switch)
            2'b00: begin
                if (switch_memory) begin
                    N_switch = 2'b01;
                end
                else begin
                    N_switch = 2'b00;
                end
            end
            2'b01: begin
                N_switch = 2'b10;
            end
            2'b10: begin
                if (switch_memory) begin
                    N_switch = 2'b10;
                end
                else begin
                    N_switch = 2'b00;
                end
            end
        endcase
    end
    
    always @(S_left) begin
        case (S_left)
            2'b00: begin
                if (left) begin
                    N_left = 2'b01;
                end
                else begin
                    N_left = 2'b00;
                end
            end
            2'b01: begin
                N_left = 2'b10;
            end
            2'b10: begin
                if (left) begin
                    N_left = 2'b10;
                end
                else begin
                    N_left = 2'b00;
                end
            end
        endcase
    end
    
    always @(S_right) begin
        case (S_right)
            2'b00: begin
                if (right) begin
                    N_right = 2'b01;
                end
                else begin
                    N_right = 2'b00;
                end
            end
            2'b01: begin
                N_right = 2'b10;
            end
            2'b10: begin
                if (right) begin
                    N_right = 2'b10;
                end
                else begin
                    N_right = 2'b00;
                end
            end
        endcase
    end
    
    always @(digit_selecter) begin
        case (digit_selecter)
            2'b00: begin
                case (current_byte[3:0])
                    4'b0000: seg = 7'b000_0001;
                    4'b0001: seg = 7'b100_1111;
                    4'b0010: seg = 7'b001_0010;
                    4'b0011: seg = 7'b000_0110;
                    4'b0100: seg = 7'b100_1100; 
                    4'b0101: seg = 7'b010_0100;
                    4'b0110: seg = 7'b010_0000;
                    4'b0111: seg = 7'b000_1111;
                    4'b1000: seg = 7'b000_0000;
                    4'b1001: seg = 7'b000_0100; 
                    4'b1010: seg = 7'b000_1000; // A
                    4'b1011: seg = 7'b110_0000; // b
                    4'b1100: seg = 7'b011_0001; // C
                    4'b1101: seg = 7'b100_0010; // d
                    4'b1110: seg = 7'b011_0000; // E
                    4'b1111: seg = 7'b011_1000; // F                  
                endcase
            end
            2'b01: begin
                case (current_byte[7:4])
                    4'b0000: seg = 7'b000_0001;
                    4'b0001: seg = 7'b100_1111;
                    4'b0010: seg = 7'b001_0010;
                    4'b0011: seg = 7'b000_0110;
                    4'b0100: seg = 7'b100_1100; 
                    4'b0101: seg = 7'b010_0100;
                    4'b0110: seg = 7'b010_0000;
                    4'b0111: seg = 7'b000_1111;
                    4'b1000: seg = 7'b000_0000;
                    4'b1001: seg = 7'b000_0100; 
                    4'b1010: seg = 7'b000_1000; // A
                    4'b1011: seg = 7'b110_0000; // b
                    4'b1100: seg = 7'b011_0001; // C
                    4'b1101: seg = 7'b100_0010; // d
                    4'b1110: seg = 7'b011_0000; // E
                    4'b1111: seg = 7'b011_1000; // F                  
                endcase        
            end
            2'b10: begin
                case (page)
                    4'b00: seg = 7'b000_0001;
                    4'b01: seg = 7'b100_1111;
                    4'b10: seg = 7'b001_0010;
                    4'b11: seg = 7'b000_0110;
                endcase
            end
            2'b11: begin
                if (memory == 0) begin
                    seg = 7'b111_0000; // t
                end
                else begin
                    seg = 7'b111_1010; // r
                end
            end
        endcase
    end
endmodule
