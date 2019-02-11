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


`uvm_analysis_imp_decl(_before)
`uvm_analysis_imp_decl(_after)

class comparator_ooo_imps #(type T = int, type IDX = int)
   extends uvm_component;

  typedef comparator_ooo_imps #(T, IDX) this_type;
  `uvm_component_param_utils(this_type)

  typedef T q_of_T[$];
  typedef IDX q_of_IDX[$];

  uvm_analysis_imp_before #(T, this_type) before_axp;
  uvm_analysis_imp_after #(T, this_type) after_axp;
  
  bit before_queued = 0;
  bit after_queued = 0;

  protected int m_matches, m_mismatches;

  protected q_of_T received_data[IDX];
  protected int rcv_count[IDX];

  protected process before_proc = null;
  protected process after_proc  = null;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    before_axp = new("before_axp", this);
    after_axp = new("after_axp", this);
  endfunction   
  
  protected function void proc_data(T txn_data, input bit is_before);
    T txn_existing;
    IDX idx;
    string rs;
    q_of_T tmpq;
    bit need_to_compare;
    idx = txn_data.index_id();
    // Check to see if there is an existing object to compare
    need_to_compare = (rcv_count.exists(idx) &&
                       ((is_before && rcv_count[idx] > 0) ||
                        (!is_before && rcv_count[idx] < 0)));
    if (need_to_compare) begin
      // Compare objects
      tmpq = received_data[idx];
      txn_existing = tmpq.pop_front();
      received_data[idx] = tmpq;
      if (txn_data.compare(txn_existing))
        m_matches++;
      else
        m_mismatches++;
    end
    else begin
      // If no compare happened, add the new entry
      if (received_data.exists(idx)) 
        tmpq = received_data[idx];
      else
        tmpq = {};
      tmpq.push_back(txn_data);
      received_data[idx] = tmpq;
    end

    // Update the index count
    if (is_before)
      if (rcv_count.exists(idx)) begin
	rcv_count[idx]--;
      end
      else
	rcv_count[idx] = -1;
    else
      if (rcv_count.exists(idx)) begin
	rcv_count[idx]++;
      end
      else
	rcv_count[idx] = 1;
    
    // If index count is balanced, remove entry from the arrays
    if (rcv_count[idx] == 0) begin
      received_data.delete(idx);
      rcv_count.delete(idx);
    end
  endfunction // proc_data

  virtual function int get_matches();
    return m_matches;
  endfunction : get_matches

  virtual function int get_mismatches();
    return m_mismatches;
  endfunction : get_mismatches

  virtual function int get_total_missing();
    int num_missing;
    foreach (rcv_count[i]) begin
      num_missing += (rcv_count[i] < 0 ? -rcv_count[i] : rcv_count[i]);
    end
    return num_missing;
  endfunction : get_total_missing
  
  virtual function q_of_IDX get_missing_indexes();
    q_of_IDX rv = rcv_count.find_index() with (item != 0);
    return rv;
  endfunction : get_missing_indexes;
  
  virtual function int get_missing_index_count(IDX i);
  // If count is < 0, more "before" txns were received
  // If count is > 0, more "after" txns were received
    if (rcv_count.exists(i))
      return rcv_count[i];
    else
      return 0;
  endfunction : get_missing_index_count;

  task run_phase(uvm_phase phase);
    fork
    join
  endtask // run_phase
  
  virtual function void write_before(T txn);    
      proc_data(txn, 1);
  endfunction // write_before
  
  virtual function void write_after(T txn);    
      proc_data(txn, 0);
  endfunction // write_after

endclass : comparator_ooo_imps


