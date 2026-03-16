#!/bin/bash

# =========================================================
# Vivado 자동 생성 파일 및 프로젝트 초기화 (Clean) 스크립트
# =========================================================

echo "========================================="
echo " Start cleaning... "
echo "========================================="

# 1. 현재 폴더 이름 가져오기
CURRENT_DIR=$(basename "$PWD")

# 2. 정규표현식으로 맨 앞의 '숫자_' 패턴 잘라내기 (예: 01_piano -> piano)
PROJ_NAME=$(echo "$CURRENT_DIR" | sed -r 's/^[0-9]+_//')

echo ">>> 타겟 프로젝트 이름: $PROJ_NAME"

rm -rf "$PROJ_NAME"     2>/dev/null  # 프로젝트 폴더
rm -rf .Xil             2>/dev/null  # 숨김 폴더
rm -f *.log             2>/dev/null  # 모든 log 파일 (backup 포함)
rm -f *.jou             2>/dev/null  # 모든 jou 파일 (backup 포함)
rm -f *.str             2>/dev/null  # 크래시 찌꺼기

echo "========================================="
echo " Clean complete."
echo "========================================="