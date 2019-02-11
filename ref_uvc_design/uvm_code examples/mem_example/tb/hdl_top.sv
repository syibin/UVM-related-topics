//------------------------------------------------------------
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
//------------------------------------------------------------

module hdl_top;
  // pragma attribute hdl_top partition_module_xrtl

  `include "timescale.v"

  // Clock and Resetn:
  logic HCLK;
  logic HRESETn;

  // Instantiate the pin interfaces
  ahb_if AHB(HCLK, HRESETn);

  // Instantiate the BFM interfaces
  ahb_monitor_bfm AHB_mon_bfm(
   .HCLK    (AHB.HCLK),
   .HRESETn (AHB.HRESETn),
   .HADDR   (AHB.HADDR),
   .HTRANS  (AHB.HTRANS),
   .HWRITE  (AHB.HWRITE),
   .HSIZE   (AHB.HSIZE),
   .HBURST  (AHB.HBURST),
   .HPROT   (AHB.HPROT),
   .HWDATA  (AHB.HWDATA),
   .HRDATA  (AHB.HRDATA),
   .HRESP   (AHB.HRESP),
   .HREADY  (AHB.HREADY),
   .HSEL    (AHB.HSEL)
);
  ahb_driver_bfm AHB_drv_bfm(
   .HCLK    (AHB.HCLK),
   .HRESETn (AHB.HRESETn),
   .HADDR   (AHB.HADDR),
   .HTRANS  (AHB.HTRANS),
   .HWRITE  (AHB.HWRITE),
   .HSIZE   (AHB.HSIZE),
   .HBURST  (AHB.HBURST),
   .HPROT   (AHB.HPROT),
   .HWDATA  (AHB.HWDATA),
   .HRDATA  (AHB.HRDATA),
   .HRESP   (AHB.HRESP),
   .HREADY  (AHB.HREADY),
   .HSEL    (AHB.HSEL)
);

  // DUT instantiation 
  mem_ss DUT(.HCLK          (HCLK       ),
             .HRESETn       (HRESETn    ),
             .HADDR         (AHB.HADDR  ),
             .HWRITE        (AHB.HWRITE ),
             .HTRANS        (AHB.HTRANS ),
             .HSIZE         (AHB.HSIZE  ),
             .HBURST        (AHB.HBURST ),
             .HPROT         (AHB.HPROT  ),
             .HWDATA        (AHB.HWDATA ),
             .HSEL          (AHB.HSEL   ),
             .HREADY        (AHB.HREADY ),
             .HRDATA        (AHB.HRDATA ),
             .HRESP         (AHB.HRESP  )
             );

  // UVN initial block:
  // Virtual interface wrapping
  initial begin //tbx vif_binding_block
    import uvm_pkg::uvm_config_db;
    uvm_config_db #(virtual ahb_monitor_bfm)::set(null,"uvm_test_top","AHB_mon_bfm",AHB_mon_bfm);
    uvm_config_db #(virtual ahb_driver_bfm)::set(null,"uvm_test_top","AHB_drv_bfm",AHB_drv_bfm);
  end

  // Clock & reset initial block
  initial begin
    HCLK = 0;
    HRESETn = 0;
    repeat (8) begin
      #10ns HCLK = ~HCLK;
    end
    HRESETn = 1;
    forever begin
      #10ns HCLK = ~HCLK;
    end
  end

endmodule




