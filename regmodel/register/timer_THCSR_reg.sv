class timer_THCSR_reg extends uvm_reg;
   `uvm_object_utils(timer_THCSR_reg)

        uvm_reg_field rsvd    ; // [31:2]
        uvm_reg_field halt_ack; // [1]
   rand uvm_reg_field halt_req; // [0]

   function new(string name = "timer_THCSR_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      rsvd = uvm_reg_field::type_id::create("rsvd");
      halt_ack = uvm_reg_field::type_id::create("halt_ack");
      halt_req = uvm_reg_field::type_id::create("halt_req");

      // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
      rsvd.configure(this,30,2,"RO",0,30'h0,1,0,1);
      halt_ack.configure(this,1,1,"RO",1,1'b0,1,1,1);
      halt_req.configure(this,1,0,"RW",0,1'b0,1,1,1);
   endfunction

endclass
