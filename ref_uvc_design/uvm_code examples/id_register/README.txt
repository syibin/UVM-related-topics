
====================
UVM Register Example
====================

--------------------------------------
Quirky Register Example - ID Register.
--------------------------------------
Version 2 - February 9, 2018


This example shows how to build an ID Register. An
ID Register is a register which returns the next value from
a list each time it is read. When it reaches the end of the
list, it returns the first item in the list.

For example, an ID Register with the "values" (10, 20, 30)
would return the following data:

 id_register.read() ==> 10
 id_register.read() ==> 20
 id_register.read() ==> 30
 id_register.read() ==> 10
 id_register.read() ==> 20
 ...

An ID Register can be used to have a small width register
(8 bits) return a long (64 bit) value. In this case the register
would be read 8 times to get the entire "id value".

The name ID register comes from the usage: the long sequence
of values is used as a device ID. Each device or block in the
system has a unique ID, and a well-known location - like
address 0.

To run the example - type make

