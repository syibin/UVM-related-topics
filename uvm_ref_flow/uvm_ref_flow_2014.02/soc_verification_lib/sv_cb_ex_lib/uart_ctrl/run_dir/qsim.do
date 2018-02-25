if {[file exists work]} {
  vdel -lib work -all}

vlib work
vlog -sv -l qsta_compile.log -mfcu -f flist
vsim -novopt -c -suppress 3009 +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=apb_uart_rx_tx uart_ctrl_top
add wave /uart_ctrl_top/apb_if0/*
add wave /uart_ctrl_top/uart_if0/*
add wave /uart_ctrl_top/uart_dut/*
run 1ms
