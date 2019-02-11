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

class iic_env extends uvm_env;

 `uvm_component_utils(iic_env)

//------------------------------------------
// Data Members
//------------------------------------------

 iic_scoreboard m_iic_scoreboard;

 iic_agent m_iic_agent1;
 iic_agent m_iic_agent2;
 iic_agent m_iic_agent3;
 iic_agent m_iic_agent4;
 iic_agent m_iic_agent5;
 wb_agent  m_wb_agent;

 iic_env_config m_iic_env_config;
 iic_agent_config m_iic_agent_config1;
 iic_agent_config m_iic_agent_config2;
 iic_agent_config m_iic_agent_config3;
 iic_agent_config m_iic_agent_config4;
 iic_agent_config m_iic_agent_config5;
 wb_agent_config  m_wb_agent_config;

 iic_virtual_sequencer m_iic_virtual_sequencer;

//------------------------------------------
// Constraints
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
 extern function new(string name = "iic_env", uvm_component parent = null);
 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);

endclass


function iic_env::new(string name = "iic_env", uvm_component parent = null);
 super.new(name, parent);
endfunction


function void iic_env::build_phase(uvm_phase phase);

 m_iic_scoreboard = iic_scoreboard::type_id::create("m_iic_scoreboard",this);

 //For bring up, build two agents and connect them.
 if (!uvm_config_db#(iic_env_config)::get(this, "", "iic_env_config", m_iic_env_config))
  `uvm_fatal("iic_env","Could not get handle to iic_env_config.")
 //
 m_iic_agent_config1 = m_iic_env_config.m_iic_agent_config1;
 //m_iic_agent_config1.m_iic_scoreboard =  m_iic_xt_scoreboard;
 uvm_config_db#(iic_agent_config)::set(this, "m_iic_agent1*", "iic_agent_config", m_iic_agent_config1);
 //
 m_iic_agent_config2 = m_iic_env_config.m_iic_agent_config2;
 //m_iic_agent_config2.m_iic_scoreboard = m_iic_xt_scoreboard;
 uvm_config_db#(iic_agent_config)::set(this, "m_iic_agent2*", "iic_agent_config", m_iic_agent_config2);
 //
 m_iic_agent_config3 = m_iic_env_config.m_iic_agent_config3;
 //m_iic_agent_config3.m_iic_scoreboard = m_iic_dut_scoreboard;
 uvm_config_db#(iic_agent_config)::set(this, "m_iic_agent3*", "iic_agent_config", m_iic_agent_config3);
 //
 m_iic_agent_config4 = m_iic_env_config.m_iic_agent_config4;
 //m_iic_agent_config4.m_iic_scoreboard = m_iic_dut_scoreboard;
 uvm_config_db#(iic_agent_config)::set(this, "m_iic_agent4*", "iic_agent_config", m_iic_agent_config4);
 //
 m_iic_agent_config5 = m_iic_env_config.m_iic_agent_config5;
 //m_iic_agent_config5.m_iic_scoreboard = m_iic_dut_scoreboard;
 uvm_config_db#(iic_agent_config)::set(this, "m_iic_agent5*", "iic_agent_config", m_iic_agent_config5);
 //
 m_wb_agent_config = m_iic_env_config.m_wb_agent_config;
 uvm_config_db#(wb_agent_config)::set(this, "m_wb_agent*", "wb_agent_config", m_wb_agent_config);
 //
 m_iic_agent1 = iic_agent::type_id::create("m_iic_agent1",this);
 m_iic_agent2 = iic_agent::type_id::create("m_iic_agent2",this);
 m_iic_agent3 = iic_agent::type_id::create("m_iic_agent3",this);
 m_iic_agent4 = iic_agent::type_id::create("m_iic_agent4",this);
 m_iic_agent5 = iic_agent::type_id::create("m_iic_agent5",this);
 m_wb_agent   = wb_agent::type_id::create("m_wb_agent",this);
 m_iic_virtual_sequencer = iic_virtual_sequencer::type_id::create("iic_virtual_sequencer", this);

endfunction

function void iic_env::connect_phase(uvm_phase phase);

 //Cross traffic master
 m_iic_agent1.m_ap.connect(m_iic_scoreboard.m_master1DataImpPort);

 //DUT master
 m_wb_agent.m_ap.connect(m_iic_scoreboard.m_master2DataImpPort);

 //Slave device 1.
 m_iic_agent2.m_ap.connect(m_iic_scoreboard.m_slave1DataImpPort);

 //Slave device 2.
 m_iic_agent3.m_ap.connect(m_iic_scoreboard.m_slave2DataImpPort);

 //Slave device 3.
 m_iic_agent4.m_ap.connect(m_iic_scoreboard.m_slave3DataImpPort);

 //Slave device 4.
 m_iic_agent5.m_ap.connect(m_iic_scoreboard.m_slave4DataImpPort);


endfunction


