/////////////////////////////////////////////////////////////////////
////                                                             ////
////  I2C verification environment using the UVM                 ////
////                                                             ////
////                                                             ////
////  Author: Carsten Thiele                                     ////
////          carsten.thiele@enquireservicesltd.co.uk            ////
////                                                             ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2012                                          ////
////          Enquire Services                                   ////
////          carsten.thiele@enquireservicesltd.co.uk            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`uvm_analysis_imp_decl(_master1)
`uvm_analysis_imp_decl(_master2)
`uvm_analysis_imp_decl(_slave1)
`uvm_analysis_imp_decl(_slave2)
`uvm_analysis_imp_decl(_slave3)
`uvm_analysis_imp_decl(_slave4)

class iic_scoreboard extends uvm_component;
 `uvm_component_utils(iic_scoreboard)

 typedef enum {waitForMasterData, compareData} scbdState_t;
 scbdState_t m_master1ScbState;
 scbdState_t m_master2ScbState;

 //// Data
 //
 uvm_analysis_imp_master1 #(bit[8:0], iic_scoreboard) m_master1DataImpPort;
 uvm_analysis_imp_master2 #(bit[8:0], iic_scoreboard) m_master2DataImpPort;
 uvm_analysis_imp_slave1 #(bit[8:0], iic_scoreboard) m_slave1DataImpPort;
 uvm_analysis_imp_slave2 #(bit[8:0], iic_scoreboard) m_slave2DataImpPort;
 uvm_analysis_imp_slave3 #(bit[8:0], iic_scoreboard) m_slave3DataImpPort;
 uvm_analysis_imp_slave4 #(bit[8:0], iic_scoreboard) m_slave4DataImpPort;


 string m_name;

 bit[8:0] m_master1DataQ[$];
 bit[8:0] m_master2DataQ[$];
 bit[8:0] m_master1SlaveDataQ[$];
 bit[8:0] m_master2SlaveDataQ[$];

 bit[7:0] m_master1Data;
 bit[7:0] m_master1SlaveData;
 bit[7:0] m_master2Data;
 bit[7:0] m_master2SlaveData;

 bit m_resetMaster1Scb;
 bit m_resetMaster2Scb;


 //// Methods
 //

 extern function new(string name = "iic_scoreboard", uvm_component parent = null);
 extern virtual task run_phase(uvm_phase phase);
 extern virtual function void write_master1(bit[8:0] master1Data);
 extern virtual function void write_master2(bit[8:0] master2Data);
 extern virtual function void write_slave1(bit[8:0] slave1Data);
 extern virtual function void write_slave2(bit[8:0] slave2Data);
 extern virtual function void write_slave3(bit[8:0] slave3Data);
 extern virtual function void write_slave4(bit[8:0] slave4Data);
 extern virtual task compareMaster1Data;
 extern virtual task compareMaster2Data;
 extern virtual function void report_phase(uvm_phase phase);

endclass

function iic_scoreboard::new(string name = "iic_scoreboard", uvm_component parent = null);
 super.new(name,parent);
 m_name = name;
 m_master1DataImpPort = new("m_master1DataImpPort",this);
 m_master2DataImpPort = new("m_master2DataImpPort",this);
 m_slave1DataImpPort = new("m_slave1DataImpPort",this);
 m_slave2DataImpPort = new("m_slave2DataImpPort",this);
 m_slave3DataImpPort = new("m_slave3DataImpPort",this);
 m_slave4DataImpPort = new("m_slave4DataImpPort",this);
endfunction

function void iic_scoreboard::write_master1(bit[8:0] master1Data);
 `uvm_info(m_name, $psprintf("Master 1 data received = %h", master1Data), UVM_LOW)
 m_master1DataQ.push_back(master1Data);
endfunction

function void iic_scoreboard::write_master2(bit[8:0] master2Data);
 `uvm_info(m_name, $psprintf("Master 2 data received = %h", master2Data), UVM_LOW)
 m_master2DataQ.push_back(master2Data);
endfunction

function void iic_scoreboard::write_slave1(bit[8:0] slave1Data);
 `uvm_info(m_name, $psprintf("Slave 1 data received = %h", slave1Data), UVM_LOW)
 m_master1SlaveDataQ.push_back(slave1Data);
 m_master2SlaveDataQ.push_back(slave1Data);
endfunction

function void iic_scoreboard::write_slave2(bit[8:0] slave2Data);
 `uvm_info(m_name, $psprintf("Slave 2 data received = %h", slave2Data), UVM_LOW)
 m_master1SlaveDataQ.push_back(slave2Data);
 m_master2SlaveDataQ.push_back(slave2Data);
endfunction

function void iic_scoreboard::write_slave3(bit[8:0] slave3Data);
 `uvm_info(m_name, $psprintf("Slave 3 data received = %h", slave3Data), UVM_LOW)
 m_master1SlaveDataQ.push_back(slave3Data);
 m_master2SlaveDataQ.push_back(slave3Data);
endfunction

function void iic_scoreboard::write_slave4(bit[8:0] slave4Data);
 `uvm_info(m_name, $psprintf("Slave 4 data received = %h", slave4Data), UVM_LOW)
 m_master1SlaveDataQ.push_back(slave4Data);
 m_master2SlaveDataQ.push_back(slave4Data);
endfunction

task iic_scoreboard::run_phase(uvm_phase phase);

 fork
  compareMaster1Data;
  compareMaster2Data;
 join

endtask


task  iic_scoreboard::compareMaster1Data;

 m_master1ScbState = waitForMasterData;

 forever begin
 //
  case (m_master1ScbState)
   //
   waitForMasterData : begin
    wait(m_master1DataQ.size());
    m_resetMaster1Scb = m_master1DataQ[0][8];
    m_master1Data     = m_master1DataQ[0][7:0];
    m_master1DataQ.pop_front();
    if (m_resetMaster1Scb) begin
     m_master1SlaveDataQ.delete();
     if (m_master1DataQ.size()) begin
      `uvm_fatal(m_name, "Error. Attempt to reset SCB before all master data has been checked.")
     end
    end else begin
     m_master1ScbState = compareData;
    end
   end
   //
   compareData : begin
    wait(m_master1SlaveDataQ.size());
    m_master1SlaveData = m_master1SlaveDataQ[0][7:0];
    m_master1SlaveDataQ.pop_front();
    if (m_master1Data != m_master1SlaveData) begin
     `uvm_fatal(m_name, $psprintf("Master 1 : Data mismatch. Master Data = %h, Slave Data = %h",m_master1Data,m_master1SlaveData ))
    end else begin
     `uvm_info(m_name,  $psprintf("Master1 : Successful match. Master Data = %h, Slave Data = %h",m_master1Data,m_master1SlaveData), UVM_LOW)
    end
    m_master1ScbState = waitForMasterData;    
   end
   //
  endcase
  //
 end

endtask


task iic_scoreboard::compareMaster2Data;

 m_master2ScbState = waitForMasterData;

 forever begin
 //
  case (m_master2ScbState)
   //
   waitForMasterData : begin
    wait(m_master2DataQ.size());
    m_resetMaster2Scb = m_master2DataQ[0][8];
    m_master2Data     = m_master2DataQ[0][7:0];
    m_master2DataQ.pop_front();
    if (m_resetMaster2Scb) begin
     m_master2SlaveDataQ.delete();
     if (m_master2DataQ.size()) begin
      `uvm_fatal(m_name, "Error. Attempt to reset SCB before all master data has been checked.")
     end
    end else begin
     m_master2ScbState = compareData;
    end
   end
   //
   compareData : begin
    wait(m_master2SlaveDataQ.size());
    m_master2SlaveData = m_master2SlaveDataQ[0][7:0];
    m_master2SlaveDataQ.pop_front();
    if (m_master2Data != m_master2SlaveData) begin
     `uvm_fatal(m_name, $psprintf("Master2 : Data mismatch. Master Data = %h, Slave Data = %h",m_master2Data,m_master2SlaveData ))
    end else begin
     `uvm_info(m_name,  $psprintf("Master2 : Successful match. Master Data = %h, Slave Data = %h",m_master2Data,m_master2SlaveData), UVM_LOW)
    end
    m_master2ScbState = waitForMasterData;    
   end
   //
  endcase
  //
 end

endtask

function void iic_scoreboard::report_phase(uvm_phase phase);
 if (m_master1DataQ.size()) begin
  `uvm_error(m_name, "Unchecked data from master1.")
  foreach (m_master1DataQ[i]) begin
   $display("Unchecked master 1 data = %h",m_master1DataQ[i][7:0]);
  end
 end
 if (m_master2DataQ.size()) begin
  `uvm_error(m_name, "Unchecked data from master2.")
  foreach (m_master2DataQ[i]) begin
   $display("Unchecked master 2 data = %h",m_master2DataQ[i][7:0]);
  end
 end

endfunction




