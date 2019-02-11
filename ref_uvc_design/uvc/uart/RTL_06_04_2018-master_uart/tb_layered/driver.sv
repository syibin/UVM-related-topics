class driver;

    virtual     uart_interface uif;
    typedef enum bit { REG_RD = 1'b0, REG_WR = 1'b1 } reg_access_t;
    int init_reg_val[6]/* = '{ 32'h0, 32'h0, 32'hC050, 32'h0, 32'h0, 32'h0 }*/; //assigning values here is also valid

    bit  [7:0]  character;
    bit [31:0]  read_data;

    bit [31:0]  read_data_n;
    bit [31:0]  read_data_nn;
    bit [31:0]  read_data_nnn;
    bit [31:0]  read_data_nnnn; 

    bit           error, err_addr;
    bit   [31:0]  mode;
    bit    [2:0]  interrupts_config;
    bit    [1:0]  ins_errors;
    bit   [31:0]  intf;
    bit    [9:0]  rx_data_queue [$];
    bit    [3:0]  send_error;

    logic  [1:0]  block_sel;
    logic  [1:0]  special;
    logic [31:0]  symbol;
    logic  [9:0]  symbol_n;
    logic  [9:0]  symbol_nn;
    logic  [9:0]  symbol_nnn;
    logic  [9:0]  symbol_nnnn;

    //logic       interrupt;
    int         LOOPBACK_CHARACTER_NUM, loop_count;
    mailbox     gen2drv, drv2scb;
    transaction trans, trn_drv, trn_scb;

    `include "coverage_loopback.sv"
    `include "coverage_receive.sv"

    function new(virtual uart_interface uif, mailbox gen2drv, drv2scb);
        this.uif               = uif;
        this.gen2drv           = gen2drv;
        this.drv2scb           = drv2scb;
        trn_drv                = new();
        uart_cg_loopback       = new();
        uart_cg_receive        = new();
        init_reg_val           = '{ 32'h0, 32'h0, 32'h0, 32'hC040, 32'h0, 32'h0 };
    endfunction

    //----- Register access method via APB bus -----//

    extern task automatic reg_access( input        [31:0] address,      // register's address
                           	          input  reg_access_t access_type,  // 0 - read, 1 - write 
                           	          input        [31:0] reg_wr_data,  // data to be written into register
                           	          input         [3:0] reg_be,       // byte enables for write data bytes (1 be per byte)  
                           	          output       [31:0] reg_rd_data,  // data read from register
                           	          output              reg_err       // error returned
                         	          );

    extern task automatic send_uart_char( input bit        insert_perr,
                                          input bit        insert_ferr,
                                          input bit [31:0] mode,
                                          input bit [ 7:0] character
                                        );

    extern task print_test_config( input [31:0] reg_base_addr,
                        	       input [31:0] mode,
                        	       input  [2:0] interrupts_config,
                                   input [31:0] LOOPBACK_CHARACTER_NUM
                                 );

    extern task print_test_result( input string result );
    extern task run_sim_loop_back();
    extern task run_sim_loop_back_soc();
    extern task run_sim_receive();
    extern task run_sim_overrun();
    extern task run_sim_transmit_m0090();
    extern task run_sim_transmit_m1090();
    extern task run_sim_transmit_m2090();
    extern task run_sim_txdata_check();
    extern task run_sim_txbrk_check();
    extern task run_sim_transmit();
    extern task run_sim_read_reg();
    extern task run_sim_control();

endclass : driver

`include "task_reg_access.sv"
`include "task_send_uart_char.sv"
`include "task_print_test_config.sv"
`include "task_print_test_result.sv"
`include "task_run_sim_loop_back.sv"
`include "task_run_sim_loop_back_soc.sv"
`include "task_run_sim_receive.sv"
`include "task_run_sim_overrun.sv"
`include "task_run_sim_transmit_m0090.sv"
`include "task_run_sim_transmit_m1090.sv"
`include "task_run_sim_transmit_m2090.sv"
`include "task_run_sim_txdata_check.sv"
`include "task_run_sim_txbrk_check.sv"
`include "task_run_sim_transmit.sv"
`include "task_run_sim_read_reg.sv"
`include "task_run_sim_control.sv"