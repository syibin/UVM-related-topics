
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION

set i0 +incdir+../../src/uart16550
set i1 +incdir+../../src/testbench
set i2 +incdir+../../src/

set s0 ../../src/uart16550/*.v
set s1 ../../src/testbench/*.v
set s2 ../../src/*.v

vlog $p0 $p1  $i0 $i1 $i2  $s0 $s1 $s2

vsim work.test_uart_transmit
add wave -radix hex sim:/test_uart_transmit/uart/*
run -all
wave zoom full
