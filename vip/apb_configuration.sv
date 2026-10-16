class apb_configuration extends uvm_object;
   bit is_active = 1;

   `uvm_object_utils_begin (apb_configuration)
      `uvm_field_int (is_active, UVM_ALL_ON | UVM_HEX)
   `uvm_object_utils_end

   function new(string name = "apb_configuration");
      super.new(name);
   endfunction
endclass
