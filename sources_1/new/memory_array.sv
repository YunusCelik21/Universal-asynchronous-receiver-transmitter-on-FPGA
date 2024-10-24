`timescale 1ns / 1ps

module memory_array(input logic shift,
                    input logic clr,
                    input logic[7:0] dataIn,
                    output logic[7:0] data[3:0]);
                    
    always @(posedge shift, posedge clr) begin
        if (clr) begin
            data[0] <= 4'b0000;
            data[1] <= 4'b0000;
            data[2] <= 4'b0000;
            data[3] <= 4'b0000;
        end
        else begin
            data[0] <= dataIn;
            data[1] <= data[0];
            data[2] <= data[1];
            data[3] <= data[2];
        end      
    end
endmodule
