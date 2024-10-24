`timescale 1ns / 1ps

module clk_gen(input logic clk,
               output logic clk_Hz);
            
    reg[8:0] count = 0;   
    reg clk_Hz_reg = 0;
    always @(posedge clk) begin
        if (count == 433) begin
            count <= 0;
            clk_Hz_reg <= ~clk_Hz_reg;
        end
        else 
            count <= count + 1;
    end
    
    assign clk_Hz = clk_Hz_reg;
endmodule
