#!/bin/bash

# =========================================================
# 리눅스 터미널에서 Vivado 빌드 시작하기
# =========================================================

SECONDS=0

# 1. Vivado 환경 변수 로드
VIVADO_SETTINGS="$HOME/tools/Xilinx/2025.2/Vivado/settings64.sh"

if [ -f "$VIVADO_SETTINGS" ]; then
    echo ">>> Vivado 2025.2 환경을 로드합니다..."
    source "$VIVADO_SETTINGS"
else
    echo "Error: $VIVADO_SETTINGS 파일을 찾을 수 없습니다."
    echo "Vivado가 해당 경로에 설치되어 있는지 다시 한번 확인해 주세요!"
    exit 1
fi

echo "========================================="
echo " FPGA Auto Build & Upload Started... "
echo "========================================="

# 2. Vivado를 GUI 없이 '배치(Batch)' 모드로 실행하며 tcl 스크립트 전달
vivado -mode batch -source run_fpga.tcl

ELAPSED=$SECONDS
MINUTES=$((ELAPSED / 60))
SEC=$((ELAPSED % 60))

echo "========================================="
echo " All Processes Finished! "
echo " Total Execution Time : ${MINUTES}분 ${SEC}초"
echo "========================================="