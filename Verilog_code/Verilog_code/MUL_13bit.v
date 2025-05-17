`timescale 1ns / 1ps
`include "header.vh"
module MUL_13bit(
    input signed [`FIXED_POINT_WIDTH-1:0] a_real,  
    input signed [`FIXED_POINT_WIDTH-1:0] a_imag,  
    input signed [`FIXED_POINT_WIDTH-1:0] b_real,  
    input signed [`FIXED_POINT_WIDTH-1:0] b_imag,  
    output signed [`FIXED_POINT_WIDTH-1:0] result_real,  
    output signed [`FIXED_POINT_WIDTH-1:0] result_imag    
    );
    wire signed [`FIXED_POINT_WIDTH*2-1:0] arxbr, aixbi, arxbi, aixbr;
    wire signed [`FIXED_POINT_WIDTH*2:0] temp_real, temp_imag;
    wire signed [`FIXED_POINT_WIDTH*2:0] neg_temp_real, neg_temp_imag;
    assign arxbr = a_real * b_real;
    assign aixbi = a_imag * b_imag;
    assign arxbi = a_real * b_imag;
    assign aixbr = a_imag * b_real;
    assign temp_real = arxbr - aixbi;
    assign temp_imag = arxbi + aixbr;
    assign neg_temp_real = -temp_real;
    assign neg_temp_imag = -temp_imag;
    assign result_real = (temp_real[`FIXED_POINT_WIDTH*2] == 1)?~(neg_temp_real[`FRACTION_BITS+`FIXED_POINT_WIDTH-1:`FRACTION_BITS]-1):temp_real[`FRACTION_BITS+`FIXED_POINT_WIDTH-1:`FRACTION_BITS]; //truncate
    assign result_imag = (temp_imag[`FIXED_POINT_WIDTH*2] == 1)?~(neg_temp_imag[`FRACTION_BITS+`FIXED_POINT_WIDTH-1:`FRACTION_BITS]-1):temp_imag[`FRACTION_BITS+`FIXED_POINT_WIDTH-1:`FRACTION_BITS]; //truncate
endmodule