# APB-UART-bridge
Creating a bridge between APB interface and UART in verilog.
Why? To kill time i guess :P

4 addresses
0 : Data (R/W) 32bit
4 : State register (RO)
8 : Control register to control TX/RX. Planning to add interupts to TX/RX so maybe control that too.(R/W)
c : Baud divider (R/W)

4 deep aync FIFO to queue up data from APB
Similar FIFO on the APB read side but may change.

TODO: Register spec, divider logic
