This example shows how to build up block level test bench using agents.

In order to run the example you should make sure that the following environment
variables are set up:

QUESTA_HOME - Pointing to your install of Questa
UVM_HOME - Pointing to the top of your copy of the UVM source code tree
UVM_REGISTER - Pointing to the directory in which you have copied the
uvm_register package (This is the ovm_register package which has been ported
to UVM.  This is not the official included UVM Register Layer. That is coming.)

To compile and run the simulation, please use the make file:

make all - Compile and run
make build - Compile the uvm part of the test bench
make run  - Run the simulation in command line mode
          - You can also run the following tests by adding TEST=<test>
					- <test> = spi_debug_test
                     spi_interrupt_test (default)
                     spi_poll_test
                     spi_reg_test

By default, the make file runs a spi_interrupt_test, but there are others
available - see the tests defined in the test directory.
