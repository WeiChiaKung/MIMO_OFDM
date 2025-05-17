`timescale 1ns / 1ps
module SR#(
    parameter integer DEPTH = 64,        
    parameter integer DATA_WIDTH = 13   
)(
    input clk,                      
    input rst,                      
    input [DATA_WIDTH-1:0]din,
    input valid,     
    output reg [DATA_WIDTH-1:0]dout  
);
    reg [DATA_WIDTH-1:0] shift_reg [0:DEPTH-1];
    integer i;
    always @(posedge clk or posedge rst) begin
        // initialize
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                shift_reg[i] <= 0;  
            end
            dout <= shift_reg[DEPTH-1];
        end 
        //shift
        else begin
            if(valid) begin
                shift_reg[0] <= din;  
                for (i = 1; i < DEPTH; i = i + 1) begin
                    shift_reg[i] <= shift_reg[i-1];  
                end
            end
            dout <= shift_reg[DEPTH-1];
        end
    end
endmodule
