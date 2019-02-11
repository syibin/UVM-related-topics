
//From verificationAcademy

class spi_test_config extends uvm_object;

localparam string s_my_config_id = "spi_test_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(spi_test_config)

// Virtual Interface
virtual spi_interface spi_vif;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_ACTIVE;
bit has_functional_coverage = 0;

//------------------------------------------
// Methods
//------------------------------------------
extern static function spi_test_config get_config( uvm_component c);
// Standard UVM Methods:
extern function new(string name = "spi_test_config");

endclass: spi_test_config

function spi_test_config::new(string name = "spi_test_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function spi_test_config spi_test_config::get_config( uvm_component c );
  spi_test_config t;
  
  if (!uvm_config_db #(spi_test_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))


  return t;
endfunction
