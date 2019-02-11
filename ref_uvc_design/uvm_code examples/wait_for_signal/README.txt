This example shows how to use a wait_for_signal task inside a configuration
object. In this case the bus sequence waits for an increasing number of clock
cycles before starting another bus transfer. The wait_for_clock task used 
counts positive clock edges on the clock inside the virtual interface inside the
configuration object.

To compile and run the simulation, please use the make file:

make all - Compile and run
make build - Compile only
make sim  - Run the simulation in command line mode

The Makefile assumes the use of Questa 10.0b or a later version
with built-in support for the UVM
