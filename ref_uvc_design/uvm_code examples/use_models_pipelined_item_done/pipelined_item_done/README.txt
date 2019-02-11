This example shows how to implement a driver and a sequencer for a pipelined
protocol, when the driver uses get() to obtain the next sequence item and
an data phase done event to indicate that it has completed the overall transfer. The relevant
files are in the mbus_pipelined_agent directory.

To compile and run the simulation, please use the make file -e.g:

make all - Compile and run
make build - Compile only
make sim  - Run the simulation in command line mode

The Makefile assumes the use of Questa 10.0b or a later version with
built-in support for the UVM
