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


int send_10_test_routine() {
  int divisor = 2;
  int slave_select = 1;
  int control = 0x2c30;
  int i = 0;
  int data_0 = 0xDEADBEEF;
  int data_1 = 0xBAADCAFE;
  int status;
  int data;

  register_thread(); // To register this thread with the c_stimulus_pkg DPI context

  // Setup the SPI Master
  reg_write(DIVIDER, divisor);
  reg_write(CTRL, control);
  reg_write(SS, slave_select);
  // Send 10 characters
  while(i < 10) {
    reg_write(TX0, data_0);
    reg_write(TX1, data_1);
    reg_write(CTRL, (control + 0x100));
    status = reg_read(CTRL);
    while((status & 0x100) == 0x100) {
      status = reg_read(CTRL);
    }
    i++;
    data_0++;
    data_1++;
  }

  return 0;

}





