//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
package messaging_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class agent_green extends uvm_component;

`uvm_component_utils(agent_green)

function new(string name = "agent_green", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  `uvm_info("green_id", "Starting run phase", UVM_HIGH)
  #100ns;
  `uvm_warning("green_id", "Nothing much has happened")
  #100ns;
  `uvm_error("green_id", "No activity")
  #100ns;
  `uvm_info("green_id", "Finishing run phase", UVM_HIGH)
endtask

endclass

class agent_blue extends uvm_component;

`uvm_component_utils(agent_blue)

function new(string name = "agent_blue", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  `uvm_info("blue_id", "Starting run phase", UVM_MEDIUM)
  #100ns;
  `uvm_error("blue_id", "Nothing much has happened")
  #100ns;
  `uvm_warning("blue_id", "No activity")
  #100ns;
  `uvm_info("blue_id", "Finishing run phase", UVM_MEDIUM)
endtask

endclass

class agent_red extends uvm_component;

`uvm_component_utils(agent_red)

function new(string name = "agent_red", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  `uvm_info("red_id", "Starting run phase", UVM_LOW)
  #100ns;
  `uvm_error("red_id", "Nothing much has happened")
  #100ns;
  `uvm_info("red_id", "No activity", UVM_LOW)
  #100ns;
  `uvm_fatal("red_id", "Something went very wrong!")
endtask

endclass

class message_env extends uvm_component;
`uvm_component_utils(message_env)

function new(string name = "message_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

agent_red red;
agent_blue blue;
agent_green green;

function void build_phase(uvm_phase phase);
  red = agent_red::type_id::create("red", this);
  blue = agent_blue::type_id::create("blue", this);
  green = agent_green::type_id::create("green", this);
endfunction

endclass

class message_mod extends uvm_report_catcher;
`uvm_object_utils(message_mod)

function new(string name = "message_mod");
  super.new(name);
endfunction

function action_e catch();
  string message;
  string id;

  if((get_id() == "green_id") & (get_severity() == UVM_INFO)) begin
    set_message("Message modified");
  end
  else if((get_id() == "green_id") & (get_severity() == UVM_ERROR)) begin
    set_severity(UVM_WARNING);
    set_message("This warning was an error");
  end

  return THROW;

endfunction

endclass

class fatal_mod extends uvm_report_catcher;
`uvm_object_utils(fatal_mod)

function new(string name = "fatal_mod");
  super.new(name);
endfunction

function action_e catch();
  string message;
  string id;

  if((get_id() == "red_id") & (get_severity() == UVM_FATAL)) begin
    set_message("Something went very wrong but was demoted to error");
    set_severity(UVM_ERROR);
  end
  return THROW;

endfunction

endclass

class message_test extends uvm_component;
`uvm_component_utils(message_test)

function new(string name = "message_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

message_env env;
message_mod mess_mod;
fatal_mod fatal_demoter;

function void build_phase(uvm_phase phase);
  env = message_env::type_id::create("env", this);
  mess_mod = new("mess_mod");
  fatal_demoter = new("fatal_demoter");
  uvm_report_cb::add(env.green, mess_mod);
  uvm_report_cb::add(null, fatal_demoter);

endfunction


task run_phase(uvm_phase phase);

  // Some commands to set up actions and redirection:
  UVM_FILE green_log_fh = $fopen("green_messages.log");
  env.green.set_report_id_action("green_id", (UVM_DISPLAY | UVM_LOG));
  env.green.set_report_id_file("green_id", green_log_fh);


  phase.raise_objection(this);
  #1us;
  phase.drop_objection(this);

  $fclose(green_log_fh);
endtask

function void report_phase(uvm_phase phase);
  uvm_report_server rs;

  `uvm_info("test_id", "reporting", UVM_NONE)

  rs = uvm_report_server::get_server();

  if((rs.get_id_count("blue_id") == 4) && ((rs.get_id_count("green_id") == 2) || (rs.get_id_count("green_id") == 4)) &&
     (rs.get_id_count("red_id") == 4) && (rs.get_id_count("test_id") == 1) &&
     (rs.get_severity_count(UVM_ERROR) == 3)) begin
    `uvm_info("** UVM TEST PASSED **", "Message id counts correct", UVM_MEDIUM)
  end
  else begin
    `uvm_error("!! UVM TEST FAILED !!", "Message id counts incorrect")
  end
endfunction

endclass

endpackage

module top;

import uvm_pkg::*;
import messaging_pkg::*;

initial begin
  run_test("message_test");
end

endmodule


