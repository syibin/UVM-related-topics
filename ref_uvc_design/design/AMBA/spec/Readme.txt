AMBA protocol specifications

The AMBA specification defines an on-chip communications standard for designing high-performance embedded microcontrollers. It is supported by ARM Limited with wide cross-industry participation.

The AMBA 5 specification defines the following buses/interfaces:
    Advanced High-performance Bus (AHB5, AHB-Lite)
    CHI Coherent Hub Interface (CHI) [3]


The AMBA 4 specification defines following buses/interfaces:
    AXI Coherency Extensions (ACE) - widely used on the latest ARM Cortex-A processors including Cortex-A7 and Cortex-A15
    AXI Coherency Extensions Lite (ACE-Lite)
    Advanced Extensible Interface 4 (AXI4)
    Advanced Extensible Interface 4 Lite (AXI4-Lite)
    Advanced Extensible Interface 4 Stream (AXI4-Stream v1.0)
    Advanced Trace Bus (ATB v1.1)
    Advanced Peripheral Bus (APB4 v2.0)


AMBA 3 specification defines four buses/interfaces:
    Advanced Extensible Interface (AXI3 or AXI v1.0) - widely used on ARM Cortex-A processors including Cortex-A9
    Advanced High-performance Bus Lite (AHB-Lite v1.0)
    Advanced Peripheral Bus (APB3 v1.0)
    Advanced Trace Bus (ATB v1.0)


AMBA 2 specification defines three buses/interfaces:
    Advanced High-performance Bus (AHB) - widely used on ARM7, ARM9 and ARM Cortex-M based designs
    Advanced System Bus (ASB)
    Advanced Peripheral Bus (APB2 or APB)

  
AMBA specification (First version) defines two buses/interfaces:
    Advanced System Bus (ASB)
    Advanced Peripheral Bus (APB)
    
    
The timing aspects and the voltage levels on the bus are not dictated by the specifications.

AXI Coherency Extensions (ACE and ACE-Lite)
ACE, defined as part of the AMBA 4 specification, extends AXI with additional signalling introducing system wide coherency.[4] This system coherency allows multiple processors to share memory and enables technology like ARM's big.LITTLE processing. The ACE-Lite protocol enables one-way aka IO coherency, for example a network interface that can read from the caches of a fully coherent ACE processor.

Advanced eXtensible Interface (AXI)
    AXI, the third generation of AMBA interface defined in the AMBA 3 specification, is targeted at high performance, high clock frequency system designs and includes features that make it suitable for high speed sub-micrometer interconnect:
    separate address/control and data phases
    support for unaligned data transfers using byte strobes
    burst based transactions with only start address issued
    issuing of multiple outstanding addresses with out of order responses
    easy addition of register stages to provide timing closure.
 
Advanced High-performance Bus (AHB)
AHB is a bus protocol introduced in Advanced Microcontroller Bus Architecture version 2 published by ARM Ltd company.

In addition to previous release, it has the following features:
    large bus-widths (64/128 bit).

A simple transaction on the AHB consists of an address phase and a subsequent data phase (without wait states: only two bus-cycles). Access to the target device is controlled through a MUX (non-tristate), thereby admitting bus-access to one bus-master at a time.

AHB-Lite is a subset of AHB formally defined in the AMBA 3 standard. This subset simplifies the design for a bus with a single master.

Advanced Peripheral Bus (APB)
APB is designed for low bandwidth control accesses, for example register interfaces on system peripherals. This bus has an address and data phase similar to AHB, but a much reduced, low complexity signal list (for example no bursts).