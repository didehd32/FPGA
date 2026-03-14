`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/14 12:43:00
// Design Name: 
// Module Name: tb_piano_btn
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


module tb_piano_btn();
    // Internal signal declarations
    reg clk_tb;
    reg rst_n;
    reg [1:0] btn;
   
    // Wire declarations for differential clock generation
    wire [3:0] led;
    wire buz_o;
    
    // Differential clock assignment (p is normal, n is inverted)
    assign clk_p = clk_tb;
    assign clk_n = ~clk_tb;

    // Instantiate the main module
    piano uut(
        .clk_p(clk_p),
        .clk_n(clk_n),
        .btn(btn),
        .rst_n(rst_n),
        .led(led),
        .buz_o(buz_o)
    );
    
    always #2.5 clk_tb = ~clk_tb;   // 5ns = 200MHz
    initial begin
        clk_tb = 1'd0;
        rst_n = 1'd0;
        #1_000_000;    // 1ms

        // Simulation start
        rst_n = 1;

        // 1. No sound state (30ms)
        btn = 2'b11;
        #30_000_000;
        // 2. 옥타브3_도(130.81Hz) state (30ms)
        btn = 2'b10;
        #30_000_000;
        // 3. 옥타브3_레(146.83Hz) state (30ms)
        btn = 2'b01;
        #30_000_000;
        // 4. 옥타브3_미(164.81Hz) state (30ms)
        btn = 2'b00;
        #30_000_000;
        
        $finish;
        // Simulation end
    end
endmodule