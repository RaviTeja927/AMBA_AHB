`include "ahb_interface.sv"
`include "ahb_slave_interface.sv"
`include "ahb_sequence_item.sv"

`include "ahb_sequence.sv"
`include "ahb_sequencer.sv"
`include "ahb_mast_driver.sv"
`include "ahb_mast_monitor.sv"
 `include "ahb_mast_agent.sv"

`include "ahb_slave_monitor.sv"
`include "ahb_slave_sequencer.sv"
`include "ahb_virtual_sequencer.sv"

`include "ahb_slave_sequence.sv"

`include "ahb_slave_driver.sv"

`include "ahb_slave_agent.sv"


`include "ahb_virtual_sequence.sv"



`include "ahb_scoreboard.sv"
`include "ahb_subscriber.sv"
`include "ahb_environment.sv"

class test extends uvm_test;
  `uvm_component_utils(test)
  ahb_environment ahb_env;
  ahb_virtual_sequence  vir_seq;

  function new(string name="test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);  ahb_env=ahb_environment::type_id::create("ahb_env",this);
  endfunction
  
   function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
    
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    vir_seq=ahb_virtual_sequence::type_id::create("vir_seq");
    phase.raise_objection(this); 
    `uvm_info(get_type_name(),"AHB ENVIRONMENT IS BUILDING...",UVM_MEDIUM);
    vir_seq.start(ahb_env.ahb_vir_seqr);
    phase.drop_objection(this);
  endtask 
  
endclass


module tb;
  bit clk;
// int numb;
 always #10 clk = ~clk;

ahb_interface ahb_intf(clk);
ahb_slave_interface ahb_sl_intf(clk);
initial begin
  clk=1;
  uvm_config_db #(virtual ahb_interface)::set(null,"*","ahb_intf",ahb_intf);
 ahb_intf.HREADY=1;
 ahb_intf.HRESP=0;
 ahb_intf.HADDR=24;
  assign ahb_sl_intf.HRESET=ahb_intf. HRESET;
  assign ahb_sl_intf.HADDR=ahb_intf.HADDR;
  assign ahb_sl_intf.HTRANS=ahb_intf.HTRANS;
  assign ahb_sl_intf.HBURST=ahb_intf.HBURST;
  assign ahb_sl_intf.HSIZE=ahb_intf.HSIZE;
  assign ahb_sl_intf.HWRITE=ahb_intf.HWRITE;
  assign ahb_sl_intf.HWDATA=ahb_intf.HWDATA;
  assign ahb_intf.HREADY=ahb_sl_intf.HREADY;
  assign ahb_intf.HRDATA=ahb_sl_intf.HRDATA;
  assign ahb_intf.HRESP=ahb_sl_intf.HRESP;
  uvm_config_db #(virtual ahb_slave_interface)::set(null,"*","ahb_sl_intf",ahb_sl_intf);
  run_test("test");
end
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end
endmodule
