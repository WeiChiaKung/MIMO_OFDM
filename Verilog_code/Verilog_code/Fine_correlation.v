`timescale 1ns / 1ps
`include "header.vh"
module Fine_correlation(
    input clk,
    input rst,
    input input_valid,
    input preamble_valid,
    input [`FIXED_POINT_WIDTH-1:0]signal_real,
    input [`FIXED_POINT_WIDTH-1:0]signal_imag,
    output [`FIXED_POINT_WIDTH-1:0]tao,
    output reg [7:0]fine_num,
    output reg fine_done
);
////////////////////ring register////////////////////////////////
    localparam state_input = 1'b0;
    localparam state_compute = 1'b1;
    reg [5:0] cnt;
    reg signed[`FIXED_POINT_WIDTH-1:0] register_real [0:63];
    reg signed[`FIXED_POINT_WIDTH-1:0] register_imag [0:63];
    reg state;
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                register_real[i] <= 13'b0;
                register_imag[i] <= 13'b0;
            end
            state <= state_input;
            cnt <= 0;
        end 
        else begin
            if(preamble_valid && state == state_input && cnt!=63) begin
                register_real[cnt] <= signal_real; 
                register_imag[cnt] <= -signal_imag; 
                cnt <= cnt + 1;
            end
            else if(cnt==63 && state == state_input) begin
                state <= state_compute;
            end
        end
    end
////////////////////////////////////////////////////////////////////////
    wire [`FIXED_POINT_WIDTH-1:0]input_real,input_imag;
    wire signed [`FIXED_POINT_WIDTH-1:0]mul_result_real [0:63];
    wire signed [`FIXED_POINT_WIDTH-1:0]mul_result_imag [0:63];
    wire signed [`FIXED_POINT_WIDTH-1:0]add_result_real [0:63];
    wire signed [`FIXED_POINT_WIDTH-1:0]add_result_imag [0:63];
    reg signed [`FIXED_POINT_WIDTH-1:0]stage_real [0:63];
    reg signed [`FIXED_POINT_WIDTH-1:0]stage_imag [0:63];
    assign input_real = (input_valid && state == state_compute) ? signal_real : 0;
    assign input_imag = (input_valid && state == state_compute) ? signal_imag : 0;
    genvar j;
    generate
        for (j = 0; j < 64; j = j + 1) begin : pipeline_stages
            // Multiplication
            MUL_13bit mul_inst (
                .a_real(input_real),  
                .a_imag(input_imag),  
                .b_real(register_real[j]),  
                .b_imag(register_imag[j]),  
                .result_real(mul_result_real[j]),  
                .result_imag(mul_result_imag[j])
            );
            // Addition
            if (j == 0) begin
                // First stage
                assign add_result_real[j] = mul_result_real[j];
                assign add_result_imag[j] = mul_result_imag[j];
            end 
            else begin
                // Subsequent stages
                ADD_13bit add_inst (
                    .a_real(mul_result_real[j]),  
                    .a_imag(mul_result_imag[j]),  
                    .b_real(stage_real[j-1]),  
                    .b_imag(stage_imag[j-1]),  
                    .result_real(add_result_real[j]),  
                    .result_imag(add_result_imag[j])
                );
            end
        end
    endgenerate
    // Stage registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                stage_real[i] <= 0;
                stage_imag[i] <= 0;
            end
        end
        else if(input_valid) begin
            for (i = 0; i < 64; i = i + 1) begin
                stage_real[i] <= add_result_real[i];
                stage_imag[i] <= add_result_imag[i];
            end
        end
    end
    reg [7:0]count;
    reg [`FIXED_POINT_WIDTH-1:0]max_tao;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            fine_num <= 0;
            max_tao <= 0;
            fine_done <= 0;
        end
        else if(input_valid) begin
            count <= count + 1;
            fine_done <= 0;
            if(count >= 64 && count < 128) begin
                if(tao > max_tao) begin
                    max_tao <= tao;
                    fine_num <= count - 64;
                end
            end
            else if(count == 128) begin
                fine_done <= 1;
            end
        end
        else begin
            count <= 0;
            fine_num <= 0;
            max_tao <= 0;
            fine_done <= 0;
        end
    end
    Magnitude mag1(
        .a_real(stage_real[63]),  
        .a_imag(stage_imag[63]),    
        .result(tao)
    );
    
    
endmodule
