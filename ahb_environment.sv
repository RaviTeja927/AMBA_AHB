//environment class 

class ahb_environment extends uvm_env;
  `uvm_component_utils(ahb_environment)
  
  function new(string name="ahb_environment",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  ahb_agent ahb_ag;
  //ahb_slave_agent ahb_sl_ag;
  //ahb_virtual_sequencer ahb_vir_seqr;
  ahb_scoreboard ahb_sb;
  ahb_subscriber ahb_subsc;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_ag       = ahb_agent::type_id::create("ahb_ag",this);
    ahb_sb       = ahb_scoreboard::type_id::create("ahb_sb",this);
    //ahb_sl_ag    = ahb_slave_agent::type_id::create("ahb_sl_ag",this);
    ahb_subsc    = ahb_subscriber::type_id::create("ahb_subsc",this);
    //ahb_vir_seqr = ahb_virtual_sequencer::type_id::create("ahb_vir_seqr",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //ahb_vir_seqr.ahb_mast_seqr=ahb_ag.ahb_seqr;
    //ahb_vir_seqr.ahb_sl_seqr=ahb_sl_ag.ahb_sl_seqr;     
    ahb_ag.ahb_mon.mon_analysis_port.connect(ahb_sb.drv_imp);//from master
    //ahb_sl_ag.ahb_sl_mon. mon_analysis_port_slave.connect(ahb_sb.mon_imp);//from slave
    ahb_ag.ahb_mon.mon_analysis_port.connect(ahb_subsc.analysis_export);
  endfunction
  
endclass
