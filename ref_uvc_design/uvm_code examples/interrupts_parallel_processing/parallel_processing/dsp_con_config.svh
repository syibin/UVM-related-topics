//
//------------------------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------

class dsp_con_config extends uvm_object;

`uvm_object_utils(dsp_con_config)

virtual dsp_con_driver_bfm drv_bfm;
  
interrupt_util INT[4];

bit   wait_reset_active = 0;
event reset_deassertion;
  
function new(string name = "dsp_con_config");
  super.new(name);
endfunction

//
// Convenience methods:
//
task wait_for_reset;
  if (!wait_reset_active) begin
    wait_reset_active = 1;
    drv_bfm.wait_for_reset();
    -> reset_deassertion;
    wait_reset_active = 0;
  end else
    @(reset_deassertion);
endtask: wait_for_reset

task wait_for_clock;
  drv_bfm.wait_for_clock();
endtask: wait_for_clock

task wait_for_irq0;
  INT[0].wait_for_interrupt();
endtask: wait_for_irq0

task wait_for_irq1;
  INT[1].wait_for_interrupt();
endtask: wait_for_irq1

task wait_for_irq2;
  INT[2].wait_for_interrupt();
endtask: wait_for_irq2

task wait_for_irq3;
  INT[3].wait_for_interrupt();
endtask: wait_for_irq3


endclass: dsp_con_config
