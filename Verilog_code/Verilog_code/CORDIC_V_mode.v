`timescale 1ns / 1ps
module CORDIC_V_mode(
    input signed [12:0] x,
    input signed [12:0] y,
    input signed [16:0] input_degree,
    output signed [16:0] output_degree
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

    // Internal variables for intermediate results
    reg signed [12:0] X [0:10];
    reg signed [12:0] Y [0:10];
    reg signed [16:0] degree [0:10];

    integer i;

    always @(*) begin
        if(y == 0) begin
            for (i = 0; i < 11; i = i + 1) begin
                X[i] = x;
                Y[i] = y;
                degree[i] = 0;
            end
        end
        else begin
            degree[0] = input_degree;
            X[0] = x;
            Y[0] = y;
            for (i = 0; i < 10; i = i + 1) begin
               if (Y[i] < 0) begin
                    degree[i+1] = degree[i] - degree_par[i];
                    X[i+1] = X[i] - (Y[i] >>> i);
                    Y[i+1] = Y[i] + (X[i] >>> i);
                end 
                else if(Y[i] > 0) begin
                    degree[i+1] = degree[i] + degree_par[i];
                    X[i+1] = X[i] + (Y[i] >>> i);
                    Y[i+1] = Y[i] - (X[i] >>> i);
                end
                else begin
                    degree[i+1] = degree[i] ;
                    X[i+1] = X[i];
                    Y[i+1] = Y[i];
                end
            end
        end
    end

    // Assign final outputs
    assign output_degree = degree[10];

endmodule