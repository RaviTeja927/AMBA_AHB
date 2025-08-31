// ahb_sequence class, contains sequences related to increment, increment4/8/16
//wrap4/8/16 and random sequence

class single_wr extends uvm_sequence #(ahb_seq_item);
  
  `uvm_object_utils(single_wr)
  
  function new(string name="single_wr");
    super.new(name);
  endfunction
  
 virtual task body();
  // repeat(3)
     // begin
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==SINGLE && req.hwrite==1 && req.haddr==40;foreach(hwdata[i]) hwdata[i] inside {[17:27]}; };
    finish_item(req);
    
 /* req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==SINGLE && req.hwrite==1 && req.haddr==44;foreach(hwdata[i]) hwdata[i] inside {[10:20]}; };
    finish_item(req);*/
    
   /* req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==SINGLE && req.hwrite==1 && req.haddr==48;foreach(hwdata[i]) hwdata[i] inside {[30:50]}; };
    finish_item(req);*/
     // end
   /* repeat(2)
     begin
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
       req.randomize() with{req.hburst==SINGLE && req.hwrite==0;};
    finish_item(req);
      end*/
  endtask
endclass

class incr extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(incr)
  
  function new(string name="incr");
      super.new(name);
    endfunction
  
  task body();
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==INCR && req.hwrite==1 && req.haddr==36 &&req.hsize==1;foreach(req.hwdata[i]) req.hwdata[i] inside{[11:51]};};
    finish_item(req);
   
    /* start_item(req);
    req.randomize() with{req.hburst==INCR && req.hwrite==0&&req.hsize==1;foreach(req.hwdata[i]) req.hwdata[i] inside{[11:51]};};
    finish_item(req);*/  
  endtask
endclass

class incr_4 extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(incr_4)
  
  function new(string name="incr_4");
      super.new(name);
    endfunction
  
  task body();
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==INCR4 && req.hwrite==1 &&req.hsize==2 &&req.haddr==56;foreach(req.hwdata[i]) req.hwdata[i] inside{[25:75]};};
    finish_item(req);
    
   /* start_item(req);
    req.randomize() with{req.hburst==INCR4 && req.hwrite==0 &&req.hsize==2;foreach(req.hwdata[i]) req.hwdata[i] inside{[25:75]};};
    finish_item(req);*/
  endtask
endclass

class incr_8 extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(incr_8)
  
  function new(string name="incr_8");
      super.new(name);
    endfunction
  
  task body();
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==INCR8 && req.hwrite==1 &&req.hsize==1 && req.haddr==52;foreach(req.hwdata[i])
      req.hwdata[i] inside {[27:37]};};
    finish_item(req);  
  endtask
endclass
       

class incr_16 extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(incr_16)
  
  function new(string name="incr_16");
      super.new(name);
    endfunction
  
  task body();
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==INCR16 && req.hwrite==1  &&req.hsize==2;req.haddr==80;foreach(req.hwdata[i])
     req. hwdata[i] inside {[60:90]};};
    finish_item(req);   
  endtask
endclass


class wrap_4 extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(wrap_4)
  
  function new(string name="wrap_4");
      super.new(name);
    endfunction
  
  task body();
    req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==WRAP4 && req.hwrite==1 &&req.hsize==2;req.haddr==56;foreach(req.hwdata[i])hwdata[i] inside{[41:51]};};
    finish_item(req);
    
    /* start_item(req);
    req.randomize() with{req.hburst==WRAP4 && req.hwrite==0 &&req.hsize==2;foreach(req.hwdata[i])hwdata[i] inside{[41:51]};};
    finish_item(req);*/
  endtask
endclass


class wrap_8 extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(wrap_8)
  
  function new(string name="wrap_8");
      super.new(name);
    endfunction
  
  task body();
    //repeat(3) begin
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==WRAP8 && req.hwrite==1 &&req.hsize==2;req.haddr==52;foreach(req.hwdata[i])hwdata[i] inside{[71:91]};};
    finish_item(req);
    //end
  endtask
endclass


class wrap_16 extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(wrap_16)
  
  function new(string name="wrap_16");
      super.new(name);
    endfunction
  
  task body();
    //repeat(3) begin
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hburst==WRAP16 && req.hwrite==1 &&req.hsize==2;req.haddr==28;foreach(req.hwdata[i])hwdata[i] inside{[31:61]};};
    finish_item(req);
    //end
  endtask
endclass

class rand_seq extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(rand_seq)
  
  function new(string name="rand_seq");
      super.new(name);
    endfunction
  
  task body();
    repeat(5) begin
     req=ahb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize() with{req.hwrite==1&&req.hsize==2;req.haddr==28;foreach(req.hwdata[i])hwdata[i] inside{[111:155]};};
    finish_item(req);
    end
  endtask
endclass
