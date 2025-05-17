`timescale 1ns / 1ps
`include "header.vh"
module Coarse_correlation(
    input clk,
    input rst,
    input valid,
    input [`FIXED_POINT_WIDTH-1:0]signal_real,
    input [`FIXED_POINT_WIDTH-1:0]signal_imag,
    output reg[`FIXED_POINT_WIDTH-1:0]tao,
    output reg [4:0]coarse_num,
    output reg coarse_done
);
    reg [5:0] count;
    //reg phid_pd_done;
    wire signed [`FIXED_POINT_WIDTH-1:0]delay_input_real, delay_input_imag,delay_input1_real, delay_input1_imag, conjugate_input_real, conjugate_input_imag;
    wire [`FIXED_POINT_WIDTH-1:0]mult_result_real,mult_result_imag;
    //wire [1:0]m_count = count/80;
    wire [`FIXED_POINT_WIDTH-1:0]accumulate0_real,accumulate0_imag;
    //reg [`FIXED_POINT_WIDTH-1:0]accumulate1_real,accumulate1_imag;
    wire [`FIXED_POINT_WIDTH-1:0]accumulate_result0_real,accumulate_result0_imag;
    wire [`FIXED_POINT_WIDTH-1:0]accumulate_result1_real,accumulate_result1_imag;
    //wire [`FIXED_POINT_WIDTH-1:0]accumulate_result2_real,accumulate_result2_imag;
    reg [`FIXED_POINT_WIDTH-1:0]tmp0_real,tmp0_imag;
    wire [`FIXED_POINT_WIDTH-1:0]magnitude;
    reg first;
    //reg [`FIXED_POINT_WIDTH-1:0] point_real [79:0];
    //reg [`FIXED_POINT_WIDTH-1:0] point_imag [79:0];
    assign accumulate0_real = (count>=17) ? mult_result_real : 0;
    assign accumulate0_imag = (count>=17) ? mult_result_imag : 0;
    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count <= 0;
            tmp0_real <= 0;
            tmp0_imag <= 0;
            tao <= 0;
            coarse_done <= 0;
            coarse_num <= 0;
            first <= 0;
        end
        else begin
            tao <= magnitude;
            count <= count;
            tmp0_real <= accumulate_result1_real;
            tmp0_imag <= accumulate_result1_imag;
            coarse_done <= 0;
            coarse_num <= coarse_num;
            first <= first;
            if(valid) begin
                count <= count + 1;
                if(count >= 33 && magnitude >= 13'b0001010011001 && ~first)begin
                    coarse_done <= 1;
                    coarse_num <= count - 33;
                    first <= 1;
                end
            end
        end
    end
    /******Phi_d*********/
    SR#(.DEPTH(16)) sr_16_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(signal_real),
        .valid(valid),     
        .dout(delay_input_real)    
    );
    SR#(.DEPTH(16)) sr_16_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(signal_imag),
        .valid(valid),     
        .dout(delay_input_imag)    
    );
    Conjugate conjugate(
        .clk(clk),
        .real_in(signal_real),
        .imag_in(signal_imag),
        .valid(valid),
        .real_out(conjugate_input_real), 
        .imag_out(conjugate_input_imag) 
    );
    MUL_13bit mul(
        .a_real(delay_input_real),  
        .a_imag(delay_input_imag),  
        .b_real(conjugate_input_real),  
        .b_imag(conjugate_input_imag),  
        .result_real(mult_result_real),  
        .result_imag(mult_result_imag)
    );
    ADD_13bit accumulator0(
        .a_real(tmp0_real),  
        .a_imag(tmp0_imag),  
        .b_real(accumulate0_real),  
        .b_imag(accumulate0_imag),  
        .result_real(accumulate_result0_real),  
        .result_imag(accumulate_result0_imag)
    );
    SR#(.DEPTH(15)) sr_15_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(mult_result_real),
        .valid(valid),     
        .dout(delay_input1_real)    
    );
    SR#(.DEPTH(15)) sr_15_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(mult_result_imag),
        .valid(valid),     
        .dout(delay_input1_imag)    
    );
    ADD_13bit accumulator1(
        .a_real(accumulate_result0_real),  
        .a_imag(accumulate_result0_imag),  
        .b_real((-delay_input1_real)),  
        .b_imag((-delay_input1_imag)),  
        .result_real(accumulate_result1_real),  
        .result_imag(accumulate_result1_imag)
    );
    Magnitude mag1(
        .a_real(tmp0_real),  
        .a_imag(tmp0_imag),    
        .result(magnitude)
    );
endmodule
