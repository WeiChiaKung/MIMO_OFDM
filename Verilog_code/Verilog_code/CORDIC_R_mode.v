`timescale 1ns / 1ps
module CORDIC_R_mode(
    input signed [12:0] x,
    input signed [12:0] y,
    input signed [16:0] input_degree,
    output reg signed [12:0] output_x,
    output reg signed [12:0] output_y
);

    // Define the lookup table for atan values in 18-bit fixed-point format
    wire signed [16:0] degree_par [0:9];
    assign degree_par[0] = 17'b00101101000000000; // atan(2^0) * 180 / PI
    assign degree_par[1] = 17'b00011010100100001; // atan(2^-1) * 180 / PI
    assign degree_par[2] = 17'b00001110000010010; // atan(2^-2) * 180 / PI
    assign degree_par[3] = 17'b00000111001000000; // atan(2^-3) * 180 / PI
    assign degree_par[4] = 17'b00000011100100111; // atan(2^-4) * 180 / PI
    assign degree_par[5] = 17'b00000001110010100; // atan(2^-5) * 180 / PI
    assign degree_par[6] = 17'b00000000111001010; // atan(2^-6) * 180 / PI
    assign degree_par[7] = 17'b00000000011100101; // atan(2^-7) * 180 / PI
    assign degree_par[8] = 17'b00000000001110010; // atan(2^-8) * 180 / PI
    assign degree_par[9] = 17'b00000000000111001; // atan(2^-9) * 180 / PI
    wire signed [12:0] gain_par [0:9];
    assign gain_par[0] = 13'b0000101101010;
    assign gain_par[1] = 13'b0000101000011;
    assign gain_par[2] = 13'b0000100111010;
    assign gain_par[3] = 13'b0000100110111;
    assign gain_par[4] = 13'b0000100110111;
    assign gain_par[5] = 13'b0000100110110; 
    assign gain_par[6] = 13'b0000100110110; 
    assign gain_par[7] = 13'b0000100110110; 
    assign gain_par[8] = 13'b0000100110110;
    assign gain_par[9] = 13'b0000100110110;

    // Internal variables for intermediate results
    reg signed [12:0] X [0:10];
    reg signed [12:0] Y [0:10];
    reg signed [16:0] degree [0:10];
    reg [3:0]count [0:10];
    reg signed[12:0]gain;
    reg signed[25:0]X_mult,Y_mult;
    reg signed[25:0]neg_X_mult,neg_Y_mult;
    integer i;

    always @(*) begin
        if(input_degree == 0) begin
            for (i = 0; i < 11; i = i + 1) begin
                X[i] = x;
                Y[i] = y;
                degree[i] = 0;
                count[i] = 0;
            end
            output_x = x;
            output_y = y;
        end
        else begin
            degree[0] = input_degree;
            X[0] = x;
            Y[0] = y;
            count[0] = 0;
            for (i = 0; i < 10; i = i + 1) begin
               if (degree[i] < 0) begin
                    degree[i+1] = degree[i] + degree_par[i];
                    X[i+1] = X[i] + (Y[i] >>> i);
                    Y[i+1] = Y[i] - (X[i] >>> i);
                    count[i+1] = count[i] + 1;
                end 
                else if(degree[i] > 0) begin
                    degree[i+1] = degree[i] - degree_par[i];
                    X[i+1] = X[i] - (Y[i] >>> i);
                    Y[i+1] = Y[i] + (X[i] >>> i);
                    count[i+1] = count[i] + 1;
                end
                else begin
                    degree[i+1] = degree[i] ;
                    X[i+1] = X[i];
                    Y[i+1] = Y[i];
                    count[i+1] = count[i];
                end
            end
            case(count[10]) 
                0: begin gain = gain_par[0]; end
                1: begin gain = gain_par[1]; end
                2: begin gain = gain_par[2]; end
                3: begin gain = gain_par[3]; end
                4: begin gain = gain_par[4]; end
                5: begin gain = gain_par[5]; end
                6: begin gain = gain_par[6]; end
                7: begin gain = gain_par[7]; end
                8: begin gain = gain_par[8]; end
                9: begin gain = gain_par[9]; end
            endcase
            X_mult = X[10] * gain;
            neg_X_mult = -X_mult;
            Y_mult = Y[10] * gain;
            neg_Y_mult = -Y_mult;
            output_x = (X_mult[25] == 1)?~(neg_X_mult[21:9]-1):X_mult[21:9];
            output_y = (Y_mult[25] == 1)?~(neg_Y_mult[21:9]-1):Y_mult[21:9]; 
        end
    end

endmodule
