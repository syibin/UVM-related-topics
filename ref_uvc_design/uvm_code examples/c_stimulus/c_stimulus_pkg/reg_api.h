//------------------------------------------------------------
//   Copyright 2012 Mentor Graphics Corporation
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
// reg_api.h
//
#include "sv_dpi.h"
//
// function: reg_read
//
// Returns data from register address
//
int reg_read(int address);

//
// function: reg_write
//
// Writes data to register address
//
void reg_write(int address, int data);

//
// function: register_thread
//
// Called to register a non-default c thread with
// the c_stimulus_pkg context
//
void register_thread();

//
// function: hw_wait_1ns
//
// Hardware delay in terms of 1ns increments
//
void hw_wait_1ns(int n);
