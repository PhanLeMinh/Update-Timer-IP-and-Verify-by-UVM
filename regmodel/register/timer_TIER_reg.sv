class timer_TIER_reg extends uvm_reg;
   `uvm_object_utils(timer_TIER_reg)

        uvm_reg_field rsvd  ; // [31:1]
   rand uvm_reg_field int_en; // [0]

   function new(string name = "timer_TIER_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      rsvd   = uvm_reg_field::type_id::create("rsvd");
      int_en = uvm_reg_field::type_id::create("int_en");

      // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
      rsvd.configure(this,31,1,"RO",0,31'h0,1,0,1);
      int_en.configure(this,1,0,"RW",0,1'b0,1,1,1);

   endfunction


endclass
