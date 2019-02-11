irun -access +rwc -svseed random -disable_sem2009 -incdir ../tb_layered -sysv ../rtl/*.v ../tb_layered/uart_top_layered.sv ../testcases/testcase_$1.sv -coverage A -covdut uart_top_tb -covfile covfile.ccf -covoverwrite -covtest test_$1
# | tee ../test_logs/simulation.log -192902774 -1283492274 -461337688
