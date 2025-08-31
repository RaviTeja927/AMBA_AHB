//ahb_sequnecer class, which starts the sequence item on the ahb_master driver
class ahb_sequencer extends uvm_sequencer #(ahb_seq_item);
  `uvm_component_utils(ahb_sequencer)
  function new(string name="ahb_seqr",uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
