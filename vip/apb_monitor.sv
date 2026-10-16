class apb_monitor extends uvm_monitor;
   `uvm_component_utils(apb_monitor)

   virtual apb_if apb_vif;

   uvm_analysis_port#(apb_transaction) item_observed_port;

   function new(string name = "apb_monitor",uvm_component parent);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      item_observed_port = new("item_observed_port",this);

      if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_vif",apb_vif))
         `uvm_fatal(get_type_name(),"Failed to get apb_vif from uvm_config_db.Please check!")
   endfunction

   virtual task run_phase(uvm_phase phase);
      apb_transaction apb_trans;
      wait(apb_vif.mon_cb.prst_n);

      forever begin
	 @(apb_vif.mon_cb);
	 `uvm_info(get_type_name(),"Start capture APB transaction",UVM_LOW)

	 if((apb_vif.mon_cb.psel && apb_vif.mon_cb.penable && apb_vif.mon_cb.pready)) begin
	    apb_trans = apb_transaction::type_id::create("apb_trans");
	    apb_trans.addr      = apb_vif.mon_cb.paddr;
	    apb_trans.pslverr   = apb_vif.mon_cb.pslverr;

	    if(apb_vif.mon_cb.pwrite) begin
	       apb_trans.xact_type = apb_transaction::WRITE;
	       apb_trans.data      = apb_vif.mon_cb.pwdata;
	    end
	    
	    if(!apb_vif.mon_cb.pwrite) begin
	       apb_trans.xact_type = apb_transaction::READ;
               apb_trans.data      = apb_vif.mon_cb.prdata;
	    end
	    `uvm_info(get_type_name(),$sformatf("Observed transaction: \n%s",apb_trans.sprint()),UVM_LOW)

	    item_observed_port.write(apb_trans);
	 end
      end
   endtask
endclass

