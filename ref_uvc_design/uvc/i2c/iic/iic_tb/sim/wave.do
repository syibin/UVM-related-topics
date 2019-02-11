onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -label iicBitCnt -radix unsigned /top/iic_fcov_monitor_inst/iicBitCnt
add wave -noupdate -label iicByteCnt -radix unsigned /top/iic_fcov_monitor_inst/iicByteCnt
add wave -noupdate -label iicRxReg -radix hexadecimal /top/iic_fcov_monitor_inst/iicRxReg
add wave -noupdate -label iicData -radix hexadecimal /top/iic_fcov_monitor_inst/iicData
add wave -noupdate -label iicAddress -radix hexadecimal /top/iic_fcov_monitor_inst/iicAddress
add wave -noupdate -label iicRwb /top/iic_fcov_monitor_inst/iicRwb
add wave -noupdate -divider Bus
add wave -noupdate -color {Cornflower Blue} /top/sda
add wave -noupdate -color {Cornflower Blue} /top/scl
add wave -noupdate -label sta_condition /top/dut/byte_controller/bit_controller/sta_condition
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT Master}
add wave -noupdate -color Coral -label frameType /top/wbIf/frameType
add wave -noupdate -color Coral -label frameState /top/wbIf/frameState
add wave -noupdate -color Coral -label sda_padoen_o /top/dut/sda_padoen_o
add wave -noupdate -color Coral -label scl_padoen_o /top/dut/scl_padoen_o
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {xt Master}
add wave -noupdate -color Coral -label frameType /top/iicIf1/frameType
add wave -noupdate -color Coral -label frameState /top/iicIf1/frameState
add wave -noupdate -color Coral -label sda_out /top/iicIf1/sda_out
add wave -noupdate -color Coral -label scl_out /top/iicIf1/scl_out
add wave -noupdate -color Coral -label busIsFree /top/iicIf1/busIsFree
add wave -noupdate -divider {Slave TX1}
add wave -noupdate -label frameType /top/iicIf2/frameType
add wave -noupdate -label frameState /top/iicIf2/frameState
add wave -noupdate -label sda_out /top/iicIf2/sda_out
add wave -noupdate -label scl_out /top/iicIf2/scl_out
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {Slave RX1}
add wave -noupdate -label frameType /top/iicIf3/frameType
add wave -noupdate -label frameState /top/iicIf3/frameState
add wave -noupdate -label sda_out /top/iicIf3/sda_out
add wave -noupdate -label scl_out /top/iicIf3/scl_out
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {Slave TX2}
add wave -noupdate -label frameState /top/iicIf4/frameState
add wave -noupdate -label frameType /top/iicIf4/frameType
add wave -noupdate -label sda_out /top/iicIf4/sda_out
add wave -noupdate -label scl_out /top/iicIf4/scl_out
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {Slave RX2}
add wave -noupdate -label frameState /top/iicIf5/frameState
add wave -noupdate -label frameType /top/iicIf5/frameType
add wave -noupdate -label sda_out /top/iicIf5/sda_out
add wave -noupdate -label scl_out /top/iicIf5/scl_out
add wave -noupdate -label iicBitName /top/iicIf5/iicBitName
add wave -noupdate -divider <NULL>
add wave -noupdate -label dut_scl_out /top/iic_fcov_monitor_inst/dut_scl_out
add wave -noupdate -label dut_sda_out /top/iic_fcov_monitor_inst/dut_sda_out
add wave -noupdate /top/sda
add wave -noupdate -label rst /top/iic_fcov_monitor_inst/rst
add wave -noupdate -label sda_in /top/iicIf1/sda_in
add wave -noupdate -label scl_in /top/iicIf1/scl_in
add wave -noupdate -divider {DUT IIC}
add wave -noupdate -color Coral /top/dut/sda_padoen_o
add wave -noupdate -color Coral /top/dut/scl_padoen_o
add wave -noupdate -label busy /top/dut/byte_controller/bit_controller/busy
add wave -noupdate -label data /top/wbIf/data
add wave -noupdate -divider WB
add wave -noupdate /top/wbIf/comment
add wave -noupdate /top/dut/wb_clk_i
add wave -noupdate /top/dut/wb_rst_i
add wave -noupdate /top/dut/arst_i
add wave -noupdate -radix hexadecimal /top/dut/wb_adr_i
add wave -noupdate -radix hexadecimal /top/dut/wb_dat_i
add wave -noupdate -radix hexadecimal /top/dut/wb_dat_o
add wave -noupdate /top/dut/wb_we_i
add wave -noupdate /top/dut/wb_stb_i
add wave -noupdate /top/dut/wb_cyc_i
add wave -noupdate /top/dut/wb_ack_o
add wave -noupdate /top/dut/wb_inta_o
add wave -noupdate -divider {DUT Regs}
add wave -noupdate -label al /top/dut/byte_controller/bit_controller/al
add wave -noupdate -radix hexadecimal /top/dut/prer
add wave -noupdate -radix hexadecimal /top/dut/ctr
add wave -noupdate -radix hexadecimal /top/dut/txr
add wave -noupdate -radix hexadecimal /top/dut/rxr
add wave -noupdate -color {Yellow Green} -radix hexadecimal -childformat {{{/top/dut/cr[7]} -radix hexadecimal} {{/top/dut/cr[6]} -radix hexadecimal} {{/top/dut/cr[5]} -radix hexadecimal} {{/top/dut/cr[4]} -radix hexadecimal} {{/top/dut/cr[3]} -radix hexadecimal} {{/top/dut/cr[2]} -radix hexadecimal} {{/top/dut/cr[1]} -radix hexadecimal} {{/top/dut/cr[0]} -radix hexadecimal}} -subitemconfig {{/top/dut/cr[7]} {-color #9a9acdcd3232 -height 15 -radix hexadecimal} {/top/dut/cr[6]} {-color #9a9acdcd3232 -height 15 -radix hexadecimal} {/top/dut/cr[5]} {-color #9a9acdcd3232 -height 15 -radix hexadecimal} {/top/dut/cr[4]} {-color #9a9acdcd3232 -height 15 -radix hexadecimal} {/top/dut/cr[3]} {-color #9a9acdcd3232 -height 15 -radix hexadecimal} {/top/dut/cr[2]} {-color #9a9acdcd3232 -height 15 -radix hexadecimal} {/top/dut/cr[1]} {-color #9a9acdcd3232 -height 14 -radix hexadecimal} {/top/dut/cr[0]} {-color #9a9acdcd3232 -height 14 -radix hexadecimal}} /top/dut/cr
add wave -noupdate -radix hexadecimal -childformat {{{/top/dut/sr[7]} -radix hexadecimal} {{/top/dut/sr[6]} -radix hexadecimal} {{/top/dut/sr[5]} -radix hexadecimal} {{/top/dut/sr[4]} -radix hexadecimal} {{/top/dut/sr[3]} -radix hexadecimal} {{/top/dut/sr[2]} -radix hexadecimal} {{/top/dut/sr[1]} -radix hexadecimal} {{/top/dut/sr[0]} -radix hexadecimal}} -expand -subitemconfig {{/top/dut/sr[7]} {-height 15 -radix hexadecimal} {/top/dut/sr[6]} {-height 15 -radix hexadecimal} {/top/dut/sr[5]} {-height 15 -radix hexadecimal} {/top/dut/sr[4]} {-height 15 -radix hexadecimal} {/top/dut/sr[3]} {-height 15 -radix hexadecimal} {/top/dut/sr[2]} {-height 15 -radix hexadecimal} {/top/dut/sr[1]} {-height 15 -radix hexadecimal} {/top/dut/sr[0]} {-height 15 -radix hexadecimal}} /top/dut/sr
add wave -noupdate -radix hexadecimal /top/dut/done
add wave -noupdate -radix hexadecimal /top/dut/core_en
add wave -noupdate /top/dut/wb_wacc
add wave -noupdate /top/dut/sta
add wave -noupdate /top/dut/sto
add wave -noupdate /top/dut/rd
add wave -noupdate /top/dut/wr
add wave -noupdate /top/dut/ack
add wave -noupdate /top/dut/iack
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {87251839 ns} 1}
configure wave -namecolwidth 198
configure wave -valuecolwidth 139
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {593325 ns}
