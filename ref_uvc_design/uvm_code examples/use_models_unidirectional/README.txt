This example shows how to implement a driver and a sequencer for a
unidirectional protocol, when the driver uses get_next_item() to obtain the next sequence item and
item_done() to indicate that it has completed the overall transfer. 

To compile and run the simulation, please use the make file -e.g:

make all - Compile and run
make build - Compile only
make sim  - Run the simulation in command line mode

The Makefile assumes the use of Questa 10.0b or a later version
with built-in support for the UVM
