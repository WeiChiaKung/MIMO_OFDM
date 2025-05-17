`timescale 1ns / 1ps
module BRAM_36(
    input clk, 
    input write_en,                 
    input [5:0] write_addr,          
    input [12:0] write_data,        
    input read_en,                   
    input [5:0] read_addr,           
    output reg [12:0] read_data      
);

    
    reg [12:0] memory [0:35];

    always @(posedge clk) begin
        if (write_en) begin
            memory[write_addr] <= write_data; 
        end
    end

    always @(posedge clk) begin
        if (read_en) begin
            read_data <= memory[read_addr]; 
        end else begin
            read_data <= 0; 
        end
    end

endmodule
