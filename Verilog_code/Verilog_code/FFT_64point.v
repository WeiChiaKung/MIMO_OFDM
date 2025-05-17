`timescale 1ns / 1ps
module FFT_64point(
    input clk,
    input [12:0] weight_real_0, input [12:0] weight_imag_0,
    input [12:0] weight_real_1, input [12:0] weight_imag_1,
    input [12:0] weight_real_2, input [12:0] weight_imag_2,
    input [12:0] weight_real_3, input [12:0] weight_imag_3,
    input [12:0] weight_real_4, input [12:0] weight_imag_4,
    input [12:0] weight_real_5, input [12:0] weight_imag_5,
    input [12:0] input_real,
    input [12:0] input_imag,
    input in_valid,
    input rst,
    output reg weight_en_0, output reg [4:0] weight_addr_0,
    output reg weight_en_1, output reg [4:0] weight_addr_1,
    output reg weight_en_2, output reg [4:0] weight_addr_2,
    output reg weight_en_3, output reg [4:0] weight_addr_3,
    output reg weight_en_4, output reg [4:0] weight_addr_4,
    output reg weight_en_5, output reg [4:0] weight_addr_5,
    output [12:0] output_real,
    output [12:0] output_imag,
    output out_valid
);
    integer i;
    /*******stage0******/
    wire signed[12:0]stage0_pair_real,stage0_pair_imag;
    wire signed[12:0]stage0_input0_real,stage0_input0_imag;
    wire signed[12:0]stage0_mult_real,stage0_mult_imag;
    wire signed[12:0]stage0_add_real,stage0_add_imag;
    wire signed[12:0]stage0_sub_real,stage0_sub_imag;
    wire signed[12:0]stage0_buffer_real,stage0_buffer_imag;
    reg signed[12:0]stage0_out_real,stage0_out_imag;
    reg signed[12:0]buffer0_real,buffer0_imag;
    reg stage0_first;
    reg stage0_out_valid;
    reg [5:0]cnt0;
    reg [5:0]temp0;
    assign stage0_buffer_real = (cnt0 > 31)?stage0_sub_real:input_real;
    assign stage0_buffer_imag = (cnt0 > 31)?stage0_sub_imag:input_imag;
    always @(*) begin
        if(in_valid && cnt0>=31) begin
            temp0 = (cnt0 -31) >> 5;
            weight_en_0 = 1;
            weight_addr_0[5] = temp0[0];
            weight_addr_0[4] = temp0[1];
            weight_addr_0[3] = temp0[2];
            weight_addr_0[2] = temp0[3];
            weight_addr_0[1] = temp0[4];
            weight_addr_0[0] = temp0[5];
        end
        else begin
            temp0 = 0;
            weight_en_0 = 0;
            weight_addr_0 = 0;
        end
    end
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            cnt0 <= 0;
            stage0_out_valid <= 0;
            stage0_out_real <= 0;
            stage0_out_imag <= 0;
            stage0_first <= 0;
            buffer0_real <= 0;
            buffer0_imag <= 0;
        end
        else if(in_valid) begin
            cnt0 <= cnt0 + 1;
            if(stage0_first == 0 && cnt0 < 32) begin
                stage0_out_real <= 0;
                stage0_out_imag <= 0;
                stage0_out_valid <= 0;
            end
            else if(stage0_first == 1 && cnt0 < 32) begin
                stage0_out_real <= stage0_input0_real;
                stage0_out_imag <= stage0_input0_imag;
                stage0_out_valid <= 1;
            end
            else if(stage0_first == 0 && cnt0 < 64) begin
                stage0_out_real <= stage0_add_real;
                stage0_out_imag <= stage0_add_imag;
                stage0_out_valid <= 1;
                stage0_first <= 1;
            end
            else if(stage0_first == 1 && cnt0 < 64) begin
                stage0_out_real <= stage0_add_real;
                stage0_out_imag <= stage0_add_imag;
                stage0_out_valid <= 1;
                stage0_first <= 1;
            end
        end
        else begin
            stage0_out_valid <= 0;
        end
    end
    Shift_Register#(.DEPTH(31)) sr_32_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage0_buffer_real),
        .valid(in_valid),     
        .dout0(stage0_input0_real)
    );
    Shift_Register#(.DEPTH(31)) sr_32_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage0_buffer_imag),
        .valid(in_valid),     
        .dout0(stage0_input0_imag)   
    );
    MUL_13bit mul(
        .a_real(input_real),  
        .a_imag(input_imag),  
        .b_real(weight_real_0),  
        .b_imag(weight_imag_0),  
        .result_real(stage0_mult_real),  
        .result_imag(stage0_mult_imag)
    );
    ADD_13bit adder0(
        .a_real(stage0_input0_real),  
        .a_imag(stage0_input0_imag),  
        .b_real(stage0_mult_real),  
        .b_imag(stage0_mult_imag),  
        .result_real(stage0_add_real),  
        .result_imag(stage0_add_imag)
    );
    ADD_13bit sub0(
        .a_real(stage0_input0_real),  
        .a_imag(stage0_input0_imag),  
        .b_real((-stage0_mult_real)),  
        .b_imag((-stage0_mult_imag)),  
        .result_real(stage0_sub_real),  
        .result_imag(stage0_sub_imag)
    );
    /*******stage1******/
    wire signed[12:0]stage1_pair_real,stage1_pair_imag;
    wire signed[12:0]stage1_input0_real,stage1_input0_imag;
    wire signed[12:0]stage1_mult_real,stage1_mult_imag;
    wire signed[12:0]stage1_add_real,stage1_add_imag;
    wire signed[12:0]stage1_sub_real,stage1_sub_imag;
    wire signed[12:0]stage1_buffer_real,stage1_buffer_imag;
    reg signed[12:0]stage1_out_real,stage1_out_imag;
    reg signed[12:0]buffer1_real,buffer1_imag;
    reg stage1_first;
    reg stage1_out_valid;
    reg [4:0]stage1_count;
    reg [5:0]cnt1;
    reg [5:0]temp1;
    assign stage1_buffer_real = (stage1_count > 15)?stage1_sub_real:stage0_out_real;
    assign stage1_buffer_imag = (stage1_count > 15)?stage1_sub_imag:stage0_out_imag;
    always @(*) begin
        if(stage0_out_valid && stage1_count>=15) begin
            temp1 = (cnt1 -15) >> 4;
            weight_en_1 = 1;
            weight_addr_1[5] = temp1[0];
            weight_addr_1[4] = temp1[1];
            weight_addr_1[3] = temp1[2];
            weight_addr_1[2] = temp1[3];
            weight_addr_1[1] = temp1[4];
            weight_addr_1[0] = temp1[5];
        end
        else begin
            temp1 = 0;
            weight_en_1 = 0;
            weight_addr_1 = 0;
        end
    end
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            cnt1 <= 0;
            stage1_count <= 0;
            stage1_out_valid <= 0;
            stage1_out_real <= 0;
            stage1_out_imag <= 0;
            stage1_first <= 0;
            buffer1_real <= 0;
            buffer1_imag <= 0;
        end
        else if(stage0_out_valid) begin
            cnt1 <= cnt1 + 1;
            stage1_count <= stage1_count +1;
            if(stage1_first == 0 && stage1_count < 16) begin
                stage1_out_real <= 0;
                stage1_out_imag <= 0;
                stage1_out_valid <= 0;
            end
            else if(stage1_first == 1 && stage1_count < 16) begin
                stage1_out_real <= stage1_input0_real;
                stage1_out_imag <= stage1_input0_imag;
                stage1_out_valid <= 1;
            end
            else if(stage1_first == 0 && stage1_count < 32) begin
                stage1_out_real <= stage1_add_real;
                stage1_out_imag <= stage1_add_imag;
                stage1_out_valid <= 1;
                stage1_first <= 1;
            end
            else if(stage1_first == 1 && stage1_count < 32) begin
                stage1_out_real <= stage1_add_real;
                stage1_out_imag <= stage1_add_imag;
                stage1_out_valid <= 1;
                stage1_first <= 1;
            end
        end
        else begin
            stage1_out_valid <= 0;
        end
    end
    Shift_Register#(.DEPTH(15)) sr_16_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage1_buffer_real),
        .valid(stage0_out_valid),     
        .dout0(stage1_input0_real)
    );
    Shift_Register#(.DEPTH(15)) sr_16_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage1_buffer_imag),
        .valid(stage0_out_valid),     
        .dout0(stage1_input0_imag)   
    );
    MUL_13bit mul1(
        .a_real(stage0_out_real),  
        .a_imag(stage0_out_imag),  
        .b_real(weight_real_1),  
        .b_imag(weight_imag_1),  
        .result_real(stage1_mult_real),  
        .result_imag(stage1_mult_imag)
    );
    ADD_13bit adder1(
        .a_real(stage1_input0_real),  
        .a_imag(stage1_input0_imag),  
        .b_real(stage1_mult_real),  
        .b_imag(stage1_mult_imag),  
        .result_real(stage1_add_real),  
        .result_imag(stage1_add_imag)
    );
    ADD_13bit sub1(
        .a_real(stage1_input0_real),  
        .a_imag(stage1_input0_imag),  
        .b_real((-stage1_mult_real)),  
        .b_imag((-stage1_mult_imag)),  
        .result_real(stage1_sub_real),  
        .result_imag(stage1_sub_imag)
    );
    
    /*******stage2******/
    wire signed[12:0]stage2_pair_real,stage2_pair_imag;
    wire signed[12:0]stage2_input0_real,stage2_input0_imag;
    wire signed[12:0]stage2_mult_real,stage2_mult_imag;
    wire signed[12:0]stage2_add_real,stage2_add_imag;
    wire signed[12:0]stage2_sub_real,stage2_sub_imag;
    wire signed[12:0]stage2_buffer_real,stage2_buffer_imag;
    reg signed[12:0]stage2_out_real,stage2_out_imag;
    reg signed[12:0]buffer2_real,buffer2_imag;
    reg stage2_first;
    reg stage2_out_valid;
    reg [3:0]stage2_count;
    reg [5:0]cnt2;
    reg [5:0]temp2;
    assign stage2_buffer_real = (stage2_count > 7)?stage2_sub_real:stage1_out_real;
    assign stage2_buffer_imag = (stage2_count > 7)?stage2_sub_imag:stage1_out_imag;
    always @(*) begin
        if(stage1_out_valid && stage2_count>=7) begin
            temp2 = (cnt2 -7) >> 3;
            weight_en_2 = 1;
            weight_addr_2[5] = temp2[0];
            weight_addr_2[4] = temp2[1];
            weight_addr_2[3] = temp2[2];
            weight_addr_2[2] = temp2[3];
            weight_addr_2[1] = temp2[4];
            weight_addr_2[0] = temp2[5];
        end
        else begin
            temp2 = 0;
            weight_en_2 = 0;
            weight_addr_2 = 0;
        end
    end
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            cnt2 <= 0;
            stage2_count <= 0;
            stage2_out_valid <= 0;
            stage2_out_real <= 0;
            stage2_out_imag <= 0;
            stage2_first <= 0;
            buffer2_real <= 0;
            buffer2_imag <= 0;
        end
        else if(stage1_out_valid) begin
            cnt2 <= cnt2 + 1;
            stage2_count <= stage2_count +1;
            if(stage2_first == 0 && stage2_count < 8) begin
                stage2_out_real <= 0;
                stage2_out_imag <= 0;
                stage2_out_valid <= 0;
            end
            else if(stage2_first == 1 && stage2_count < 8) begin
                stage2_out_real <= stage2_input0_real;
                stage2_out_imag <= stage2_input0_imag;
                stage2_out_valid <= 1;
            end
            else if(stage2_first == 0 && stage2_count < 16) begin
                stage2_out_real <= stage2_add_real;
                stage2_out_imag <= stage2_add_imag;
                stage2_out_valid <= 1;
                stage2_first <= 1;
            end
            else if(stage2_first == 1 && stage2_count < 16) begin
                stage2_out_real <= stage2_add_real;
                stage2_out_imag <= stage2_add_imag;
                stage2_out_valid <= 1;
                stage2_first <= 1;
            end
        end
        else begin
            stage2_out_valid <= 0;
        end
    end
    Shift_Register#(.DEPTH(7)) sr_8_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage2_buffer_real),
        .valid(stage1_out_valid),     
        .dout0(stage2_input0_real)
    );
    Shift_Register#(.DEPTH(7)) sr_8_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage2_buffer_imag),
        .valid(stage1_out_valid),     
        .dout0(stage2_input0_imag)   
    );
    MUL_13bit mul2(
        .a_real(stage1_out_real),  
        .a_imag(stage1_out_imag),  
        .b_real(weight_real_2),  
        .b_imag(weight_imag_2),  
        .result_real(stage2_mult_real),  
        .result_imag(stage2_mult_imag)
    );
    ADD_13bit adder2(
        .a_real(stage2_input0_real),  
        .a_imag(stage2_input0_imag),  
        .b_real(stage2_mult_real),  
        .b_imag(stage2_mult_imag),  
        .result_real(stage2_add_real),  
        .result_imag(stage2_add_imag)
    );
    ADD_13bit sub2(
        .a_real(stage2_input0_real),  
        .a_imag(stage2_input0_imag),  
        .b_real((-stage2_mult_real)),  
        .b_imag((-stage2_mult_imag)),  
        .result_real(stage2_sub_real),  
        .result_imag(stage2_sub_imag)
    );
     /*******stage3******/
    wire signed[12:0]stage3_pair_real,stage3_pair_imag;
    wire signed[12:0]stage3_input0_real,stage3_input0_imag;
    wire signed[12:0]stage3_mult_real,stage3_mult_imag;
    wire signed[12:0]stage3_add_real,stage3_add_imag;
    wire signed[12:0]stage3_sub_real,stage3_sub_imag;
    wire signed[12:0]stage3_buffer_real,stage3_buffer_imag;
    reg signed[12:0]stage3_out_real,stage3_out_imag;
    reg signed[12:0]buffer3_real,buffer3_imag;
    reg stage3_first;
    reg stage3_out_valid;
    reg [2:0]stage3_count;
    reg [5:0]cnt3;
    reg [5:0]temp3;
    assign stage3_buffer_real = (stage3_count > 3)?stage3_sub_real:stage2_out_real;
    assign stage3_buffer_imag = (stage3_count > 3)?stage3_sub_imag:stage2_out_imag;
    always @(*) begin
        if(stage2_out_valid && stage3_count>=3) begin
            temp3 = (cnt3 -3) >> 2;
            weight_en_3 = 1;
            weight_addr_3[5] = temp3[0];
            weight_addr_3[4] = temp3[1];
            weight_addr_3[3] = temp3[2];
            weight_addr_3[2] = temp3[3];
            weight_addr_3[1] = temp3[4];
            weight_addr_3[0] = temp3[5];
        end
        else begin
            temp3 = 0;
            weight_en_3 = 0;
            weight_addr_3 = 0;
        end
    end
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            cnt3 <= 0;
            stage3_count <= 0;
            stage3_out_valid <= 0;
            stage3_out_real <= 0;
            stage3_out_imag <= 0;
            stage3_first <= 0;
            buffer3_real <= 0;
            buffer3_imag <= 0;
        end
        else if(stage2_out_valid) begin
            cnt3 <= cnt3 + 1;
            stage3_count <= stage3_count +1;
            if(stage3_first == 0 && stage3_count < 4) begin
                stage3_out_real <= 0;
                stage3_out_imag <= 0;
                stage3_out_valid <= 0;
            end
            else if(stage3_first == 1 && stage3_count < 4) begin
                stage3_out_real <= stage3_input0_real;
                stage3_out_imag <= stage3_input0_imag;
                stage3_out_valid <= 1;
            end
            else if(stage3_first == 0 && stage3_count < 8) begin
                stage3_out_real <= stage3_add_real;
                stage3_out_imag <= stage3_add_imag;
                stage3_out_valid <= 1;
                stage3_first <= 1;
            end
            else if(stage3_first == 1 && stage3_count < 8) begin
                stage3_out_real <= stage3_add_real;
                stage3_out_imag <= stage3_add_imag;
                stage3_out_valid <= 1;
                stage3_first <= 1;
            end
        end
        else begin
            stage3_out_valid <= 0;
        end
    end
    Shift_Register#(.DEPTH(3)) sr_4_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage3_buffer_real),
        .valid(stage2_out_valid),     
        .dout0(stage3_input0_real)
    );
    Shift_Register#(.DEPTH(3)) sr_4_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage3_buffer_imag),
        .valid(stage2_out_valid),     
        .dout0(stage3_input0_imag)   
    );
    MUL_13bit mul3(
        .a_real(stage2_out_real),  
        .a_imag(stage2_out_imag),  
        .b_real(weight_real_3),  
        .b_imag(weight_imag_3),  
        .result_real(stage3_mult_real),  
        .result_imag(stage3_mult_imag)
    );
    ADD_13bit adder3(
        .a_real(stage3_input0_real),  
        .a_imag(stage3_input0_imag),  
        .b_real(stage3_mult_real),  
        .b_imag(stage3_mult_imag),  
        .result_real(stage3_add_real),  
        .result_imag(stage3_add_imag)
    );
    ADD_13bit sub3(
        .a_real(stage3_input0_real),  
        .a_imag(stage3_input0_imag),  
        .b_real((-stage3_mult_real)),  
        .b_imag((-stage3_mult_imag)),  
        .result_real(stage3_sub_real),  
        .result_imag(stage3_sub_imag)
    );
     /*******stage4******/
    wire signed[12:0]stage4_pair_real,stage4_pair_imag;
    wire signed[12:0]stage4_input0_real,stage4_input0_imag;
    wire signed[12:0]stage4_mult_real,stage4_mult_imag;
    wire signed[12:0]stage4_add_real,stage4_add_imag;
    wire signed[12:0]stage4_sub_real,stage4_sub_imag;
    wire signed[12:0]stage4_buffer_real,stage4_buffer_imag;
    reg signed[12:0]stage4_out_real,stage4_out_imag;
    reg signed[12:0]buffer4_real,buffer4_imag;
    reg stage4_first;
    reg stage4_out_valid;
    reg [1:0]stage4_count;
    reg [5:0]cnt4;
    reg [5:0]temp4;
    assign stage4_buffer_real = (stage4_count > 1)?stage4_sub_real:stage3_out_real;
    assign stage4_buffer_imag = (stage4_count > 1)?stage4_sub_imag:stage3_out_imag;
    always @(*) begin
        if(stage3_out_valid && stage4_count>=1) begin
            temp4 = (cnt4 -1) >> 1;
            weight_en_4 = 1;
            weight_addr_4[5] = temp4[0];
            weight_addr_4[4] = temp4[1];
            weight_addr_4[3] = temp4[2];
            weight_addr_4[2] = temp4[3];
            weight_addr_4[1] = temp4[4];
            weight_addr_4[0] = temp4[5];
        end
        else begin
            temp4 = 0;
            weight_en_4 = 0;
            weight_addr_4 = 0;
        end
    end
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            cnt4 <= 0;
            stage4_count <= 0;
            stage4_out_valid <= 0;
            stage4_out_real <= 0;
            stage4_out_imag <= 0;
            stage4_first <= 0;
            buffer4_real <= 0;
            buffer4_imag <= 0;
        end
        else if(stage3_out_valid) begin
            cnt4 <= cnt4 + 1;
            stage4_count <= stage4_count +1;
            if(stage4_first == 0 && stage4_count < 2) begin
                stage4_out_real <= 0;
                stage4_out_imag <= 0;
                stage4_out_valid <= 0;
            end
            else if(stage4_first == 1 && stage4_count < 2) begin
                stage4_out_real <= stage4_input0_real;
                stage4_out_imag <= stage4_input0_imag;
                stage4_out_valid <= 1;
            end
            else if(stage4_first == 0 && stage4_count < 4) begin
                stage4_out_real <= stage4_add_real;
                stage4_out_imag <= stage4_add_imag;
                stage4_out_valid <= 1;
                stage4_first <= 1;
            end
            else if(stage4_first == 1 && stage4_count < 4) begin
                stage4_out_real <= stage4_add_real;
                stage4_out_imag <= stage4_add_imag;
                stage4_out_valid <= 1;
                stage4_first <= 1;
            end
        end
        else begin
            stage4_out_valid <= 0;
        end
    end
    Shift_Register#(.DEPTH(1)) sr_2_real(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage4_buffer_real),
        .valid(stage3_out_valid),     
        .dout0(stage4_input0_real)
    );
    Shift_Register#(.DEPTH(1)) sr_2_imag(
        .clk(clk),                      
        .rst(rst),                      
        .din(stage4_buffer_imag),
        .valid(stage3_out_valid),     
        .dout0(stage4_input0_imag)   
    );
    MUL_13bit mul4(
        .a_real(stage3_out_real),  
        .a_imag(stage3_out_imag),  
        .b_real(weight_real_4),  
        .b_imag(weight_imag_4),  
        .result_real(stage4_mult_real),  
        .result_imag(stage4_mult_imag)
    );
    ADD_13bit adder4(
        .a_real(stage4_input0_real),  
        .a_imag(stage4_input0_imag),  
        .b_real(stage4_mult_real),  
        .b_imag(stage4_mult_imag),  
        .result_real(stage4_add_real),  
        .result_imag(stage4_add_imag)
    );
    ADD_13bit sub4(
        .a_real(stage4_input0_real),  
        .a_imag(stage4_input0_imag),  
        .b_real((-stage4_mult_real)),  
        .b_imag((-stage4_mult_imag)),  
        .result_real(stage4_sub_real),  
        .result_imag(stage4_sub_imag)
    );
    
     /*******stage5******/
    reg signed[12:0]stage5_input0_real,stage5_input0_imag;
    wire signed[12:0]stage5_pair_real,stage5_pair_imag;
    wire signed[12:0]stage5_mult_real,stage5_mult_imag;
    wire signed[12:0]stage5_add_real,stage5_add_imag;
    wire signed[12:0]stage5_sub_real,stage5_sub_imag;
    reg signed[12:0]stage5_buffer_real,stage5_buffer_imag;
    reg signed[12:0]stage5_out_real,stage5_out_imag;
    reg signed[12:0]buffer5_real,buffer5_imag;
    reg stage5_first;
    reg stage5_out_valid;
    reg stage5_count;
    reg [5:0]cnt5;
    reg [5:0]temp5;
    always @(*) begin
        if(stage4_out_valid) begin
            temp5 = cnt5;
            weight_en_5 = 1;
            weight_addr_5[5] = temp5[0];
            weight_addr_5[4] = temp5[1];
            weight_addr_5[3] = temp5[2];
            weight_addr_5[2] = temp5[3];
            weight_addr_5[1] = temp5[4];
            weight_addr_5[0] = temp5[5];
        end
        else begin
            temp5 = 0;
            weight_en_5 = 0;
            weight_addr_5 = 0;
        end
    end
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            cnt5 <= 0;
            stage5_count <= 0;
            stage5_out_valid <= 0;
            stage5_out_real <= 0;
            stage5_out_imag <= 0;
            stage5_buffer_real <= 0;
            stage5_buffer_imag <= 0;
            stage5_input0_real <= 0;
            stage5_input0_imag <= 0;
            stage5_first <= 0;
        end
        else if(stage4_out_valid) begin
            stage5_input0_real <= stage4_out_real;
            stage5_input0_imag <= stage4_out_imag;
            stage5_buffer_real <= stage5_sub_real;
            stage5_buffer_imag <= stage5_sub_imag;
            cnt5 <= cnt5 + 1;
            stage5_count <= stage5_count +1;
            if(~stage5_first && ~stage5_count) begin
                stage5_out_real <= 0;
                stage5_out_imag <= 0;
                stage5_out_valid <= 0;
                stage5_first <= 1;
            end
            else if(stage5_first && stage5_count) begin
                stage5_out_real <= stage5_add_real;
                stage5_out_imag <= stage5_add_imag;
                stage5_out_valid <= 1;
            end
           else if(stage5_first && ~stage5_count) begin
                stage5_out_real <= stage5_buffer_real;
                stage5_out_imag <= stage5_buffer_imag;
                stage5_out_valid <= 1;
            end
        end
        else begin
            stage5_out_valid <= 0;
        end
    end
    MUL_13bit mul5(
        .a_real(stage4_out_real),  
        .a_imag(stage4_out_imag),  
        .b_real(weight_real_5),  
        .b_imag(weight_imag_5),  
        .result_real(stage5_mult_real),  
        .result_imag(stage5_mult_imag)
    );
    ADD_13bit adder5(
        .a_real(stage5_input0_real),  
        .a_imag(stage5_input0_imag),  
        .b_real(stage5_mult_real),  
        .b_imag(stage5_mult_imag),  
        .result_real(stage5_add_real),  
        .result_imag(stage5_add_imag)
    );
    ADD_13bit sub5(
        .a_real(stage5_input0_real),  
        .a_imag(stage5_input0_imag),  
        .b_real((-stage5_mult_real)),  
        .b_imag((-stage5_mult_imag)),  
        .result_real(stage5_sub_real),  
        .result_imag(stage5_sub_imag)
    );
    
    assign output_real = stage5_out_real;
    assign output_imag = stage5_out_imag;
    assign out_valid = stage5_out_valid;
endmodule
