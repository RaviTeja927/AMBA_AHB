//ahb master agent class
class ahb_agent extends uvm_agent;
  `uvm_component_utils(ahb_agent)
  function new(string name="ahb_agent",uvm_component parent);
    super.new(name, parent);
  endfunction
  
  ahb_sequencer ahb_seqr;
  ahb_driver    ahb_drv;
  ahb_monitor   ahb_mon;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    ahb_seqr =  ahb_sequencer::type_id::create("ahb_seqr",this);
    ahb_drv  =  ahb_driver::type_id::create("ahb_drv",this);
    ahb_mon  =  ahb_monitor::type_id::create("ahb_mon",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ahb_drv.seq_item_port.connect(ahb_seqr.seq_item_export);
  endfunction 
endclass
