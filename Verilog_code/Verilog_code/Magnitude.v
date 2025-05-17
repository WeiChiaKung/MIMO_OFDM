`timescale 1ns / 1ps
`include "header.vh"
module Magnitude(
    input signed [`FIXED_POINT_WIDTH-1:0] a_real,  
    input signed [`FIXED_POINT_WIDTH-1:0] a_imag,    
    output signed [`FIXED_POINT_WIDTH-1:0] result    
    );
    wire signed [`FIXED_POINT_WIDTH*2-1:0] arxar, aixai;
    wire signed [`FIXED_POINT_WIDTH*2:0] temp;
    assign arxar = a_real * a_real;
    assign aixai = a_imag * a_imag;
    assign temp = arxar + aixai;
    assign result = temp[`FRACTION_BITS+`FIXED_POINT_WIDTH-1:`FRACTION_BITS]; //truncate
endmodule
