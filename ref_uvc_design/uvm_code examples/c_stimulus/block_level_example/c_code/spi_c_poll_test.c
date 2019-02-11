//------------------------------------------------------------
//   Copyright 2012-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// Version 1.0 - First release: 29th June 2012
//

#include "spi_regs.h" // Defines for register offsets etc
#include "reg_api.h"  // DPI Register Hardware access layer API


int spi_c_poll_test_routine() {
  int no_chars = 1;
  int format = 0;
  int divisor = 2;
  int slave_select = 1;
  int control = 0;
  int i = 0;
  int data_0 = 0x12345678;
  int data_1 = 0x87654321;
  int data_2 = 0x90901212;
  int data_3 = 0x5a6b7c8d;
  int status;
  int data;

  register_thread(); // To register this thread with the c_stimulus_pkg DPI context

  reg_write(DIVIDER, divisor);

  while(i < 10) {
    control = no_chars + (format << 9) + 0x3000;
    reg_write(CTRL, control);
    reg_write(SS, slave_select);
    reg_write(TX0, data_0);
    reg_write(TX1, data_1);
    control = control + 0x100;
    reg_write(CTRL, control);
    status = reg_read(CTRL);
    // Poll the GO_BUSY bit in the control register:
    while((status & 0x100) == 0x100) {
      status = reg_read(CTRL);
      data = reg_read(SS);
    }
    // Transfer over - deselect slaves
    reg_write(SS, 0xFF);
    // Dump the data buffer
    data = reg_read(TX0);
    data = reg_read(TX1);
    // Set up for the next iteration:
    no_chars = no_chars++;
    format = format++;
    if(format == 8) {
      format = 0;
    }
    slave_select = slave_select << 1;
    if(slave_select = 0x100) {
      slave_select = 1;
    }

    i++;

  }

  return 0;

}





