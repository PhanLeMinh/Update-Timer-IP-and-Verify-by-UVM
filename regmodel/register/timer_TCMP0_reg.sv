class timer_TCMP0_reg extends uvm_reg;
   `uvm_object_utils(timer_TCMP0_reg)

   rand uvm_reg_field tcmp0; // [31:0]

   function new(string name = "timer_TCMP0_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction 

   virtual function void build();
      tcmp0 = uvm_reg_field::type_id::create("tcmp0");

      // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
      tcmp0.configure(this,32,0,"RW",0,32'hFFFF_FFFF,1,1,1);
   endfunction
endclass


