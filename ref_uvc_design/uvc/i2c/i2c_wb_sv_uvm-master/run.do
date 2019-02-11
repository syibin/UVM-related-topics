vlog ./../i2c_master_slave_core/verilog/rtl/*.v
vlog +define+UVM_NO_DPI +incdir+C:\\modeltech64_10.1c\\uvm-1.2\\src C:\\modeltech64_10.1c\\uvm-1.2\\src\\uvm_pkg.sv uvm_i2c_top_tb.sv
vsim -novopt top
add wave -r /*
run 5 us 
