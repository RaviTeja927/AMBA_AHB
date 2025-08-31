//Sequence item file, all signals of ahb are randomized here or via the test


typedef enum {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16}h_burst;
typedef enum {BYTE,HALFWORD,WORD}h_size;

class ahb_seq_item extends uvm_sequence_item;
  
  rand bit[31:0]haddr;
  rand bit[31:0]hwdata[];
  rand h_burst hburst;
  rand h_size hsize;
  rand bit hwrite;
  rand bit[2:0] variable;
  bit[1:0] htrans;
  rand logic ready=1;
  logic [31:0]hrdata;
  rand logic[1:0]resp;
  rand int test_var;
  
  `uvm_object_utils_begin(ahb_seq_item)
  `uvm_field_int(haddr, UVM_ALL_ON)
  `uvm_field_enum(h_burst,hburst, UVM_ALL_ON)
  `uvm_field_enum(h_size,hsize, UVM_ALL_ON)
  `uvm_field_array_int(hwdata, UVM_ALL_ON)
  `uvm_field_int(hwrite, UVM_ALL_ON)
  `uvm_field_int(variable,UVM_ALL_ON)
  `uvm_field_int(htrans,UVM_ALL_ON)
  `uvm_field_int(test_var,UVM_ALL_ON)
  `uvm_field_int(ready,UVM_ALL_ON)
  `uvm_field_int(resp,UVM_ALL_ON)
  `uvm_field_int(hrdata,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name="seq_item");
    super.new(name);
  endfunction
  
  constraint c2{if(hburst==SINGLE)
                  hwdata.size==1;
                
               soft if(hburst==INCR)
                  hwdata.size==variable;
                
               if(hburst==WRAP4 || hburst==INCR4) 
                  hwdata.size==4;
                
               if(hburst==WRAP8 || hburst==INCR8) 
                  hwdata.size==8;
                
               if(hburst==WRAP16 || hburst==INCR16)
                  hwdata.size==16;}
  
  constraint c3{soft foreach( hwdata[i])
    hwdata[i] inside {[100:200]};}
 
  constraint c7{ if(hsize==HALFWORD)
                    haddr[0]==0;
                          
                if(hsize==WORD)
                  haddr[1:0]==0;};
                 
endclass
