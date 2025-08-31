// This interface file contains signals related to ahb
interface ahb_interface (input bit clk);  
  
  logic HRESET;
  logic [31:0] HADDR;
  logic  [1:0]HTRANS;
  logic [2:0] HBURST;
  logic [2:0]HSIZE;
  logic  HWRITE;
  logic [31:0]HWDATA;
  
  logic HREADY;
  logic [31:0]HRDATA;
  logic [1:0] HRESP;
  
/*  clocking cb1 @(posedge clk);
    default input #1 output #2;
    input HADDR;
    input HTRANS;
    input HBURST;
    input HSIZE;
    input HWRITE;
    input HWDATA;
    
    input HREADY;
    input HRDATA;
    input HRESP;
  endclocking
  
  
   clocking cb2 @(posedge clk);
    default input #1 output #2;
    output HADDR;
    output HTRANS;
    output HBURST;
    output HSIZE;
    output HWRITE;
    output HWDATA;
    
    output HREADY;
    output HRDATA;
    output HRESP;
  endclocking
  
  modport drv(clocking cb1 ,input clk);
  modport moni(clocking cb2,input clk);*/
  
endinterface
