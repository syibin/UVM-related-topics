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
package tb_params_pkg;

import sfr_agent_pkg::*;

class SFR;

  localparam sfr_addr_width = 16;
  localparam sfr_data_width = 32;

endclass

typedef sfr_config_object #(SFR::sfr_addr_width, SFR::sfr_data_width) SFR_cfg_t;
typedef sfr_agent #(SFR::sfr_addr_width, SFR::sfr_data_width) SFR_agent_t;

typedef virtual sfr_monitor_bfm #(SFR::sfr_addr_width, SFR::sfr_data_width) SFR_monitor_bfm_t;
typedef virtual sfr_master_bfm #(SFR::sfr_addr_width, SFR::sfr_data_width) SFR_master_bfm_t;

endpackage
