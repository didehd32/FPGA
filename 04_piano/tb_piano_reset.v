`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/13 14:14:58
// Design Name: 
// Module Name: tb_piano_led
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_piano_reset();
    // Internal signal declarations
    reg clk_tb; 
    reg rst_n;
    reg [1:0] btn;
   
    // Wire declarations for differential clock generation
    wire clk_p;
    wire clk_n;
    wire [3:0] led;
    wire buz_o;
    
    // Differential clock assignment (p is normal, n is inverted)
    assign clk_p = clk_tb;
    assign clk_n = ~clk_tb;

    // Instantiate the main module
    tb_piano uut(
        .clk_p(clk_p),
        .clk_n(clk_n),
        .btn(btn),
        .rst_n(rst_n),
        .led(led),
        .buz_o(buz_o)
    );
    always #5 clk_tb = ~clk_tb;
    initial begin
        clk_tb = 1'd0;
        rst_n = 1'd0;
        btn = 2'd0;
        #5 rst_n = 0;   // 5ns
        #10 rst_n = 1;  // 10ns
        #100 $finish;   // Simulate during 100ns
    end
endmodule


