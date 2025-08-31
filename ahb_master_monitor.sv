//monitor class which monitors the transactions from the interface
class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
  
  uvm_analysis_port #(ahb_seq_item) mon_analysis_port;
  
  virtual ahb_interface intf;

  bit[31:0] current_addr;


  function new(string name="ahb_monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port=new("mon_analysis_port",this);
    if(uvm_config_db #(virtual ahb_interface)::get(this,"","ahb_intf",intf))
    `uvm_info(get_type_name(),"Getting interface into monitor",UVM_MEDIUM);
  endfunction
  
virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info("[MONITOR]", "monitor receiving sequence items from driver", UVM_MEDIUM);
  forever begin
   ahb_seq_item req = ahb_seq_item::type_id::create("req");
    @(intf.HADDR, intf.HTRANS, intf.HSIZE, intf.HWDATA, intf.HWRITE, intf.HRESP);
    req.hwdata    = new[1];
    current_addr  = intf.HADDR;
    req.hwrite    = intf.HWRITE;
    req.hburst    = intf.HBURST;
    req.hsize     = intf.HSIZE;
    req.hwdata[0] = intf.HWDATA;
    req.haddr     = current_addr;
   // req.htrans  = intf.HTRANS;
   // `uvm_info("[MONITOR]",$sformatf("haddr = %0h,hwdata = %0h in  monitor", req.haddr, req.hwdata[0]), UVM_MEDIUM);
    // @(posedge intf.clk);
     mon_analysis_port.write(req);
  end 
endtask
endclass

