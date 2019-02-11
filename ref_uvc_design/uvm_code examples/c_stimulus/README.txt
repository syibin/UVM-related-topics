This example shows how to use the c_stimulus_pkg for running c based stimulus
on a register based UVM environment..

To compile and run the simulation, please use the make file:

cd block_level_example/sim

make all - Compile and run
make rtl - Compile the rtl
make build - Compile the UVM test bench
make run  - Run the simulation test cases in command line mode

The Makefile assumes the use of Questa 10.1a or a later version with
built-in support for the UVM and the vlog DPI compile

By default, the make file runs the spi_c_int_test, followed the spi_c_poll_test but the package also
contains the UVM sequence based tests:

spi_interrupt_test
spi_poll_test

The tests are defined in the test directory.
