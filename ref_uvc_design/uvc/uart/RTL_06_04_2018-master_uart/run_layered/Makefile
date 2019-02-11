DIR=-incdir ../tb_layered/  -incdir ../testcase
sys_ver_DIR=-sysv ../rtl/*.v -sysv ../tb_layered/uart_top_layered.sv  -sysv ../testcases/$(testcase).sv

COV=0
ifeq ($(COV), 1)
	COVERAGE=-coverage A  -covdut uart_top_tb  -covfile covfile.ccf  -covoverwrite  -covtest $(testcase)
else
	COVERAGE=
endif

testcase?=""

#T_STAMP:=$(shell date +%Y-%m-%d-%H.%M.%S)



make_dir:
	if [ ! -d "LOGS" ]; then \
		mkdir LOGS ; \
	fi ; \
	if [ ! -d "DUMP" ]; then \
		mkdir DUMP ; \
	fi ; \
	if [ ! -d "CSV" ]; then \
		mkdir CSV ; \
	fi ;


out_cat:
	rm CSV/output_all_regression_matrix.csv -rf ; \
	cat CSV/*regression_matrix.csv >> CSV/output_all_regression_matrix.csv ; \
	sed -i '1s/^/test case	PASS\/FAIL\n/' CSV/output_all_regression_matrix.csv ; \
	if [ `find latest` ]; then \
		unlink latest ; \
	fi; \
	ln -s CSV/output_all_regression_matrix.csv latest ;

imc:
	rm cov_work/scope/merged_all -rf ; \
	imc -batch -init merge.tcl ;

report:
	echo --------------------------------------------------------- ; \
	echo "          Verification Regression Summary" ; \
	echo --------------------------------------------------------- ; \
	PS_no=`awk '{ print $2 }' CSV/output_all_regression_matrix.csv | grep -c PASSED` ; \
	FL_no=`awk '{ print $2 }' CSV/output_all_regression_matrix.csv | grep -c FAILED` ; \
	Ttl_no=`expr $$PS_no + $$FL_no` ; \
	echo "          Total testcase:             $$Ttl_no" ; \
	echo "          Passed testcase:            $$PS_no" ; \
	echo "          Failed testcase:            $$FL_no" ; \
	echo -n "          Passed testcase percentage: " ; \
	echo "       scale=4; $$PS_no/$$Ttl_no*100" | bc ; \
	echo -n "          Failed testcase percentage: " ; \
	echo "       scale=4; $$FL_no/$$Ttl_no*100" | bc ; \
	echo "          Block Average:              `awk 'NR==4' out.rpt | awk '{ print $$2 }'`" ; \
	echo "          Block Covered:              `awk 'NR==4' out.rpt | awk '{ print $$3 }'` `awk 'NR==4' out.rpt | awk '{ print $$4 }'`" ; \
	echo "          Expression Average:         `awk 'NR==4' out.rpt | awk '{ print $$7 }'`" ; \
	echo "          Expression Covered:         `awk 'NR==4' out.rpt | awk '{ print $$8 }'` `awk 'NR==4' out.rpt | awk '{ print $$9 }'`" ; \
	echo "          Toggle Average:             `awk 'NR==4' out.rpt | awk '{ print $$12 }'`" ; \
	echo "          Toggle Covered:             `awk 'NR==4' out.rpt | awk '{ print $$13 }'` `awk 'NR==4' out.rpt | awk '{ print $$14 }'`"; \
	echo ---------------------------------------------------------  ;



usage:
	@echo "		===================";
	@echo "		= Makefile USAGE =";
	@echo "		===================";
	@echo "		Mode 1";
	@echo "			Instruction: make test testcase=testcase_name";
	@echo "			i.e., make test testcase=dma_test_001_os_f2f_word";
	@echo "			What it does: It runs irun with a single testcase 'dma_test_001_os_f2f_word' without coverage";
	@echo "			N.B.: use COV=1 to turn on coverage";
	@echo "		Mode 2";
	@echo "			Instruction: make all";
	@echo "			What it does: It runs irun with all the testcases in the ascending order";
	@echo "			N.B.: use COV=1 to turn on coverage";


test: make_dir
	irun -svseed random  -access +rw    -disable_sem2009  -timescale 1ns/1ns  $(DIR)  $(COVERAGE)   $(sys_ver_DIR)  ; \
	mv irun.log LOGS/$(testcase).log -f ; \
	mv dump.vcd DUMP/$(testcase).vcd -f ; \
	tclsh PF_proc.tcl $(testcase) ; \
	mv CSV/output.csv CSV/output_$(testcase)_regression_matrix.csv -f ; \
	if [ "`find latest`" ]; then \
		unlink latest ; \
	fi; \
	ln -s CSV/output_$(testcase)_regression_matrix.csv latest ; \


all:
	make test testcase=testcase_txinv_check
	make out_cat
	make imc
	make report


all_cov:
	make test testcase=dma_test_135_soc_uart_config COV=1
	make out_cat
	make imc
	make report


