class timer_TCR_reg extends uvm_reg;
   `uvm_object_utils(timer_TCR_reg)

   rand uvm_reg_field prescaler; // [31:16]
        uvm_reg_field rsvd0    ; // [15:12]
   rand uvm_reg_field div_val  ; // [11: 8]
        uvm_reg_field rsvd1    ; // [7 : 4]
   rand uvm_reg_field pwm_en   ; // [3]
   rand uvm_reg_field div_mode ; // [2]
   rand uvm_reg_field div_en   ; // [1]
   rand uvm_reg_field timer_en ; // [0]

   function new(string name = "timer_TCR_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction 

   constraint div_val_c {div_val.value <= 8;};

   virtual function void build();
      rsvd0     = uvm_reg_field::type_id::create("rsvd0");
      rsvd1     = uvm_reg_field::type_id::create("rsvd1");
      timer_en  = uvm_reg_field::type_id::create("timer_en");
      div_mode  = uvm_reg_field::type_id::create("div_mode");
      pwm_en    = uvm_reg_field::type_id::create("pwm_en");
      div_val   = uvm_reg_field::type_id::create("div_val");
      div_en    = uvm_reg_field::type_id::create("div_en");
      prescaler = uvm_reg_field::type_id::create("prescaler");
      
      // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
      prescaler.configure(this,16,16,"RW",0,16'h0,1,1,1);
      rsvd0.configure(this    ,4, 12,"RO",0,4'b0,1,0,1);
      div_val.configure(this  ,4,  8,"RW",0,4'b0001,1,1,1);
      rsvd1.configure(this    ,4,  4,"RO",0,4'b0,1,0,1);
      pwm_en.configure(this   ,1,  3,"RW",0,1'b0,1,1,1);
      div_mode.configure(this ,1,  2,"RW",0,1'b0,1,1,1);
      div_en.configure(this   ,1,  1,"RW",0,1'b0,1,1,1);
      timer_en.configure(this ,1,  0,"RW",0,1'b0,1,1,1);

   endfunction
endclass
