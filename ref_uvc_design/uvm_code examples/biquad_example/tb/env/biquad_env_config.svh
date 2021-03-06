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

class biquad_env_config extends uvm_object;

`uvm_object_utils(biquad_env_config)

apb_agent_config apb_cfg;
signal_agent_config signal_cfg;

biquad_reg_block rm;

filter_mode_e mode = LP;

function new(string name = "biquad_env_config");
  super.new(name);
endfunction

endclass: biquad_env_config