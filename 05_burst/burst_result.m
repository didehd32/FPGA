clear;

%% 1. 데이터 불러오기
raw_data = readmatrix('D:\Eunhye\FPGA_project\07_burst\burst\burst.sim\sim_1\behav\xsim\burst_results.txt'); 

% 비트 분리 (1열: buz_o[1], 2열: buz_o[0])
bit_msb = raw_data(:, 1); % buz_o[1]
bit_lsb = raw_data(:, 2); % buz_o[0]

% 설정
fs = 1 / 5e-9;           % 200MHz 샘플링 주파수
L = length(raw_data);
t = (0:L-1) / fs;        % 시간 축 (초 단위)
f = fs * (0:(L/2)) / L;  % 주파수 축 (Hz 단위)

%% 2. FFT 계산 (DC 성분 제거 포함)
% buz_o[1] (MSB) 분석
Y_msb = fft(bit_msb - mean(bit_msb)); 
P2_msb = abs(Y_msb/L);
P1_msb = P2_msb(1:floor(L/2)+1);
P1_msb(2:end-1) = 2*P1_msb(2:end-1);

% buz_o[0] (LSB) 분석
Y_lsb = fft(bit_lsb - mean(bit_lsb)); 
P2_lsb = abs(Y_lsb/L);
P1_lsb = P2_lsb(1:floor(L/2)+1);
P1_lsb(2:end-1) = 2*P1_lsb(2:end-1);

%% 3. 시각화 (2x2 레이아웃) - 필요한 구간만 그리기
figure('Name', 'Buzzer Signal Analysis: buz_o[1:0]', 'Position', [100, 100, 1000, 700]);

max_points = 100000;

% 시간 영역: 전체 길이에 맞춰서 듬성듬성 건너뛸 간격(step) 계산
step_t = max(1, floor(L / max_points));
idx_t = 1:step_t:L;

% 주파수 영역: 1MHz까지만 자르고, 그 안에서도 점이 많으면 건너뛰기
limit_freq = 0.01; 
idx_freq_max = find((f/1e6) <= limit_freq, 1, 'last');
step_f = max(1, floor(idx_freq_max / max_points));
idx_f = 1:step_f:idx_freq_max;

% --- buz_o[1] (MSB) 결과 ---
subplot(2,2,1); % 시간 영역
plot(t(idx_t)*1e6, bit_msb(idx_t), 'b', 'LineWidth', 1);
title('buz\_o[1] Time Domain');
xlabel('t (us)'); ylabel('x(t)');
grid on; ylim([-0.2 1.2]);

subplot(2,2,2); % 주파수 영역
plot(f(idx_f)/1e6, P1_msb(idx_f), 'b', 'LineWidth', 1);
title('buz\_o[1] Frequency Domain');
xlabel('f (MHz)'); ylabel('|X(f)|');
grid on;

% --- buz_o[0] (LSB) 결과 ---
subplot(2,2,3); % 시간 영역
plot(t(idx_t)*1e6, bit_lsb(idx_t), 'r', 'LineWidth', 1);
title('buz\_o[0] Time Domain');
xlabel('t (us)'); ylabel('x(t)');
grid on; ylim([-0.2 1.2]);

subplot(2,2,4); % 주파수 영역
plot(f(idx_f)/1e6, P1_lsb(idx_f), 'r', 'LineWidth', 1);
title('buz\_o[0] Frequency Domain');
xlabel('f (MHz)'); ylabel('|X(f)|');
grid on;