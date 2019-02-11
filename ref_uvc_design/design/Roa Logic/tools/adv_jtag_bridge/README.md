# adv_jtag_bridge

This is a port of the OpenCores adv_jtag_bridge to support the RISC-V adv_dbg_sys port, which can also be found on RoaLogic github.

Building instructions:
```
    ./autogen.sh
    ./configure
    ./make
```

To support the ft254 (Altera USB Blaster) make sure to install libusb and libftdi.
Currently the core only supports the pre 1.0 releases. So make sure to install the correct version.



