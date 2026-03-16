# =========================================================
# Vivado Auto Create, Build & Upload Tcl Script
# =========================================================

# --- [1단계] 프로젝트 설정 변수 (본인 환경에 맞게 수정!) ---
# 1. 현재 스크립트가 실행되는 전체 경로 가져오기
set current_path [pwd]

# 2. 전체 경로에서 맨 마지막 '폴더 이름'만 추출하기 (예: /home/user/XX_piano -> XX_piano)
set folder_name [file tail $current_path]

# 3. 폴더 이름에서 앞부분 잘라내고 프로젝트 이름 만들기
# ex) 01_piano -> piano, 12_led_test -> led_test
regsub {^[0-9]{2}_} $folder_name "" proj_name

# 4. 추출한 이름으로 변수 세팅
set proj_dir "./$proj_name"
set xpr_file "$proj_dir/$proj_name.xpr"
set top_module $proj_name   ;  # Top 모듈 이름도 프로젝트 이름과 똑같다고 가정

# ALINX AX7203B 보드의 정확한 FPGA 칩셋명 (Artix-7 200T)
set fpga_part "xc7a200tfbg484-2"

# --- [2단계] 프로젝트 존재 여부 확인 및 생성 ---
if {[file exists $xpr_file]} {
    puts ">>> 기존 프로젝트($xpr_file)를 발견했습니다. 프로젝트를 엽니다..."
    open_project $xpr_file
} else {
    puts ">>> 프로젝트가 존재하지 않습니다. 새로 생성합니다..."

    # 새 프로젝트 생성
    create_project $proj_name $proj_dir -part $fpga_part

    # 스크립트가 있는 곳의 모든 .v 파일과 .xdc 파일 추가
    puts ">>> 소스 코드 및 XDC 제약 파일을 추가합니다..."
    add_files [glob -nocomplain ./*.v]
    add_files -fileset constrs_1 [glob -nocomplain ./*.xdc]

    # Top 모듈 지정 (가장 최상위 파일 이름)
    set_property top $top_module [current_fileset]
    update_compile_order -fileset sources_1

    puts ">>> 새 프로젝트 기본 세팅 완료!"
}

# --- [3단계] 합성(Synthesis) 실행 ---
puts ">>> Running Synthesis..."
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# --- [4단계] 구현(Implementation) 및 비트스트림(Bitstream) 생성 ---
puts ">>> Running Implementation & Bitstream Generation..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# --- [5단계] 하드웨어 매니저 열기 및 보드 연결 ---
puts ">>> Connecting to FPGA Board..."
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

# 연결된 첫 번째 FPGA 디바이스 잡기
set hw_device [lindex [get_hw_devices] 0]
current_hw_device $hw_device
refresh_hw_device -update_hw_probes false $hw_device

# 비트스트림 파일(.bit) 경로 설정 및 업로드
set bit_file [get_property DIRECTORY [get_runs impl_1]]/${top_module}.bit
set_property PROGRAM.FILE $bit_file $hw_device

puts ">>> Uploading Bitstream to FPGA..."
program_hw_devices $hw_device

# --- [6단계] 종료 ---
close_hw_manager
close_project
puts ">>> FPGA Programming Completed Successfully!"