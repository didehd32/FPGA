# FPGA
1) 01_led_blink (ref. https://github.com/matbi86/matbi_fpga_season_1 ) // upload date : 2026-03-09
- Zynq board / Veilog practice
2) 02_led_blink_2 (ref. https://www.youtube.com/watch?v=qtBuGEDdczM ) // Last update : 2026-03-12
- Alinx Artix-7 xc7a200tfbg484 board
- Make Veilog code for LED blink per 1 sec (using 200MHz clock)
- Uploaded code on board and Check LED blinking
- Used ILA IP core
3) 03_led_button (ref. https://www.youtube.com/watch?v=zSyc6py964Q ) // upload date : 2026-03-12
- Alinx Artix-7 xc7a200tfbg484 board
- If you press the button, then turn on the LED
4) 04_piano // upload date : 2026-03-13 // Last update : 2026-03-16
- Alinx Artix-7 xc7a200tfbg484 board
- If you press the key 1, then turn on the LED 1 and make a sound
- If you press the key 2, then turn on the LED 2 and make another sound
- If you press the key 1 and 2, then turn on the LED 1 & 2 and make a different sound
- Two testbench files. (1) reset button testbench (2) key 1,2 testbench
- Make build.sh and clean.sh for automation
5) 05_burst // upload date : 2026-03-17 // Last update : 2026-03-20
- Alinx Artix-7 xc7a200tfbg484 board
- Make two signals (connected two buzzers), Same PRT 5s
- (1) Burst duration time 1s, Freq 5Hz, 1 Cycle time 0.2s
- (2) Burst duration time 0.2ms, Freq 50Hz, 1 Cycle time 0.02s
- Added functionality to input “Delay” and “PRT”
