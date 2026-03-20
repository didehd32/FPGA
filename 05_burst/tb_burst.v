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
    reg [31:0] delay_i;
    reg is_delay_i;
    reg [31:0] prt_t_i;
    reg is_prt_i;
    wire [1:0] buz_o;

    // Instantiate the main module
    burst uut(
        .clk(clk_tb),
        .rst_n(rst_n),
        .delay_i(delay_i),
        .is_delay_i(is_delay_i),
        .prt_t_i(prt_t_i),
        .is_prt_i(is_prt_i),
        .buz_o(buz_o)
    );
    
    always #2.5 clk_tb = ~clk_tb;   // 5ns = 200MHz
    
    integer file;
    initial begin
        clk_tb = 1'd0;
        rst_n = 1'b0;
        delay_i = 32'd0;
        is_delay_i = 1'b0;
        prt_t_i = 32'd0;
        is_prt_i = 1'b0;
        #1_000_000;    // 1ms

        // Simulation start
        rst_n = 1'b1;
        delay_i = 32'd0;  // 0~4,294,967,295
        is_delay_i = 1'b0;

        file = $fopen("burst_results.txt", "w");
        
        // test 1. PRT 0.5ms(100,000 클럭)
        prt_t_i = 32'd200_000;
        is_prt_i = 1'b1;
        #5;                   // 5ns
        is_prt_i = 1'b0;
        #500_000; // 부저들이 바뀐 PRT 간격으로 0.5ms 동안 울리는지 관찰

        // test 2. Delay 1ms = 200,000
        delay_i = 32'd100_000; 
        is_delay_i = 1'b1;
        #5;                   // 5ns
        is_delay_i = 1'b0;
        
        #2_000_000;      // 2ms 동안 시뮬레이션 진행 후 종료
        
        $fclose(file);
        
        $display("Simulation Finished and Data Saved.");
        $finish;
        // Simulation end
    end
    always @(posedge clk_tb) begin
        if (rst_n == 1'b1) begin
            $fdisplay(file, "%b %b", buz_o[1], buz_o[0]);
        end
    end
endmodule