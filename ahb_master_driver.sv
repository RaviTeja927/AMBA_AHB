//ahb driver class will be part of the handshake mechanism with sequence and drive the data into the interface

typedef enum {IDLE, BUSY, NONSEQ, SEQ} h_trans;
class ahb_driver extends uvm_driver #(ahb_seq_item); 
  `uvm_component_utils(ahb_driver)
  h_trans htrans;
  virtual ahb_interface intf;
  //`define drv_intf intf.drv.cb1;
 
  int aligned_address,wrap_boundary,st_addr;  //for wrap calculations
  int haddr_drv;                              //for haddr next location
  bit[31:0] qu[$];
  
  function new(string name="ahb_driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(uvm_config_db #(virtual ahb_interface)::get(this,"","ahb_intf",intf))
    `uvm_info(get_type_name(),"Getting interface into driver",UVM_MEDIUM);
  endfunction
  
  extern task drive_write();   //this task is used for write transactions
  extern task drive_read();    //this task isused for read transactions
  extern task single();        //this task is used for single transaction either write/read
  extern task incr();          //this task is used for undfeined increment
  extern task wrap();          //this task is used for wrap4/8/16 
  extern task wrap_logic();    //wrap4/8/16 logic for  
  extern task aligned_cal();   //used for aligned address calculations for wrap transaction
        
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("[DRIVER]","Driver receving sequence items",UVM_MEDIUM);
    forever begin
      req = ahb_seq_item::type_id::create("req");
      seq_item_port.get_next_item(req);
      if(req.hwrite) begin
        drive_write();
      end
      if(!req.hwrite) begin
        drive_read();
      end
      seq_item_port.item_done();
    end
  endtask
endclass
    
task ahb_driver::drive_write();
  fork
    ahb_driver::single();
    ahb_driver::incr();
    ahb_driver::wrap();
  join  
endtask
    
task ahb_driver::drive_read();
  fork
    ahb_driver::single();
    ahb_driver::incr();
    ahb_driver::wrap();
  join  
endtask
     
//writing task for SINGLE transfer  
task ahb_driver::single();
  //******************WRITE LOGIC****************************//
  if(req.hburst == SINGLE&&req.hwrite) begin
    for(int i = 0;i <= req.hwdata.size();i++) begin
      if(i == 0) begin
        htrans = 2;
        intf.HTRANS <= htrans;
        intf.HBURST <= req.hburst;
        intf.HADDR  <= req.haddr;
        intf.HWRITE <= req.hwrite;
        intf.HSIZE  <= req.hsize;
        @(posedge intf.clk);
        intf.HWDATA<=req.hwdata[i];     
        //`uvm_info(get_type_name(),$sformatf("HADDR=%0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
      end
      else  begin
        htrans = 0;
        intf.HTRANS <= htrans;
        intf.HADDR  <= 32'hx;
        @(posedge intf.clk);
       /*if(req.haddr) begin
         htrans = 2;
         intf.HTRANS <= htrans;
         intf.HADDR  <= req.haddr;
         @(posedge intf.clk);
        end*/
       //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver", intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
      end
   end
 end
      
/**************READ LOGIC********************************/  
if(req.hburst == SINGLE&&!req.hwrite) begin 
  for(int i=0;i<=req.hwdata.size();i++) begin
    if(i==0) begin
      htrans = 2;
      intf.HTRANS <= htrans;
      intf.HBURST <= req.hburst;
      intf.HWRITE <= req.hwrite;
      intf.HSIZE  <= req.hsize;
      @(posedge intf.clk);
      intf.HRDATA <= req.hwdata[i];
                
      //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HRDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver", intf.HADDR, intf.HRDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
    end
    else  begin
      htrans = 0;
      intf.HTRANS <= htrans;
      intf.HADDR  <= 32'hx;
      @(posedge intf.clk);
      //`uvm_info(get_type_name(),$sformatf("HADDR=%0h,HRDATA=%0h HWRITE=%0d,HSIZE=%0d,HTRANS=%0d in driver",intf.HADDR,intf.HRDATA,intf.HWRITE,intf.HSIZE,intf.HTRANS), UVM_MEDIUM);
    end
  end
end
endtask

    
//writing task for INCR read and write    
task ahb_driver::incr(); 
  /*****************INCR WRITE LOGIC********************************/      
  if(req.hwrite && (req.hburst == INCR || req.hburst == INCR4 || req.hburst == INCR8 || req.hburst == INCR16)) begin
    intf.HWRITE <= req.hwrite;
    intf.HSIZE  <= req.hsize;
    intf.HBURST <= req.hburst;
    for(int i = 0;i <= req.hwdata.size();i++) begin
      if(i==0) begin
        htrans=2;
        intf.HTRANS <= htrans;
        haddr_drv = req.haddr;
        intf.HADDR <= haddr_drv;
        @(posedge intf.clk);
        intf.HWDATA <= req.hwdata[i];
        //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver", intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
      end         
      if(i>0) begin
        if(i==req.hwdata.size()) begin
          htrans = 0;
          intf.HTRANS <= htrans;
          intf.HADDR  <= 32'dx;
          @(posedge intf.clk);
        end
        else begin
          haddr_drv = haddr_drv+(2**req.hsize);
          htrans = 3;
          intf.HTRANS <= htrans;
          intf.HADDR  <= haddr_drv;
          @(posedge intf.clk);
          intf.HWDATA <= req.hwdata[i];
        end
       //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
      end
    end
  end
      
/***************INCR READ LOGIC**********************************/
if(!req.hwrite&& (req.hburst == INCR || req.hburst == INCR4 || req.hburst == INCR8 || req.hburst == INCR16)) begin
  intf.HWRITE <= req.hwrite;
  intf.HSIZE  <= req.hsize;
  intf.HBURST <= req.hburst;
  for(int i=0;i<=req.hwdata.size();i++) begin
    if(i==0) begin
      htrans = 2;
      intf.HTRANS <= htrans;
      haddr_drv = req.haddr;
      //intf.HADDR<=haddr_drv;
      @(posedge intf.clk);
      intf.HRDATA<=req.hwdata[i];
      //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HRDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
    end
               
    if(i > 0) begin
      if(i == req.hwdata.size()) begin
        htrans = 0;
        intf.HTRANS <= htrans;
        intf.HADDR  <= 32'dx;
        @(posedge intf.clk);
      end
      else begin
        haddr_drv   = haddr_drv+(2**req.hsize);
        htrans      = 3;
        intf.HTRANS <= htrans;
        @(posedge intf.clk);
        intf.HRDATA <= req.hwdata[i];
      end
      //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HRDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HRDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
    end
   end
 end     
endtask
    
// writing task for wrap read & write 
task ahb_driver::wrap();  
/********************WRAP WRITE LOGIC******************************/
if(req.hwrite&&(req.hburst == WRAP4 || req.hburst == WRAP8 || req.hburst == WRAP16)) begin
  intf.HWRITE <= req.hwrite;
  intf.HSIZE  <= req.hsize;
  intf.HBURST <= req.hburst;
  ahb_driver::wrap_logic();
  for(int i=0;i<=req.hwdata.size();i++) begin
    if(i==0) begin
      htrans = 2;
      intf.HTRANS <= htrans;
      intf.HADDR  <= qu[i];
      @(posedge intf.clk);
      intf.HWDATA <= req.hwdata[i];
      //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
    end
    if(i>0) begin
      if(i == req.hwdata.size()) begin
        htrans = 0;
        intf.HTRANS <= htrans;
        intf.HADDR  <= 32'dx;
        @(posedge intf.clk);
      end
      else  begin
        htrans = 3;
        intf.HTRANS <= htrans;
        intf.HADDR  <= qu[i];
        @(posedge intf.clk)
        intf.HWDATA <= req.hwdata[i];
      end
      //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
   end
 end
end

/*********************WRAP READ LOGIC***********************************/      
if(!req.hwrite&&(req.hburst == WRAP4 || req.hburst == WRAP8 || req.hburst == WRAP16)) begin
  intf.HWRITE <= req.hwrite;
  intf.HSIZE  <= req.hsize;
  intf.HBURST <= req.hburst;
  ahb_driver::wrap_logic();
  for(int i = 0;i <= req.hwdata.size();i++) begin
    if(i==0) begin
      htrans = 2;
      intf.HTRANS <= htrans;
      intf.HADDR  <= qu[i];
      @(posedge intf.clk);
      intf.HWDATA <= req.hwdata[i];
      //`uvm_info(get_type_name(),$sformatf("HADDR = %0h, HWDATA = %0h, HWRITE = %0d, HSIZE = %0d, HTRANS = %0d in driver",intf.HADDR, intf.HWDATA, intf.HWRITE, intf.HSIZE, intf.HTRANS), UVM_MEDIUM);
    end
    if(i>0) begin
      if(i==req.hwdata.size())  begin
        htrans = 0;
        intf.HTRANS <= htrans;
        intf.HADDR  <= 32'dx;
        @(posedge intf.clk);
      end
      else begin
        htrans = 3;
        intf.HTRANS <= htrans;
        @(posedge intf.clk)
        intf.HRDATA <= req.hwdata[i];
      end
      //`uvm_info(get_type_name(),$sformatf("HADDR=%0h,HWDATA=%0h HWRITE=%0d,HSIZE=%0d,HTRANS=%0d in driver",intf.HADDR,intf.HWDATA,intf.HWRITE,intf.HSIZE,intf.HTRANS),UVM_MEDIUM);
    end
  end
end
endtask
    
task ahb_driver::wrap_logic();
/********************WRITE WRAP LOGIC************************/      
if(req.hwrite == 1) begin
  foreach(req.hwdata[i]) begin
    if(i == 0) begin
      st_addr = req.haddr;
      qu.push_back(st_addr);
      ahb_driver::aligned_cal();
      $display("st_addr = %0d, alig = %0d,w = %0d",st_addr, aligned_address, wrap_boundary);
    end
    if(i > 0) begin
      if(st_addr == wrap_boundary - (2**req.hsize)) begin
        st_addr = aligned_address;
        qu.push_back(st_addr);
      end
      else begin
        st_addr = st_addr + (2**req.hsize);
        qu.push_back(st_addr);
      end
    end
  end
  $display("%0p",qu);
end
          
/*********for READ WRAP LOGIC*********************************/   
if(!req.hwrite) begin
  foreach(req.hwdata[i]) begin
    if(i == 0) begin
      st_addr = intf.HADDR;
      qu.push_back(st_addr);
      ahb_driver::aligned_cal();
      $display("alig=%0d,w=%0d",aligned_address,wrap_boundary);
    end
    if(i > 0) begin
      if(st_addr == wrap_boundary - (2**req.hsize)) begin
        st_addr = aligned_address;
        qu.push_back(st_addr);
      end
      else begin
        st_addr = st_addr+(2**req.hsize);
        qu.push_back(st_addr);
      end
    end
  end
  $display("%0p",qu);
end
endtask
    
task ahb_driver::aligned_cal();
  if(req.hburst == WRAP4) begin
    aligned_address = st_addr - (st_addr%((2**req.hsize)*4));
    wrap_boundary   = aligned_address + ((2**req.hsize)*4);
  end
  if(req.hburst == WRAP8) begin
    aligned_address = st_addr - (st_addr%((2**req.hsize)*8));
    wrap_boundary   = aligned_address+((2**req.hsize)*8);
  end
  if(req.hburst == WRAP16) begin
    aligned_address = st_addr - (st_addr%((2**req.hsize)*16));
    wrap_boundary   = aligned_address+((2**req.hsize)*16);
  end
endtask
