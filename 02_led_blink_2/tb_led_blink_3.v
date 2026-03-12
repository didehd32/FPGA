`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/12 13:47:22
// Design Name: 
// Module Name: tb_led_blink_3
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


module tb_led_blink_3(); // Testbench modules do not have port lists

    // Internal signal declarations
    reg sys_clk_tb; 
    reg rst_n;
    
    // Wire declarations for differential clock generation
    wire sys_clk_p;
    wire sys_clk_n;
    
    // Wire declaration to monitor output
    wire [3:0] led;

    // Differential clock assignment (p is normal, n is inverted)
    assign sys_clk_p = sys_clk_tb;
    assign sys_clk_n = ~sys_clk_tb;

    // Instantiate the main module
    led_blink_3 uut(
        .sys_clk_p(sys_clk_p),
        .sys_clk_n(sys_clk_n),
        .rst_n(rst_n),
        .led(led)
    );

    // Initialization block
    initial begin
        sys_clk_tb = 0;
        rst_n = 0;
        #1000;
        rst_n = 1;      // Release reset after 1000ns
    end

    // Generate 200MHz clock (5ns period -> 2.5ns half-period)
    always #2.5 sys_clk_tb = ~sys_clk_tb;

endmodule
