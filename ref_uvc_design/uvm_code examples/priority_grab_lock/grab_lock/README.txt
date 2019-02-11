This example shows how the sequencer lock and grab mechanisms work. The example
contains a number of sequences which are competing to send sequence_items to
a driver. Some of these sequences use grab and lock to get exclusive access to
the sequencer for their sequence_items. The arbitration argument used by the 
sequencer is set via a command line plusarg switch:

+ARB_TYPE=<SEQ_ARB_xxxx enum>

By default, the make file runs through all the available arbitration options.

The example also contains an implementation of a user arbitration algorithm.

To compile and run the simulation, please use the make file:

make all - Compile and run
make build - Compile only
make sim  - Run the simulation in command line mode

The Makefile assumes the use of Questa 10.0b or a later version with
built-in support for the UVM
