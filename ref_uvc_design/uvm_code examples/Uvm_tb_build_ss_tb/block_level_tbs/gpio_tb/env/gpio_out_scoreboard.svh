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
class gpio_out_scoreboard extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(gpio_out_scoreboard)

// Register block
gpio_reg_block gpio_rb;

// Typedefs needed for the GPO checking
typedef enum {AUX_REG, GPO_REG, AUX_SAMPLE} gpo_change_e;
typedef struct {gpo_change_e src; logic[31:0] value;} gpo_q_t;
//------------------------------------------
// Analysis FIFOs
//------------------------------------------
uvm_tlm_analysis_fifo #(gpio_seq_item) GPO_fifo;
uvm_tlm_analysis_fifo #(gpio_seq_item) GPOE_fifo;
uvm_tlm_analysis_fifo #(gpio_seq_item) AUX_fifo;
//------------------------------------------
// Data Members
//------------------------------------------
logic[31:0] GPO_reg;
logic[31:0] GPOE_reg;
logic[31:0] AUX_reg;
logic[31:0] AUX_in_current;
int gpoe_error_count;
int gpo_error_count;
int aux_error_count;
int gpo_count;
int gpoe_count;
logic[31:0] gpoe_q[$]; // Last write to the GPOE reg - generally one deep
gpo_q_t gpo_q[$]; // GPO changes queue
logic[31:0] aux_q[$]; // AUX sample changes queue
//------------------------------------------
// Covergroups
//------------------------------------------
covergroup gpoe_cov;
  option.per_instance = 1;
  coverpoint GPOE_reg[0];
  coverpoint GPOE_reg[1];
  coverpoint GPOE_reg[2];
  coverpoint GPOE_reg[3];
  coverpoint GPOE_reg[4];
  coverpoint GPOE_reg[5];
  coverpoint GPOE_reg[6];
  coverpoint GPOE_reg[7];
  coverpoint GPOE_reg[8];
  coverpoint GPOE_reg[9];
  coverpoint GPOE_reg[10];
  coverpoint GPOE_reg[11];
  coverpoint GPOE_reg[12];
  coverpoint GPOE_reg[13];
  coverpoint GPOE_reg[14];
  coverpoint GPOE_reg[15];
  coverpoint GPOE_reg[16];
  coverpoint GPOE_reg[17];
  coverpoint GPOE_reg[18];
  coverpoint GPOE_reg[19];
  coverpoint GPOE_reg[20];
  coverpoint GPOE_reg[21];
  coverpoint GPOE_reg[22];
  coverpoint GPOE_reg[23];
  coverpoint GPOE_reg[24];
  coverpoint GPOE_reg[25];
  coverpoint GPOE_reg[26];
  coverpoint GPOE_reg[27];
  coverpoint GPOE_reg[28];
  coverpoint GPOE_reg[29];
  coverpoint GPOE_reg[30];
  coverpoint GPOE_reg[31];
endgroup: gpoe_cov

covergroup gpo_cov;
  option.per_instance = 1;
  GPO_0: coverpoint GPO_reg[0];
  GPO_1: coverpoint GPO_reg[1];
  GPO_2: coverpoint GPO_reg[2];
  GPO_3: coverpoint GPO_reg[3];
  GPO_4: coverpoint GPO_reg[4];
  GPO_5: coverpoint GPO_reg[5];
  GPO_6: coverpoint GPO_reg[6];
  GPO_7: coverpoint GPO_reg[7];
  GPO_8: coverpoint GPO_reg[8];
  GPO_9: coverpoint GPO_reg[9];
  GPO_10: coverpoint GPO_reg[10];
  GPO_11: coverpoint GPO_reg[11];
  GPO_12: coverpoint GPO_reg[12];
  GPO_13: coverpoint GPO_reg[13];
  GPO_14: coverpoint GPO_reg[14];
  GPO_15: coverpoint GPO_reg[15];
  GPO_16: coverpoint GPO_reg[16];
  GPO_17: coverpoint GPO_reg[17];
  GPO_18: coverpoint GPO_reg[18];
  GPO_19: coverpoint GPO_reg[19];
  GPO_20: coverpoint GPO_reg[20];
  GPO_21: coverpoint GPO_reg[21];
  GPO_22: coverpoint GPO_reg[22];
  GPO_23: coverpoint GPO_reg[23];
  GPO_24: coverpoint GPO_reg[24];
  GPO_25: coverpoint GPO_reg[25];
  GPO_26: coverpoint GPO_reg[26];
  GPO_27: coverpoint GPO_reg[27];
  GPO_28: coverpoint GPO_reg[28];
  GPO_29: coverpoint GPO_reg[29];
  GPO_30: coverpoint GPO_reg[30];
  GPO_31: coverpoint GPO_reg[31];
  AUX_0: coverpoint AUX_reg[0];
  AUX_1: coverpoint AUX_reg[1];
  AUX_2: coverpoint AUX_reg[2];
  AUX_3: coverpoint AUX_reg[3];
  AUX_4: coverpoint AUX_reg[4];
  AUX_5: coverpoint AUX_reg[5];
  AUX_6: coverpoint AUX_reg[6];
  AUX_7: coverpoint AUX_reg[7];
  AUX_8: coverpoint AUX_reg[8];
  AUX_9: coverpoint AUX_reg[9];
  AUX_10: coverpoint AUX_reg[10];
  AUX_11: coverpoint AUX_reg[11];
  AUX_12: coverpoint AUX_reg[12];
  AUX_13: coverpoint AUX_reg[13];
  AUX_14: coverpoint AUX_reg[14];
  AUX_15: coverpoint AUX_reg[15];
  AUX_16: coverpoint AUX_reg[16];
  AUX_17: coverpoint AUX_reg[17];
  AUX_18: coverpoint AUX_reg[18];
  AUX_19: coverpoint AUX_reg[19];
  AUX_20: coverpoint AUX_reg[20];
  AUX_21: coverpoint AUX_reg[21];
  AUX_22: coverpoint AUX_reg[22];
  AUX_23: coverpoint AUX_reg[23];
  AUX_24: coverpoint AUX_reg[24];
  AUX_25: coverpoint AUX_reg[25];
  AUX_26: coverpoint AUX_reg[26];
  AUX_27: coverpoint AUX_reg[27];
  AUX_28: coverpoint AUX_reg[28];
  AUX_29: coverpoint AUX_reg[29];
  AUX_30: coverpoint AUX_reg[30];
  AUX_31: coverpoint AUX_reg[31];
  AUX_in_0: coverpoint AUX_in_current[0];
  AUX_in_1: coverpoint AUX_in_current[1];
  AUX_in_2: coverpoint AUX_in_current[2];
  AUX_in_3: coverpoint AUX_in_current[3];
  AUX_in_4: coverpoint AUX_in_current[4];
  AUX_in_5: coverpoint AUX_in_current[5];
  AUX_in_6: coverpoint AUX_in_current[6];
  AUX_in_7: coverpoint AUX_in_current[7];
  AUX_in_8: coverpoint AUX_in_current[8];
  AUX_in_9: coverpoint AUX_in_current[9];
  AUX_in_10: coverpoint AUX_in_current[10];
  AUX_in_11: coverpoint AUX_in_current[11];
  AUX_in_12: coverpoint AUX_in_current[12];
  AUX_in_13: coverpoint AUX_in_current[13];
  AUX_in_14: coverpoint AUX_in_current[14];
  AUX_in_15: coverpoint AUX_in_current[15];
  AUX_in_16: coverpoint AUX_in_current[16];
  AUX_in_17: coverpoint AUX_in_current[17];
  AUX_in_18: coverpoint AUX_in_current[18];
  AUX_in_19: coverpoint AUX_in_current[19];
  AUX_in_20: coverpoint AUX_in_current[20];
  AUX_in_21: coverpoint AUX_in_current[21];
  AUX_in_22: coverpoint AUX_in_current[22];
  AUX_in_23: coverpoint AUX_in_current[23];
  AUX_in_24: coverpoint AUX_in_current[24];
  AUX_in_25: coverpoint AUX_in_current[25];
  AUX_in_26: coverpoint AUX_in_current[26];
  AUX_in_27: coverpoint AUX_in_current[27];
  AUX_in_28: coverpoint AUX_in_current[28];
  AUX_in_29: coverpoint AUX_in_current[29];
  AUX_in_30: coverpoint AUX_in_current[30];
  AUX_in_31: coverpoint AUX_in_current[31];
  GPO_0_CROSS: cross GPO_0, AUX_0, AUX_in_0;
  GPO_1_CROSS: cross GPO_1, AUX_1, AUX_in_1;
  GPO_2_CROSS: cross GPO_2, AUX_2, AUX_in_2;
  GPO_3_CROSS: cross GPO_3, AUX_3, AUX_in_3;
  GPO_4_CROSS: cross GPO_4, AUX_4, AUX_in_4;
  GPO_5_CROSS: cross GPO_5, AUX_5, AUX_in_5;
  GPO_6_CROSS: cross GPO_6, AUX_6, AUX_in_6;
  GPO_7_CROSS: cross GPO_7, AUX_7, AUX_in_7;
  GPO_8_CROSS: cross GPO_8, AUX_8, AUX_in_8;
  GPO_9_CROSS: cross GPO_9, AUX_9, AUX_in_9;
  GPO_10_CROSS: cross GPO_10, AUX_10, AUX_in_10;
  GPO_11_CROSS: cross GPO_11, AUX_11, AUX_in_11;
  GPO_12_CROSS: cross GPO_12, AUX_12, AUX_in_12;
  GPO_13_CROSS: cross GPO_13, AUX_13, AUX_in_13;
  GPO_14_CROSS: cross GPO_14, AUX_14, AUX_in_14;
  GPO_15_CROSS: cross GPO_15, AUX_15, AUX_in_15;
  GPO_16_CROSS: cross GPO_16, AUX_16, AUX_in_16;
  GPO_17_CROSS: cross GPO_17, AUX_17, AUX_in_17;
  GPO_18_CROSS: cross GPO_18, AUX_18, AUX_in_18;
  GPO_19_CROSS: cross GPO_19, AUX_19, AUX_in_19;
  GPO_20_CROSS: cross GPO_20, AUX_20, AUX_in_20;
  GPO_21_CROSS: cross GPO_21, AUX_21, AUX_in_21;
  GPO_22_CROSS: cross GPO_22, AUX_22, AUX_in_22;
  GPO_23_CROSS: cross GPO_23, AUX_23, AUX_in_23;
  GPO_24_CROSS: cross GPO_24, AUX_24, AUX_in_24;
  GPO_25_CROSS: cross GPO_25, AUX_25, AUX_in_25;
  GPO_26_CROSS: cross GPO_26, AUX_26, AUX_in_26;
  GPO_27_CROSS: cross GPO_27, AUX_27, AUX_in_27;
  GPO_28_CROSS: cross GPO_28, AUX_28, AUX_in_28;
  GPO_29_CROSS: cross GPO_29, AUX_29, AUX_in_29;
  GPO_30_CROSS: cross GPO_30, AUX_30, AUX_in_30;
  GPO_31_CROSS: cross GPO_31, AUX_31, AUX_in_31;
endgroup: gpo_cov
//------------------------------------------
// Sub Components
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "gpio_out_scoreboard", uvm_component parent = null);
// Only required if you have sub-components
extern function void build_phase(uvm_phase phase);
// Only required if you have sub-components which are connected
extern function void connect_phase(uvm_phase phase);
// Only required if the class generates stimulus or is an analysis component
extern task run_phase(uvm_phase phase);
// Scoreboard tasks - forever loops run in parallel:
extern task check_gpo;
extern function void check_gpoe(logic[31:0] GPOE_reg);
extern task monitor_aux;
extern task monitor_gpoe;
// Only required if you need to report:
extern function void report_phase(uvm_phase phase);

endclass: gpio_out_scoreboard

function gpio_out_scoreboard::new(string name = "gpio_out_scoreboard", uvm_component parent = null);
  super.new(name, parent);
  GPO_reg = 0;
  GPOE_reg = 0;
  AUX_reg = 0;
  gpoe_count = 0;
  gpoe_error_count = 0;
  gpo_error_count = 0;
  aux_error_count = 0;
  gpoe_cov = new;
  gpo_cov = new;
endfunction

// Only required if you have sub-components
function void gpio_out_scoreboard::build_phase(uvm_phase phase);
  GPO_fifo = new("GPO_fifo", this);
  GPOE_fifo = new("GPOE_fifo", this);
  AUX_fifo = new("AUX_fifo", this);
endfunction: build_phase

// Only required if you have sub-components which are connected
function void gpio_out_scoreboard::connect_phase(uvm_phase phase);

endfunction: connect_phase

// Only required if the class generates stimulus or is an analysis component
task gpio_out_scoreboard::run_phase(uvm_phase phase);
  fork
    check_gpo;
    monitor_gpoe;
    monitor_aux;
  join
endtask: run_phase

task gpio_out_scoreboard::monitor_gpoe;
  gpio_seq_item gpoe;

  forever begin
    GPOE_fifo.get(gpoe);
    gpoe_q.push_back(gpoe.gpio);
  end
endtask: monitor_gpoe

// Checks the GPOE outputs:
function void gpio_out_scoreboard::check_gpoe(logic[31:0] GPOE_reg);
  logic[31:0] gpio;
  bit error;

  begin
    error = 0;
    if(gpoe_q.size() == 0) begin
      `uvm_error("GPIO_OUTPUT_SB", "GPOEnable error - GPOE changed without a write to the GPOE register")
      error = 1;
    end
    else begin
      gpio = gpoe_q.pop_front();
      if(gpio != GPOE_reg) begin
        `uvm_error("GPIO_OUTPUT_SB", $sformatf("GPOEnable error - Expected %0h, Actual %0h", GPOE_reg, gpio))
        gpoe_error_count++;
        error = 1;
      end
    end
    gpoe_count++;
    if(error == 0) begin // Only sample the GPOE cover group if no errors detected
      gpoe_cov.sample();
    end
  end
endfunction: check_gpoe

// Gathers any AUX in changes:
task gpio_out_scoreboard::monitor_aux;
  gpio_seq_item aux;

  forever begin
    AUX_fifo.get(aux);
    aux_q.push_back(aux.gpio);
  end

endtask: monitor_aux

// Checks the GPO against the relevant source - GPO_reg or AUX_reg & AUX input!
task gpio_out_scoreboard::check_gpo;
  gpio_seq_item gpo;
  bit error;
  int last_error_count;
  logic[31:0] gpo_reg;
  logic[31:0] aux_reg;
  logic[31:0] aux_sample;
  gpo_q_t gpo_update;

  forever begin
    error = 0;
    last_error_count = gpo_error_count;
    GPO_fifo.get(gpo);
    if(gpo_q.size() == 0) begin
    end
    else begin // Get up to date with the latest changes ...
      gpo_update = gpo_q.pop_front();
      case(gpo_update.src)
        GPO_REG: gpo_reg = gpo_update.value;
        AUX_REG: aux_reg = gpo_update.value;
        AUX_SAMPLE: aux_sample = gpo_update.value;
      endcase

      if(aux_q.size() > 0) begin
        aux_sample = aux_q.pop_front();
        AUX_in_current = aux_sample;
      end
      foreach(aux_reg[i]) begin
        if(aux_reg[i] == 1) begin // Expecting the aux input to be on GPO
          if(gpo.gpio[i] != aux_sample[i]) begin
            `uvm_error("GPIO_OUTPUT_SB", $sformatf("AUX_Input to GPO error on bit %0d", i))
            aux_error_count++;
            error = 1;
          end
        end
        else begin // Expected the GPO register value to be on GPO
          if(gpo.gpio[i] != gpo_reg[i]) begin
            `uvm_error("GPIO_OUTPUT_SB", $sformatf("GPO error on bit %0d", i))
             gpo_error_count++;
             error = 1;
          end
        end
      end
    end
    if(error == 0) begin // Sample GPO functional coverage if no error
      gpo_cov.sample();
    end
    else begin
      `uvm_info("GPIO_OUTPUT_SB", $sformatf("AUX_REG: %0h GPO_REG: %0h AUX_INPUT: %0h GPO: %0h",
                                             aux_reg, gpo_reg, aux_sample, gpo.gpio), UVM_LOW)
    end
    gpo_count++;
  end
endtask: check_gpo

// Only required if you need to report:
function void gpio_out_scoreboard::report_phase(uvm_phase phase);
  if((gpo_error_count == 0) && (gpoe_error_count == 0) && (aux_error_count == 0)) begin
    `uvm_info("GPIO_OUTPUT_SB", "Test passed: no errors detected", UVM_LOW)
    `uvm_info("GPIO_OUTPUT_SB", $sformatf("%0d GPOE changes detected %0d GPO changes detected", gpoe_count, gpo_count), UVM_LOW)
  end
  else begin
    if(gpo_error_count != 0) begin
      `uvm_error("GPIO_OUTPUT_SB", $sformatf("Test failed %0d GPO errors detected", gpo_error_count))
    end
    if(aux_error_count != 0) begin
      `uvm_error("GPIO_OUTPUT_SB", $sformatf("Test failed %0d AUX errors detected", aux_error_count))
    end
    if(gpoe_error_count != 0) begin
      `uvm_error("GPIO_OUTPUT_SB", $sformatf("Test failed %0d GPOE errors detected", gpoe_error_count))
    end
  end
endfunction: report_phase
