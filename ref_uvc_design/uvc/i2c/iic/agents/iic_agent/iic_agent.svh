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

class iic_agent extends uvm_agent;
 `uvm_component_utils(iic_agent)

 string m_name;

 iic_agent_config m_iic_agent_config;
 virtual iicIf    m_iicIf;
 
 iic_sequencer m_iic_sequencer;
 iic_driver    m_iic_driver;

 uvm_analysis_port #(bit[8:0]) m_ap;

 extern function new(string name = "iic_agent", uvm_component parent = null);
 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);

endclass

function iic_agent::new(string name = "iic_agent", uvm_component parent = null);
 super.new(name,parent);
 m_name = name;
endfunction

function void iic_agent::build_phase(uvm_phase phase);
 super.build_phase(phase);

 //Configure byte.
 if (!uvm_config_db#(iic_agent_config)::get(this, "", "iic_agent_config", m_iic_agent_config))
  `uvm_fatal(m_name, "Unable to get handle to iic_agent_config.")
 m_iicIf = m_iic_agent_config.m_iicIf;

 //Create sub components.
 m_iic_driver = iic_driver::type_id::create("m_iic_driver", this);
 m_iic_driver.m_iicIf = m_iicIf;
 m_iic_sequencer = iic_sequencer::type_id::create("m_iic_sequencer", this);

endfunction

function void iic_agent::connect_phase(uvm_phase phase);
 super.connect_phase(phase);
 m_iic_driver.seq_item_port.connect(m_iic_sequencer.seq_item_export);
 m_ap = m_iic_sequencer.m_ap;
endfunction





