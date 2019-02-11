This is the AHB simulation suite. It contains the following files:

ahb_def.v - Definition file
ahbmst.v - AHB master model
ahbslv.v - AHB slave model
ahbarb.v - AHB arbiter model
ahbdec.v - AHB decoder model
testbench.v - Top level test bench file
ahb_stimuli.v - Sample AHB stimuli file
qm_ahbmst_(test_)tasks(1,2).v - Test vector files for AHB master and slave
ahbmodel.spj - Silos III simulation project file


AHB Master:
The main interface to the AHB master is to call the ahb_transfer task. The parameters are explained below. During a write data is obtained from an internal array called data_array, and during a read the data read from the AHB bus is either compared to the data in data_array or stored in data_array. Data_array is byte wide.

ahb_transfer(addr,size,burst,rn_w,count,store_rdata,comp_rdata,pass_failn)
	addr is the AHB address, 32-bit.
	size is the transfer size, allowed values are BUS_8/BUS_16/BUS_32 (defined in ahb_def.v).
	burst is the burst type, allowed values are SINGLE/INCR/INCR4/INCR8/INCR16/WRAP4/WRAP8/WRAP16 (defined in ahb_def.v).
	rn_w is read (low) or write (high), allowed values are WRITE/READ (defined in ahb_def.v).
	count is the number of beats (data phases), not the # of bytes or words.
		The actual number of bytes transferred also depends on the size signal.
	store_rdata is whether to store data read in data_array. 1'b1 stores.
	comp_rdata is whether to compare read data with data_array and report error when data compare fails. 1'b1 compares.
		normally if you want to store data then no compare, if you want to compare then no store,
	 	but you can also want no store and no compare (just to test the flow).
	pass_failn is the return value of whether data compare fails. 1'b1 passes and 1'b0 fails.


AHB Slave:
The AHB slave provides a memory-type of device on AHB. In addition to storing data, it can also insert arbitrary number of wait states at each data phase and issue RETRY or ERROR at arbitrary data phase. The interface are 3 tasks: set_delay, set_resp, and set_resp_limit.

set_delay: It takes two parameters - data phase and wait states. It makes the slave model insert a specific number of wait states at that data phase. By default 0 wait state is specified for all data phases.
set_resp: It takes two parameters - data phase and response (OKAY/ERROR/RETRY). It makes the slave model issue the specified response at the specified data phase. The SPLIT response is not supported since QuickMIPS does not support split. By default the OKAY response is specified for all data phases.
set_resp_limit: It takes two parameter - data phase and response limit. It makes the slave model use the response specified in set_resp up to a certain times, then use OKAY afterwards. If it is 0 then there is no limit. By default it is 0 for all data phases.


AHB Decoder:
The AHB decoder decodes the address and assigns it to a particular slave. Currently it supports 3 slaves and their address mappings are:

hsel0 - 32'h0000_0000 - 32'h0FFF_FFFF
hsel1 - 32'h1000_0000 - 32'h3FFF_FFFF
hsel2 - the rest

The address mapping can be easily changed and more slaves can be added easily.


AHB Arbiter:
The AHB arbiter provides arbitration to the AHB bus. It currently supports 4 masters and uses a priority scheme. There is a maximum timeout value that regulates how long (clock cycles) a master can use the bus. The parameter name is tout_value.


Ahb_stimuli.v:
This file contains some sample usage of the models.


Features Not Implemented:
 - Slave split capability. QuickMIPS does not support split.
 - Master busy state insertion.
 - Arbiter more arbitration schemes. QuickMIPS uses fixed-priority arbitration scheme, so it should be okay.
