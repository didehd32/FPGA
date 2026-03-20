import serial
import time
import sys

# COM 포트는 본인 환경에 맞게 수정하세요!
COM_PORT = 'COM3'
BAUD_RATE = 115200
CLK_FREQ = 200000000  # 200MHz
MAX_SEC = 21.47  # 32비트 한계 (4,294,967,295 / 200,000,000)

try:
    ser = serial.Serial(COM_PORT, BAUD_RATE)
    time.sleep(1)  # 시리얼 연결 안정화 대기
    print(f"{COM_PORT} 연결 성공!")
except Exception as e:
    print(f"포트 연결 실패: {e}")
    sys.exit()

print("=" * 45)
print("FPGA 실시간 제어 터미널")
print(f"주의: 입력 가능한 최대 시간은 {MAX_SEC}초 입니다.")
print("=" * 45)

while True:
    try:
        print("통신 버퍼 청소 중...")
        # 0x00을 10번 연속으로 보내서 FPGA의 byte_count를 강제로 한 바퀴 돌려버립니다.
        ser.write(b'\x00' * 10)
        time.sleep(0.5)

        print("\n[1] PRT (반복 주기) 변경")
        print("[2] Delay (강제 정지) 실행")
        print("[3] 종료")
        choice = input("원하는 명령을 선택하세요 (1/2/3): ")

        if choice == '3':
            print("프로그램을 종료합니다.")
            break

        if choice not in['1', '2']:
            print("잘못된 입력입니다. 1, 2, 3 중에서 선택해주세요.")
            continue

        # 시간 입력받기
        sec_str = input(f"시간을 초(sec) 단위로 입력하세요 (최대 {MAX_SEC}초): ")
        sec = float(sec_str)

        # 최대값 검사
        if sec < 0:
            print("시간은 0보다 커야 합니다.")
            continue
        elif sec > MAX_SEC:
            print(f"최대 한계치({MAX_SEC}초)를 초과했습니다! 다시 입력해주세요.")
            continue

        # 클럭 사이클로 변환
        cycles = int(sec * CLK_FREQ)

        # 패킷 생성 및 전송
        if choice == '1':
            # PRT 변경 명령 (0x02)
            packet = bytes([0x02]) + cycles.to_bytes(4, byteorder='big')
            ser.write(packet)
            print(f"[전송 완료] PRT 주기가 {sec}초로 변경되었습니다.")

        elif choice == '2':
            # Delay 명령 (0x01)
            packet = bytes([0x01]) + cycles.to_bytes(4, byteorder='big')
            ser.write(packet)
            print(f"[전송 완료] {sec}초 동안 시스템을 정지합니다.")

    except ValueError:
        print("숫자를 정확히 입력해주세요! (예: 1.5, 5)")
    except KeyboardInterrupt:
        print("\n프로그램을 강제 종료합니다.")
        break

ser.close()