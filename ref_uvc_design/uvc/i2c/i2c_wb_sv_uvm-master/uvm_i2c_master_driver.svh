//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the I2C driver which behaves as a master to the DUT which is
//configured to be the I2C slave. This component is under construction.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------

`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_master_driver extends uvm_driver #(i2c_transaction);
//------------------------------------------------------------------------------
//Registering the class to the factory
//------------------------------------------------------------------------------
  `uvm_component_utils (i2c_master_driver)
  
//------------------------------------------------------------------------------
//Instantiating the virtual interface in order retrieve the interface from the
//configuration database. So that driver can drive the signals of the DUT
//from the class based environment
//------------------------------------------------------------------------------
  virtual i2c_if i2c_vi;
//------------------------------------------------------------------------------
//Local signals and variables for driver functionality
//------------------------------------------------------------------------------
  bit send_data_flag;
  reg [3:0] state = 4'b0000; 
  reg [2:0] state_scl = 3'b000; 
  reg [2:0] count = 0;

  localparam IDLE   = 4'b0000;
  localparam START  = 4'b0001;
  localparam ADDR   = 4'b0010;
  localparam RW     = 4'b0011;
  localparam WACK   = 4'b0100;
  localparam DATA   = 4'b0101;
  localparam WACK2  = 4'b0110;
  localparam STOP1   = 4'b0111;
  localparam STOP2   = 4'b1000;
  
  
  localparam IDLE_SCL   = 3'b000;
  localparam START_SCL  = 3'b001;
  localparam STOP_SCL1   = 3'b010;
  localparam STOP_SCL2   = 3'b011;

//------------------------------------------------------------------------------
//constructor
//------------------------------------------------------------------------------

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

//------------------------------------------------------------------------------
//Build method. Here the DUT interface is retrieved from the configuration database
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", i2c_vi)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
    end 
  endfunction

//------------------------------------------------------------------------------
//The run method of the driver, which consumes time.
//Calls driver functions that receives transcations from the sequencer and drives it
//onto the pins of the DUT
//------------------------------------------------------------------------------
  
  task run_phase(uvm_phase phase);
    reg [6:0] addr = 7'b0000001;
    reg [7:0] data = 8'b10011001;
      repeat(4)
      begin
        i2c_transaction i2c_tx;
        @(posedge i2c_vi.clk);
        seq_item_port.get(i2c_tx);

        addr = i2c_tx.addr;   
        data = i2c_tx.data;

        write_2_sda_slave(addr, data);
      end
  endtask

  
//------------------------------------------------------------------------------
//Main control task which as three parallel running threads.
//send_scl contains a state machine to generate the SCL for the SDA
//Send_data_write contains a write state machine to provide data - SDA to I2C while
//following I2C protcol rules. The SDA and SCL strictly adheres to the I2C protocol 
//detect_byte_xferred enables the data transfer using these state machines.
//This functionality is still under construction.
//------------------------------------------------------------------------------
  task write_2_sda_slave(input [6:0]addr, input [7:0] data);
  begin
  #1000;
    send_data_flag = 1;
    fork
      send_sda_write(addr, data);
      //send_sda_read;
      send_scl;
      detect_byte_xferred;
    join
  end
  endtask

//------------------------------------------------------------------------------
//Task to control SCL and SDA state machine
//------------------------------------------------------------------------------

  task detect_byte_xferred;
  begin
    forever
    begin
      @(posedge i2c_vi.clk);
      if(state == STOP2)
      begin
        send_data_flag = 0;
      end 
    end
  end
  endtask

//------------------------------------------------------------------------------
//SCL - Clock generation state machine
//------------------------------------------------------------------------------
  task send_scl;
    begin
      forever
      begin
      @(negedge i2c_vi.clk);
      case (state_scl)
        IDLE_SCL : begin
          i2c_vi.scl_oe = 1;
          if(i2c_vi.sda_oe == 0 && send_data_flag == 1)
          begin
            state_scl = START_SCL;
          end
          else
          begin
            state_scl = IDLE;
          end
        end
        START_SCL : begin
            i2c_vi.scl_oe = ~i2c_vi.scl_oe;
            if(state == STOP1) begin
              state_scl = STOP_SCL1;
            end
            else begin
              state_scl = START_SCL;
            end
        end
        STOP_SCL1 : begin
            i2c_vi.scl_oe = ~i2c_vi.scl_oe;
              state_scl = STOP_SCL2;
        end
        STOP_SCL2 : begin
          i2c_vi.scl_oe = 1;
          state_scl = IDLE_SCL;
        end
      endcase
      end
    end
  endtask;

//------------------------------------------------------------------------------
//Data write state machine to write data over SDA
//------------------------------------------------------------------------------
  task send_sda_write(input [6:0]addr, input [7:0] data);
    begin
    forever
      begin
      @(negedge i2c_vi.clk_sda);
      case (state)
      IDLE : begin
        i2c_vi.sda_oe = 1;
        if(send_data_flag == 1) begin
          state = START;
        end else begin
          state = IDLE;
        end
      end
      START : begin
        i2c_vi.sda_oe = 0;
        state = ADDR;
        count = 6;
      end
      ADDR : begin
        i2c_vi.sda_oe = addr[count];
        if(count == 0) state = RW;
        else count = count - 1;
      end
      RW : begin //Setting read=1 write=0 bit
        i2c_vi.sda_oe = 0;
        state = WACK;
      end
      WACK : begin
        i2c_vi.sda_oe = 1;
        state = DATA;
        count = 7;
      end
      DATA : begin
        i2c_vi.sda_oe = data[count];
        if(count == 0) state = WACK2;
        else count = count - 1;
      end
      WACK2 : begin
        i2c_vi.sda_oe = 1;
        state = STOP1;
      end
      STOP1 : begin
        i2c_vi.sda_oe = 0;
        state = STOP2;
      end
      STOP2 : begin
        i2c_vi.sda_oe = 1;
        state = IDLE;
      end
      endcase
      end
    end
  endtask

//-------------------------------------------------
  /// Pre-reset Phase Task 
//-------------------------------------------------
task pre_reset_phase (uvm_phase phase);
  phase.raise_objection(this);
  i2c_vi.reset = 1'b0;
  i2c_vi.addr_in = 0;
  i2c_vi.we = 0;
  i2c_vi.addr_in = 8'h00;
  i2c_vi.data_in = 8'b00;
  i2c_vi.wb_stb_i = 0;
  i2c_vi.wb_cyc_i = 0;
  i2c_vi.sda_oe = 1;
  i2c_vi.scl_oe = 1;

  #1;
  phase.drop_objection(this);
endtask: pre_reset_phase

//-------------------------------------------------
/// Reset Phase Task, reset is Active high
//-------------------------------------------------
task reset_phase(uvm_phase phase);
  phase.raise_objection(this);
  i2c_vi.reset = 1'b1;
  #100;
  i2c_vi.reset = 1'b0;
  #10;
  phase.drop_objection(this);
endtask: reset_phase 

endclass
