`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/20 11:09:33
// Design Name: 
// Module Name: burst_main
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


module burst_main(
    input clk_p,        // 200MHz Positive clock
    input clk_n,        // 200MHz Negative clock
    input rst_n,
    input rx_pin,       // python input (UART)
    output [1:0] buz_o
    );

    wire clk;
    wire [31:0] delay_val_wire; // UART에서 나와서 Burst로 들어갈 32비트 데이터 선
    wire is_delay_pulse_wire;   // UART에서 나와서 Burst로 들어갈 1클럭 펄스 선
    wire [31:0] prt_t_wire;
    wire is_prt_pulse_wire;

    // Change 차동 클락 -> 단일 클락
    IBUFDS clk_inst (
        .O(clk),        // 내부 로직으로 들어가는 단일 클락
        .I(clk_p),      // 외부에서 들어오는 P 클락
        .IB(clk_n)      // 외부에서 들어오는 N 클락
    );

    BUFG bufg_inst (
        .I(clk_ibuf),
        .O(clk)
    );

    // UART 통신 모듈 배치 및 배선 연결
    burst_uart_32bit uart_rx_inst (
        .clk(clk),          // 변환된 공통 클럭 공급
        .rst_n(rst_n),
        .rx_pin(rx_pin),    // 외부 수신 핀 연결
        // 출력되는 신호들을 내부 전선에 연결
        .delay_i(delay_val_wire),       
        .is_delay_i(is_delay_pulse_wire),
        .prt_t_i(prt_t_wire),
        .is_prt_i(is_prt_pulse_wire)
    );

    // Burst 모듈 배치 및 배선 연결
    burst burst_inst (
        .clk(clk),      // 변환된 공통 클럭 공급
        .rst_n(rst_n),
        // UART 모듈에서 나온 내부 전선을 입력으로 받음
        .delay_i(delay_val_wire),
        .is_delay_i(is_delay_pulse_wire),
        .prt_t_i(prt_t_wire),
        .is_prt_i(is_prt_pulse_wire),
        .buz_o(buz_o)   // 외부 부저 핀으로 바로 출력
    );

endmodule
