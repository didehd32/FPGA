`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/20 10:45:49
// Design Name: 
// Module Name: burst_uart_32bit
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


module burst_uart_32bit(
    input clk,      // 200MHz 시스템 클럭
    input rst_n,
    input rx_pin,   // 보드의 UART RX 핀
    
    // burst 모듈로 넘겨줄 출력 신호들
    output reg [31:0] delay_i,  // 32bit delay value
    output reg is_delay_i,       // 4바이트가 다 모이면 딱 1클럭만 '1'이 되는 펄스
    output reg [31:0] prt_t_i,  
    output reg is_prt_i
    );
    
    // Baud Rate 설정: 115200 bps (200MHz/115200=1736.xx)
    parameter CLKS_PER_BIT = 1736;
    
    // UART 수신 상태 머신
    parameter s_IDLE         = 3'd0;
    parameter s_RX_START_BIT = 3'd1;
    parameter s_RX_DATA_BITS = 3'd2;
    parameter s_RX_STOP_BIT  = 3'd3;
    parameter s_CLEANUP      = 3'd4;
    
    reg [2:0] state = 0;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;    // 8비트 중 몇 번째 비트인지
    reg [7:0] rx_byte = 0;      // 수신된 1바이트 임시 저장소
    reg rx_byte_ready = 0;      // 1바이트 수신 완료 신호 (1클럭 펄스)
    
    // 32비트 조립용 변수
    reg [2:0] byte_count = 0;
    reg [7:0] cmd_reg = 0;
    reg [31:0] shift_reg = 0;
    
    reg rx_sync_1, rx_sync_2;

// FF
always @(posedge clk) begin
    rx_sync_1 <= rx_pin;
    rx_sync_2 <= rx_sync_1;
end

// 1byte(8bit) 단위 UART 수신
always @(posedge clk) begin
    if (!rst_n) begin
        state <= s_IDLE;
        clk_count <= 0;
        bit_index <= 0;
        rx_byte <= 0;
        rx_byte_ready <= 0;
    end
    else begin
        rx_byte_ready <= 0; // 기본적으로 0 유지 (펄스 생성용)
        case (state)
        s_IDLE : begin
            clk_count <= 0;
            bit_index <= 0;
            // Start Bit(0으로 떨어짐) 감지
            if (rx_sync_2 == 1'b0) begin
                state <= s_RX_START_BIT;
            end
        end
        s_RX_START_BIT : begin
        // 비트의 딱 '중간' 지점까지 대기 (가장 안정적인 쓰레기값 없는 시점)
            if (clk_count == (CLKS_PER_BIT / 2)) begin
                if (rx_sync_2 == 1'b0) begin
                    clk_count <= 0;  // 확인 완료, 카운터 리셋
                    state <= s_RX_DATA_BITS;
                end
                else begin
                    state <= s_IDLE; // 노이즈였음 (다시 대기)
                end
            end
            else begin
                clk_count <= clk_count + 1;
            end
        end
        s_RX_DATA_BITS : begin
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end
            else begin
                clk_count <= 0;
                rx_byte[bit_index] <= rx_sync_2; // 1비트 저장
                if (bit_index < 7) begin
                    bit_index <= bit_index + 1;
                end
                else begin
                    bit_index <= 0;
                    state <= s_RX_STOP_BIT; // 8비트 다 받음
                end
            end
        end
        s_RX_STOP_BIT : begin
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end
            else begin
                rx_byte_ready <= 1'b1; // 1바이트 수신 완료 펄스
                clk_count <= 0;
                state <= s_CLEANUP;
            end
        end
        s_CLEANUP : begin
            state <= s_IDLE;
        end
        default : begin
            state <= s_IDLE;
        end
        endcase
    end
end

// 5바이트 모아서 분배하기 로직
always @(posedge clk) begin
    if (!rst_n) begin
        byte_count <= 0;
        shift_reg <= 0;
        delay_i <= 0;
        is_delay_i <= 0;
        prt_t_i <= 0;
        is_prt_i <= 0;
    end
    else begin
        is_delay_i <= 0; // 1클럭 펄스를 위한 기본값 0 세팅
        is_prt_i <= 0;
        
        if (rx_byte_ready) begin
            if (byte_count == 3'd0) begin
                // 첫 번째 들어온 바이트는 '명령어(주소)'로 인식
                cmd_reg <= rx_byte;
                byte_count <= byte_count + 1;
            end
            else begin
                // 나머지 4바이트는 데이터로 차곡차곡 조립
                shift_reg <= {shift_reg[23:0], rx_byte};
                // 5바이트(명령어1 + 데이터4)가 다 찼다면
                if (byte_count == 3'd4) begin
                    // 명령어에 따라 맞는 곳에 데이터를 쏴줌
                    if (cmd_reg == 8'h01) begin       // 명령어 0x01: 딜레이
                        delay_i <= {shift_reg[23:0], rx_byte};
                        is_delay_i <= 1'b1;
                    end
                    else if (cmd_reg == 8'h02) begin  // 명령어 0x02: PRT
                        prt_t_i <= {shift_reg[23:0], rx_byte};
                        is_prt_i <= 1'b1;
                    end
                    byte_count <= 0; // 다음 5바이트를 받을 준비
                end
                else begin
                    byte_count <= byte_count + 1;
                end
            end
        end
    end
end

endmodule
