class timer_TISR_reg extends uvm_reg;
   `uvm_object_utils(timer_TISR_reg)

        uvm_reg_field rsvd      ; // [31:2]
   rand uvm_reg_field pwm_int_st; // [1]
   rand uvm_reg_field int_st    ; // [0]

   function new(string name = "timer_TISR_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      rsvd   = uvm_reg_field::type_id::create("rsvd");
      pwm_int_st = uvm_reg_field::type_id::create("pwm_int_st");
      int_st     = uvm_reg_field::type_id::create("int_st");

      // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
      rsvd.configure(this      ,30,2,"RO" ,0,31'h0,1,0,1);
      pwm_int_st.configure(this, 1,1,"R1C",1,1'b0 ,1,1,1);
      int_st.configure(this    , 1,0,"R1C",1,1'b0 ,1,1,1);

   endfunction


endclass
