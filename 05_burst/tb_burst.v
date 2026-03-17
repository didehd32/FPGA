`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/17 15:57:00
// Design Name: 
// Module Name: tb_burst
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


module tb_burst();
    // Internal signal declarations
    reg clk_tb;
    reg rst_n;
   
    // Wire declarations for differential clock generation
    wire [1:0] buz_o;
    
    // Differential clock assignment (p is normal, n is inverted)
    assign clk_p = clk_tb;
    assign clk_n = ~clk_tb;

    // Instantiate the main module
    burst uut(
        .clk_p(clk_p),
        .clk_n(clk_n),
        .rst_n(rst_n),
        .buz_o(buz_o)
    );
    
    always #2.5 clk_tb = ~clk_tb;   // 5ns = 200MHz
    initial begin
        clk_tb = 1'd0;
        rst_n = 1'd0;
        #1_000_000;    // 1ms

        // Simulation start
        rst_n = 1;

        #2_000_000_000;
        
        $finish;
        // Simulation end
    end
endmodule