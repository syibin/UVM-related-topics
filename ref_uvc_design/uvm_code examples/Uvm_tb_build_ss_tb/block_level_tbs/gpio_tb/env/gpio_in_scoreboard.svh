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
//
// Class Description:
//
//
class gpio_in_scoreboard extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(gpio_in_scoreboard)

// Register block
gpio_reg_block gpio_rb;

//------------------------------------------
// Data Members
//------------------------------------------
logic[31:0] GPI;
logic[31:0] GPI_pre;
logic[31:0] GPI_last;
logic[31:0] GPI_Q[3:0];
logic[31:0] INTS;
logic[31:0] INTE_reg;
logic[31:0] PTRIG_reg;
logic[31:0] CTRL_reg;
logic[31:0] ECLK_reg;
logic[31:0] NEC_reg;
int gpi_read_error;
int ints_read_error;
//------------------------------------------
// Covergroups
//------------------------------------------
covergroup gpi_cov;
  option.per_instance = 1;
  GPI_0: coverpoint GPI[0];
  GPI_1: coverpoint GPI[1];
  GPI_2: coverpoint GPI[2];
  GPI_3: coverpoint GPI[3];
  GPI_4: coverpoint GPI[4];
  GPI_5: coverpoint GPI[5];
  GPI_6: coverpoint GPI[6];
  GPI_7: coverpoint GPI[7];
  GPI_8: coverpoint GPI[8];
  GPI_9: coverpoint GPI[9];
  GPI_10: coverpoint GPI[10];
  GPI_11: coverpoint GPI[11];
  GPI_12: coverpoint GPI[12];
  GPI_13: coverpoint GPI[13];
  GPI_14: coverpoint GPI[14];
  GPI_15: coverpoint GPI[15];
  GPI_16: coverpoint GPI[16];
  GPI_17: coverpoint GPI[17];
  GPI_18: coverpoint GPI[18];
  GPI_19: coverpoint GPI[19];
  GPI_20: coverpoint GPI[20];
  GPI_21: coverpoint GPI[21];
  GPI_22: coverpoint GPI[22];
  GPI_23: coverpoint GPI[23];
  GPI_24: coverpoint GPI[24];
  GPI_25: coverpoint GPI[25];
  GPI_26: coverpoint GPI[26];
  GPI_27: coverpoint GPI[27];
  GPI_28: coverpoint GPI[28];
  GPI_29: coverpoint GPI[29];
  GPI_30: coverpoint GPI[30];
  GPI_31: coverpoint GPI[31];
  ECLK_0: coverpoint ECLK_reg[0];
  ECLK_1: coverpoint ECLK_reg[1];
  ECLK_2: coverpoint ECLK_reg[2];
  ECLK_3: coverpoint ECLK_reg[3];
  ECLK_4: coverpoint ECLK_reg[4];
  ECLK_5: coverpoint ECLK_reg[5];
  ECLK_6: coverpoint ECLK_reg[6];
  ECLK_7: coverpoint ECLK_reg[7];
  ECLK_8: coverpoint ECLK_reg[8];
  ECLK_9: coverpoint ECLK_reg[9];
  ECLK_10: coverpoint ECLK_reg[10];
  ECLK_11: coverpoint ECLK_reg[11];
  ECLK_12: coverpoint ECLK_reg[12];
  ECLK_13: coverpoint ECLK_reg[13];
  ECLK_14: coverpoint ECLK_reg[14];
  ECLK_15: coverpoint ECLK_reg[15];
  ECLK_16: coverpoint ECLK_reg[16];
  ECLK_17: coverpoint ECLK_reg[17];
  ECLK_18: coverpoint ECLK_reg[18];
  ECLK_19: coverpoint ECLK_reg[19];
  ECLK_20: coverpoint ECLK_reg[20];
  ECLK_21: coverpoint ECLK_reg[21];
  ECLK_22: coverpoint ECLK_reg[22];
  ECLK_23: coverpoint ECLK_reg[23];
  ECLK_24: coverpoint ECLK_reg[24];
  ECLK_25: coverpoint ECLK_reg[25];
  ECLK_26: coverpoint ECLK_reg[26];
  ECLK_27: coverpoint ECLK_reg[27];
  ECLK_28: coverpoint ECLK_reg[28];
  ECLK_29: coverpoint ECLK_reg[29];
  ECLK_30: coverpoint ECLK_reg[30];
  ECLK_31: coverpoint ECLK_reg[31];
  NEC_0: coverpoint NEC_reg[0];
  NEC_1: coverpoint NEC_reg[1];
  NEC_2: coverpoint NEC_reg[2];
  NEC_3: coverpoint NEC_reg[3];
  NEC_4: coverpoint NEC_reg[4];
  NEC_5: coverpoint NEC_reg[5];
  NEC_6: coverpoint NEC_reg[6];
  NEC_7: coverpoint NEC_reg[7];
  NEC_8: coverpoint NEC_reg[8];
  NEC_9: coverpoint NEC_reg[9];
  NEC_10: coverpoint NEC_reg[10];
  NEC_11: coverpoint NEC_reg[11];
  NEC_12: coverpoint NEC_reg[12];
  NEC_13: coverpoint NEC_reg[13];
  NEC_14: coverpoint NEC_reg[14];
  NEC_15: coverpoint NEC_reg[15];
  NEC_16: coverpoint NEC_reg[16];
  NEC_17: coverpoint NEC_reg[17];
  NEC_18: coverpoint NEC_reg[18];
  NEC_19: coverpoint NEC_reg[19];
  NEC_20: coverpoint NEC_reg[20];
  NEC_21: coverpoint NEC_reg[21];
  NEC_22: coverpoint NEC_reg[22];
  NEC_23: coverpoint NEC_reg[23];
  NEC_24: coverpoint NEC_reg[24];
  NEC_25: coverpoint NEC_reg[25];
  NEC_26: coverpoint NEC_reg[26];
  NEC_27: coverpoint NEC_reg[27];
  NEC_28: coverpoint NEC_reg[28];
  NEC_29: coverpoint NEC_reg[29];
  NEC_30: coverpoint NEC_reg[30];
  NEC_31: coverpoint NEC_reg[31];
  GPI_0_CROSS: cross GPI_0, ECLK_0, NEC_0;
  GPI_1_CROSS: cross GPI_1, ECLK_1, NEC_1;
  GPI_2_CROSS: cross GPI_2, ECLK_2, NEC_2;
  GPI_3_CROSS: cross GPI_3, ECLK_3, NEC_3;
  GPI_4_CROSS: cross GPI_4, ECLK_4, NEC_4;
  GPI_5_CROSS: cross GPI_5, ECLK_5, NEC_5;
  GPI_6_CROSS: cross GPI_6, ECLK_6, NEC_6;
  GPI_7_CROSS: cross GPI_7, ECLK_7, NEC_7;
  GPI_8_CROSS: cross GPI_8, ECLK_8, NEC_8;
  GPI_9_CROSS: cross GPI_9, ECLK_9, NEC_9;
  GPI_10_CROSS: cross GPI_10, ECLK_10, NEC_10;
  GPI_11_CROSS: cross GPI_11, ECLK_11, NEC_11;
  GPI_12_CROSS: cross GPI_12, ECLK_12, NEC_12;
  GPI_13_CROSS: cross GPI_13, ECLK_13, NEC_13;
  GPI_14_CROSS: cross GPI_14, ECLK_14, NEC_14;
  GPI_15_CROSS: cross GPI_15, ECLK_15, NEC_15;
  GPI_16_CROSS: cross GPI_16, ECLK_16, NEC_16;
  GPI_17_CROSS: cross GPI_17, ECLK_17, NEC_17;
  GPI_18_CROSS: cross GPI_18, ECLK_18, NEC_18;
  GPI_19_CROSS: cross GPI_19, ECLK_19, NEC_19;
  GPI_20_CROSS: cross GPI_20, ECLK_20, NEC_20;
  GPI_21_CROSS: cross GPI_21, ECLK_21, NEC_21;
  GPI_22_CROSS: cross GPI_22, ECLK_22, NEC_22;
  GPI_23_CROSS: cross GPI_23, ECLK_23, NEC_23;
  GPI_24_CROSS: cross GPI_24, ECLK_24, NEC_24;
  GPI_25_CROSS: cross GPI_25, ECLK_25, NEC_25;
  GPI_26_CROSS: cross GPI_26, ECLK_26, NEC_26;
  GPI_27_CROSS: cross GPI_27, ECLK_27, NEC_27;
  GPI_28_CROSS: cross GPI_28, ECLK_28, NEC_28;
  GPI_29_CROSS: cross GPI_29, ECLK_29, NEC_29;
  GPI_30_CROSS: cross GPI_30, ECLK_30, NEC_30;
  GPI_31_CROSS: cross GPI_31, ECLK_31, NEC_31;
endgroup: gpi_cov

covergroup ints_cov;
  option.per_instance = 1;
  INTS_0: coverpoint INTS[0];
  INTS_1: coverpoint INTS[1];
  INTS_2: coverpoint INTS[2];
  INTS_3: coverpoint INTS[3];
  INTS_4: coverpoint INTS[4];
  INTS_5: coverpoint INTS[5];
  INTS_6: coverpoint INTS[6];
  INTS_7: coverpoint INTS[7];
  INTS_8: coverpoint INTS[8];
  INTS_9: coverpoint INTS[9];
  INTS_10: coverpoint INTS[10];
  INTS_11: coverpoint INTS[11];
  INTS_12: coverpoint INTS[12];
  INTS_13: coverpoint INTS[13];
  INTS_14: coverpoint INTS[14];
  INTS_15: coverpoint INTS[15];
  INTS_16: coverpoint INTS[16];
  INTS_17: coverpoint INTS[17];
  INTS_18: coverpoint INTS[18];
  INTS_19: coverpoint INTS[19];
  INTS_20: coverpoint INTS[20];
  INTS_21: coverpoint INTS[21];
  INTS_22: coverpoint INTS[22];
  INTS_23: coverpoint INTS[23];
  INTS_24: coverpoint INTS[24];
  INTS_25: coverpoint INTS[25];
  INTS_26: coverpoint INTS[26];
  INTS_27: coverpoint INTS[27];
  INTS_28: coverpoint INTS[28];
  INTS_29: coverpoint INTS[29];
  INTS_30: coverpoint INTS[30];
  INTS_31: coverpoint INTS[31];
  INTE_0: coverpoint INTE_reg[0];
  INTE_1: coverpoint INTE_reg[1];
  INTE_2: coverpoint INTE_reg[2];
  INTE_3: coverpoint INTE_reg[3];
  INTE_4: coverpoint INTE_reg[4];
  INTE_5: coverpoint INTE_reg[5];
  INTE_6: coverpoint INTE_reg[6];
  INTE_7: coverpoint INTE_reg[7];
  INTE_8: coverpoint INTE_reg[8];
  INTE_9: coverpoint INTE_reg[9];
  INTE_10: coverpoint INTE_reg[10];
  INTE_11: coverpoint INTE_reg[11];
  INTE_12: coverpoint INTE_reg[12];
  INTE_13: coverpoint INTE_reg[13];
  INTE_14: coverpoint INTE_reg[14];
  INTE_15: coverpoint INTE_reg[15];
  INTE_16: coverpoint INTE_reg[16];
  INTE_17: coverpoint INTE_reg[17];
  INTE_18: coverpoint INTE_reg[18];
  INTE_19: coverpoint INTE_reg[19];
  INTE_20: coverpoint INTE_reg[20];
  INTE_21: coverpoint INTE_reg[21];
  INTE_22: coverpoint INTE_reg[22];
  INTE_23: coverpoint INTE_reg[23];
  INTE_24: coverpoint INTE_reg[24];
  INTE_25: coverpoint INTE_reg[25];
  INTE_26: coverpoint INTE_reg[26];
  INTE_27: coverpoint INTE_reg[27];
  INTE_28: coverpoint INTE_reg[28];
  INTE_29: coverpoint INTE_reg[29];
  INTE_30: coverpoint INTE_reg[30];
  INTE_31: coverpoint INTE_reg[31];
  PTRIG_0: coverpoint PTRIG_reg[0];
  PTRIG_1: coverpoint PTRIG_reg[1];
  PTRIG_2: coverpoint PTRIG_reg[2];
  PTRIG_3: coverpoint PTRIG_reg[3];
  PTRIG_4: coverpoint PTRIG_reg[4];
  PTRIG_5: coverpoint PTRIG_reg[5];
  PTRIG_6: coverpoint PTRIG_reg[6];
  PTRIG_7: coverpoint PTRIG_reg[7];
  PTRIG_8: coverpoint PTRIG_reg[8];
  PTRIG_9: coverpoint PTRIG_reg[9];
  PTRIG_10: coverpoint PTRIG_reg[10];
  PTRIG_11: coverpoint PTRIG_reg[11];
  PTRIG_12: coverpoint PTRIG_reg[12];
  PTRIG_13: coverpoint PTRIG_reg[13];
  PTRIG_14: coverpoint PTRIG_reg[14];
  PTRIG_15: coverpoint PTRIG_reg[15];
  PTRIG_16: coverpoint PTRIG_reg[16];
  PTRIG_17: coverpoint PTRIG_reg[17];
  PTRIG_18: coverpoint PTRIG_reg[18];
  PTRIG_19: coverpoint PTRIG_reg[19];
  PTRIG_20: coverpoint PTRIG_reg[20];
  PTRIG_21: coverpoint PTRIG_reg[21];
  PTRIG_22: coverpoint PTRIG_reg[22];
  PTRIG_23: coverpoint PTRIG_reg[23];
  PTRIG_24: coverpoint PTRIG_reg[24];
  PTRIG_25: coverpoint PTRIG_reg[25];
  PTRIG_26: coverpoint PTRIG_reg[26];
  PTRIG_27: coverpoint PTRIG_reg[27];
  PTRIG_28: coverpoint PTRIG_reg[28];
  PTRIG_29: coverpoint PTRIG_reg[29];
  PTRIG_30: coverpoint PTRIG_reg[30];
  PTRIG_31: coverpoint PTRIG_reg[31];
  INTS_0_CROSS: cross INTS_0, INTE_0, PTRIG_0;
  INTS_1_CROSS: cross INTS_1, INTE_1, PTRIG_1;
  INTS_2_CROSS: cross INTS_2, INTE_2, PTRIG_2;
  INTS_3_CROSS: cross INTS_3, INTE_3, PTRIG_3;
  INTS_4_CROSS: cross INTS_4, INTE_4, PTRIG_4;
  INTS_5_CROSS: cross INTS_5, INTE_5, PTRIG_5;
  INTS_6_CROSS: cross INTS_6, INTE_6, PTRIG_6;
  INTS_7_CROSS: cross INTS_7, INTE_7, PTRIG_7;
  INTS_8_CROSS: cross INTS_8, INTE_8, PTRIG_8;
  INTS_9_CROSS: cross INTS_9, INTE_9, PTRIG_9;
  INTS_10_CROSS: cross INTS_10, INTE_10, PTRIG_10;
  INTS_11_CROSS: cross INTS_11, INTE_11, PTRIG_11;
  INTS_12_CROSS: cross INTS_12, INTE_12, PTRIG_12;
  INTS_13_CROSS: cross INTS_13, INTE_13, PTRIG_13;
  INTS_14_CROSS: cross INTS_14, INTE_14, PTRIG_14;
  INTS_15_CROSS: cross INTS_15, INTE_15, PTRIG_15;
  INTS_16_CROSS: cross INTS_16, INTE_16, PTRIG_16;
  INTS_17_CROSS: cross INTS_17, INTE_17, PTRIG_17;
  INTS_18_CROSS: cross INTS_18, INTE_18, PTRIG_18;
  INTS_19_CROSS: cross INTS_19, INTE_19, PTRIG_19;
  INTS_20_CROSS: cross INTS_20, INTE_20, PTRIG_20;
  INTS_21_CROSS: cross INTS_21, INTE_21, PTRIG_21;
  INTS_22_CROSS: cross INTS_22, INTE_22, PTRIG_22;
  INTS_23_CROSS: cross INTS_23, INTE_23, PTRIG_23;
  INTS_24_CROSS: cross INTS_24, INTE_24, PTRIG_24;
  INTS_25_CROSS: cross INTS_25, INTE_25, PTRIG_25;
  INTS_26_CROSS: cross INTS_26, INTE_26, PTRIG_26;
  INTS_27_CROSS: cross INTS_27, INTE_27, PTRIG_27;
  INTS_28_CROSS: cross INTS_28, INTE_28, PTRIG_28;
  INTS_29_CROSS: cross INTS_29, INTE_29, PTRIG_29;
  INTS_30_CROSS: cross INTS_30, INTE_30, PTRIG_30;
  INTS_31_CROSS: cross INTS_31, INTE_31, PTRIG_31;
endgroup: ints_cov
//------------------------------------------
// Sub Components
//------------------------------------------
uvm_tlm_analysis_fifo #(gpio_seq_item) gpi_int;
uvm_tlm_analysis_fifo #(gpio_seq_item) gpi_ext;
//------------------------------------------
// Methods
//------------------------------------------
extern task handle_gpi_int;
extern task handle_gpi_ext;
extern task interrupt_monitor;
extern function void check_gpi(logic[31:0] gpi);
extern function void check_ints(logic[31:0] gpi);
// Standard UVM Methods:
extern function new(string name = "gpio_in_scoreboard", uvm_component parent = null);
// Only required if you have sub-components
extern function void build_phase(uvm_phase phase);
// Only required if the class generates stimulus or is an analysis component
extern task run_phase(uvm_phase phase);
// Only required if you need to report:
extern function void report_phase(uvm_phase phase);

endclass: gpio_in_scoreboard

function gpio_in_scoreboard::new(string name = "gpio_in_scoreboard", uvm_component parent = null);
  super.new(name, parent);
  gpi_cov = new;
  ints_cov = new;
endfunction

// Only required if you have sub-components
function void gpio_in_scoreboard::build_phase(uvm_phase phase);
  gpi_int = new("gpi_int", this);
  gpi_ext = new("gpi_ext", this);
  GPI = 0;
  GPI_last = 0;
  INTS = 0;
  INTE_reg = 0;
  PTRIG_reg = 0;
  CTRL_reg = 0;
  ECLK_reg = 0;
  NEC_reg = 0;
  gpi_read_error = 0;
  ints_read_error = 0;
endfunction: build_phase

// Only required if the class generates stimulus or is an analysis component
task gpio_in_scoreboard::run_phase(uvm_phase phase);

  fork
    handle_gpi_int;
    handle_gpi_ext;
    interrupt_monitor;
  join

endtask: run_phase

// Only required if you need to report:
function void gpio_in_scoreboard::report_phase(uvm_phase phase);
  if((gpi_read_error == 0) && (ints_read_error == 0)) begin
    `uvm_info("GPIO_IN_SB", "Test Passed - No GPI or interrupt read errors", UVM_LOW)
    return;
  end
  if(gpi_read_error > 0) begin
    `uvm_error("GPIO_IN_SB", $sformatf("Test Failed - with %0d GPI read errors", gpi_read_error))
  end
  if(ints_read_error > 0) begin
    `uvm_error("GPIO_IN_SB", $sformatf("Test Failed - with %0d GPIO interrupt state read errors", ints_read_error))
  end


endfunction: report_phase

// Handling the GPIs sampled by the internal clock
//
// Only update the GPI bit if it is enabled for GPI internal sampling
task gpio_in_scoreboard::handle_gpi_int;
  gpio_seq_item gpi;

  forever begin
    gpi_int.get(gpi);
    // Pipeline depth of 4 with sampling and synchronisation to the read data path
    GPI_pre = GPI_Q[3];
    GPI_Q[3] = GPI_Q[2];
    GPI_Q[2] = GPI_Q[1];
    GPI_Q[1] = GPI_Q[0];
    GPI_Q[0] = gpi.gpio;
    foreach(GPI_pre[i]) begin
      if(ECLK_reg[i] == 0) begin
        GPI[i] = GPI_pre[i];
//        $display("%t ECLK_reg[i] %h, GPI %h", $time, ECLK_reg, GPI);
      end
    end
  end
endtask: handle_gpi_int

// Handling the GPIs sampled by the external clock
//
// Only update the GPI bit if it is enabled for GPI external sampling
task gpio_in_scoreboard::handle_gpi_ext;
  gpio_seq_item gpi;

  forever begin
    gpi_ext.get(gpi);
//    $display("%t gpi.GPIO_ext %0h", $time, gpi.gpio);
    foreach(gpi.gpio[i]) begin
      if(ECLK_reg[i] == 1) begin
        if(((NEC_reg[i] == 1) && (gpi.ext_clk == 0)) || ((NEC_reg[i] == 0) && (gpi.ext_clk == 1))) begin
          GPI[i] = gpi.gpio[i];
//          $display("GPI after ext_clk update is %0h with ECLK_reg %0h, NEC_reg %0h", GPI, ECLK_reg, NEC_reg);
        end
      end
    end
  end
endtask: handle_gpi_ext

//
// Monitor the GPI vector to keep the expect interrupt status up to date
//
task gpio_in_scoreboard::interrupt_monitor;

  forever begin
    @(GPI);
//    $display("%t GPI has just changed to %0h GPI_last is %0h", $time, GPI, GPI_last);
    if(CTRL_reg[0] == 1) begin
      foreach(GPI[i]) begin
        if(INTE_reg[i] == 1) begin
          if(PTRIG_reg[i] == 1) begin // +ve edge triggered
            if((GPI[i] == 1) && (GPI_last[i] == 0)) begin
              INTS[i] = 1;
            end
          end
          else if((GPI[i] == 0) && (GPI_last[i] == 1)) begin
            INTS[i] = 1;
          end
        end
      end
    end
//    $display("%t INTS = %0h", $time, INTS);
    GPI_last = GPI;
  end

endtask: interrupt_monitor

function void gpio_in_scoreboard::check_gpi(logic[31:0] gpi);
  if(gpi != GPI) begin
    `uvm_error("GPI_Read_Check", $sformatf("GPI Read back error: Expected %0h, Actual %0h", GPI, gpi))
    gpi_read_error++;
    return;
  end
  gpi_cov.sample();
endfunction: check_gpi

function void gpio_in_scoreboard::check_ints(logic[31:0] gpi);
  if(CTRL_reg[0] == 1) begin
    if(gpi != INTS) begin
      `uvm_error("GPI_Read_Check", $sformatf("INTS Read back error: Expected %0h, Actual %0h", INTS, gpi))
      ints_read_error++;
      return;
    end
    ints_cov.sample();
  end
endfunction: check_ints
