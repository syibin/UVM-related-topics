This example shows how to implement a driver and a sequencer for a
bidrectional protocol when the driver uses get to obtain the next
sequence_item and put() to indicate that it has completed the transfer
and to return a response.

To compile and run the simulation, please use the make file -e.g:

make all - Compile and run
make build - Compile only
make sim  - Run the simulation in command line mode

The Makefile assumes the use of Questa 10.0b or a later version
with built-in support for the UVM
