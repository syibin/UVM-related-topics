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

#include "reg_api.h"

int reg_read(int address) {
  int data;

  c_reg_read(address, &data);
  return data;
}

void reg_write(int address, int data) {
  c_reg_write(address, data);
}

void hw_wait_1ns(int n) {
  wait_1ns(n);
}

void register_thread() {
    svSetScope(svGetScopeFromName("c_stimulus_pkg"));
}
