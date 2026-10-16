class timer_TDR0_reg extends uvm_reg;
   `uvm_object_utils(timer_TDR0_reg)

   rand uvm_reg_field tdr0; // [31:0]

   function new(string name = "timer_TDR0_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction 

   virtual function void build();
      tdr0 = uvm_reg_field::type_id::create("tdr0");

      // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
      tdr0.configure(this,32,0,"RW",1,32'h0,1,1,1);
   endfunction
endclass


