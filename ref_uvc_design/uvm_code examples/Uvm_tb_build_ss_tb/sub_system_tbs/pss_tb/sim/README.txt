This example shows how a sub-system test bench can reuse agents, block-level
envs and block-level sequences.

In order to run the example you should make sure that the following environment
variables are set up:

QUESTA_HOME - Pointing to your install of Questa
UVM_REGISTER - Pointing to the directory in which you have copied the
uvm_register package

To compile and run the simulation, please use the make file:

make all - Compile and run
make rtl - Compile the rtl
make tb - Compile the structural level of the test bench
make build - Compile the uvm part of the test bench
make run  - Run the simulation in command line mode
          - You can also run the following tests by adding TEST=<test>
					- <test> = pss_gpio_outputs_test
                     pss_spi_interrupt_test
										 pss_spi_polling_test
                     pss_test (default)

By default, the make file runs a pss_spi_interrupt_test, but there are others
available - see the tests defined in the test directory.
