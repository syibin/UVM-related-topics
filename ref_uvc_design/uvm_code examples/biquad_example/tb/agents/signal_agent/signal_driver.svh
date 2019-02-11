//------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
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

timeunit 1ns;
timeprecision 1ps;

class signal_driver extends uvm_driver #(signal_seq_item);


`uvm_component_utils(signal_driver)

virtual signal_if SIGNAL;

extern function new(string name = "signal_driver", uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern task do_sweep;

endclass: signal_driver

function signal_driver::new(string name = "signal_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task signal_driver::run_phase(uvm_phase phase);
  signal_seq_item item;

  forever begin
    seq_item_port.get_next_item(item);
    do_sweep;
    seq_item_port.item_done();
  end
endtask: run_phase

task signal_driver::do_sweep;
  real ph;
  realtime period;
  real pi = 3.14159265;
  int sweep_array[39];
  int f;

  // Populate array with frequencies of interest:
  sweep_array = {100, 200, 400, 800, 1000, 1200, 1400, 1500, 1600, 1800, 2000,
                 2200, 2400, 2500, 2600, 2800, 3000, 3200, 3400, 3500, 3600, 3800,
                 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000,
                 13000, 14000, 15000, 16000, 17000, 18000, 19000, 20000};


  // Sweep frequency in 100 steps:
  foreach(sweep_array[i]) begin
    f = sweep_array[i];
    SIGNAL.f <= f;
    repeat(5) begin
      period = 1000000000/(f*360);
      for(int i = 0; i < 360; i++) begin
        ph = 1*($sin(i*pi/180));
        SIGNAL.x <= ph;
        #period;
      end
    end
  end
endtask: do_sweep
