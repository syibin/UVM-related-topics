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

class iic_test_base extends uvm_test;

 `uvm_component_utils(iic_test_base)
 
 iic_agent_config  m_iic_agent1_config;
 iic_agent_config  m_iic_agent2_config;
 iic_agent_config  m_iic_agent3_config;
 iic_agent_config  m_iic_agent4_config;
 iic_agent_config  m_iic_agent5_config;
 wb_agent_config   m_wb_agent_config;
 iic_env_config    m_iic_env_config;

 virtual iicIf     m_iicIf1;
 virtual iicIf     m_iicIf2;
 virtual iicIf     m_iicIf3;
 virtual iicIf     m_iicIf4;
 virtual iicIf     m_iicIf5;
 virtual wbIf      m_wbIf;

 iic_env           m_env;

 extern function new(string name = "iic_test_base", uvm_component parent = null);
 extern function void build_phase(uvm_phase phase);

endclass

function iic_test_base::new(string name = "iic_test_base", uvm_component parent = null);
 super.new(name, parent);
 assert(this.randomize()) else `uvm_fatal(m_name, "could not randomize test")
endfunction

function void iic_test_base::build_phase(uvm_phase phase);

 if (!uvm_config_db#(virtual iicIf)::get(this, "", "iicIf1", m_iicIf1))
  `uvm_fatal("iic_test_base", "Could not get iic interface handle handle #1.")

 if (!uvm_config_db#(virtual iicIf)::get(this, "", "iicIf2", m_iicIf2))
  `uvm_fatal("iic_test_base", "Could not get iic interface handle handle #2.")

 if (!uvm_config_db#(virtual iicIf)::get(this, "", "iicIf3", m_iicIf3))
  `uvm_fatal("iic_test_base", "Could not get iic interface handle handle #3.")

 if (!uvm_config_db#(virtual iicIf)::get(this, "", "iicIf4", m_iicIf4))
  `uvm_fatal("iic_test_base", "Could not get iic interface handle handle #4.")

 if (!uvm_config_db#(virtual iicIf)::get(this, "", "iicIf5", m_iicIf5))
  `uvm_fatal("iic_test_base", "Could not get iic interface handle handle #5.")

 if (!uvm_config_db#(virtual wbIf)::get(this, "", "wbIf", m_wbIf))
  `uvm_fatal("iic_test_base", "Could not get wishbone interface handle handle.")

 m_iicIf1.setBusFrequency(50);      //kHz
 m_iic_agent1_config                = iic_agent_config::type_id::create("m_iic_agent1_config");
 m_iic_agent1_config.m_iicIf        = m_iicIf1;

 m_iicIf2.setBusFrequency(50);      //kHz
 m_iic_agent2_config                = iic_agent_config::type_id::create("m_iic_agent2_config");
 m_iic_agent2_config.m_iicIf        = m_iicIf2;

 m_iicIf3.setBusFrequency(50);      //kHz
 m_iic_agent3_config                = iic_agent_config::type_id::create("m_iic_agent3_config");
 m_iic_agent3_config.m_iicIf        = m_iicIf3;

 m_iicIf4.setBusFrequency(50);      //kHz
 m_iic_agent4_config                = iic_agent_config::type_id::create("m_iic_agent4_config");
 m_iic_agent4_config.m_iicIf        = m_iicIf4;

 m_iicIf5.setBusFrequency(50);      //kHz
 m_iic_agent5_config                = iic_agent_config::type_id::create("m_iic_agent5_config");
 m_iic_agent5_config.m_iicIf        = m_iicIf5;

 m_wb_agent_config                  = wb_agent_config::type_id::create("m_wb_agent_config");
 m_wb_agent_config.m_wbFrequency    = P_DEFAULTWBFREQUENCY;
 m_wb_agent_config.m_sclFrequency   = 50  ; //kHz
 m_wb_agent_config.m_wbIf = m_wbIf; 

 m_iic_env_config = iic_env_config::type_id::create("m_iic_env_config");
 m_iic_env_config.m_iic_agent_config1 = m_iic_agent1_config;
 m_iic_env_config.m_iic_agent_config2 = m_iic_agent2_config;
 m_iic_env_config.m_iic_agent_config3 = m_iic_agent3_config;
 m_iic_env_config.m_iic_agent_config4 = m_iic_agent4_config;
 m_iic_env_config.m_iic_agent_config5 = m_iic_agent5_config;
 m_iic_env_config.m_wb_agent_config   = m_wb_agent_config;
 uvm_config_db#(iic_env_config)::set(this, "m_env", "iic_env_config", m_iic_env_config);

 m_env = iic_env::type_id::create("m_env", this);

endfunction
