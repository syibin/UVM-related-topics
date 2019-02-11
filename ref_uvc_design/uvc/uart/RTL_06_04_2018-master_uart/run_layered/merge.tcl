merge -out ./cov_work/scope/merged_all ./cov_work/scope/* -metrics all -message 1 -overwrite
load ./cov_work/scope/merged_all
report -summary -inst uart_top_tb.dut -both -metrics all -out out.rpt -cumulative on -local on
exit
