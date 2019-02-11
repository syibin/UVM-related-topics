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

class wb_driver extends uvm_driver#(wb_seq_item);

 `uvm_component_utils(wb_driver)

 //uvm_analysis_port #(wb_seq_item) m_ap;

 string m_name;
 ui item_cnt = 0;
 wb_agent_config m_wb_agent_config;
 ui m_wbFrequency;
 ui m_wbHalfPeriod;

 virtual wbIf m_wbIf;

 extern function new(string name = "wb_driver", uvm_component parent = null);
 extern task run_phase(uvm_phase phase);
 extern function void build_phase(uvm_phase phase);
 extern virtual task wb_read_cycle;
 extern virtual task wb_write_cycle;
 extern virtual task genClk;
 
endclass

function wb_driver::new(string name = "wb_driver", uvm_component parent = null);
 super.new(name,parent);
 m_name = name;
endfunction

function void wb_driver::build_phase(uvm_phase phase);
 super.build_phase(phase);
 //m_ap = new("m_ap", this);
endfunction

task wb_driver::run_phase(uvm_phase phase);
 wb_seq_item cloned_wb_seq_item;
 if (!uvm_config_db#(wb_agent_config)::get(this,"","wb_agent_config", m_wb_agent_config))
  `uvm_fatal(m_name,"Could not get handle to wb_agent_config.")

 m_wbFrequency  = m_wb_agent_config.m_wbFrequency;
 m_wbHalfPeriod =  (10**6/m_wbFrequency)/2;

 fork
  genClk;
  forever begin
   seq_item_port.get_next_item(req);
   case(req.txn_type)
    WRITE    :  wb_write_cycle;
    READ     :  wb_read_cycle;
    //SCB      :  write_to_scbd;
    default  : `uvm_error(m_name, "unknown transaction type")
   endcase
   seq_item_port.item_done();

  end
 join
endtask

task wb_driver::wb_read_cycle;
 `uvm_info(m_name, "Wishbone read.", UVM_LOW)
 m_wbIf.addr <= req.addr;
 m_wbIf.we  <= 1'b0;
 m_wbIf.cyc <= 1'b1;
 m_wbIf.stb <= 1'b1;
 @(posedge m_wbIf.clk);
 while(!m_wbIf.ack) @(posedge m_wbIf.clk);
 req.data = m_wbIf.dat_i;
 m_wbIf.cyc <= 1'b0;
 m_wbIf.stb <= 1'b0; 
 `uvm_info(m_name, "Finished Wishbone read.", UVM_LOW)
endtask


task wb_driver::wb_write_cycle;
 `uvm_info(m_name, "Wishbone write.", UVM_LOW)
 m_wbIf.addr   <= req.addr;
 m_wbIf.dat_o  <= req.data;
 m_wbIf.we     <= 1'b1;
 m_wbIf.cyc    <= 1'b1;
 m_wbIf.stb    <= 1'b1;
 @(posedge m_wbIf.clk);
 while(!m_wbIf.ack) @(posedge m_wbIf.clk);
 m_wbIf.cyc    <= 1'b0;
 m_wbIf.stb    <= 1'b0;  
 `uvm_info(m_name, "Finished Wishbone write.", UVM_LOW)
endtask


task wb_driver::genClk; 
 m_wbIf.clk <= 1'b0;
 forever #m_wbHalfPeriod m_wbIf.clk <= ~m_wbIf.clk;
endtask



