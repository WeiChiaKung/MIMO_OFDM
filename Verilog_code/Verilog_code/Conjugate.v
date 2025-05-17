`timescale 1ns / 1ps
`include "header.vh"
module Conjugate(
    input clk,
    input signed [`FIXED_POINT_WIDTH-1:0] real_in,
    input signed [`FIXED_POINT_WIDTH-1:0] imag_in,
    input valid,
    output reg signed [`FIXED_POINT_WIDTH-1:0] real_out, 
    output reg signed [`FIXED_POINT_WIDTH-1:0] imag_out 
    );
    always @(posedge clk) begin
        if(valid) begin
            real_out <= real_in;
            imag_out <= -imag_in;
        end
        else begin
            real_out <= 0;
            imag_out <= 0;
        end
    end
endmodule
