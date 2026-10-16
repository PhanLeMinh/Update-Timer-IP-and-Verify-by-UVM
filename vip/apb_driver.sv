class apb_driver extends uvm_driver #(apb_transaction);
	`uvm_component_utils(apb_driver)
	
	virtual apb_if apb_vif;

	function new(string name = "apb_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);	
		super.build_phase(phase);
		if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_vif",apb_vif))
		   `uvm_fatal(get_type_name(),"Failed to get apb_vif from uvm_confif_db.Please check!")
	endfunction

	virtual task run_phase(uvm_phase phase);
	   forever begin
	      seq_item_port.get_next_item(req);
	      `uvm_info(get_type_name(), $sformatf("Driver received transaction: addr=0x%0h data=0x%0h kind=%0s",req.addr,req.data,(req.xact_type == apb_transaction::WRITE) ? "WRITE" : "READ"),UVM_LOW)
	      $cast(rsp,req.clone());
	      rsp.set_id_info(req);

	      driver();

	      seq_item_port.item_done(rsp);
	   end
	endtask

	virtual task driver();
	   apb_vif.drv_cb.psel    <= 0;
	   apb_vif.drv_cb.pwrite  <= 0;
	   apb_vif.drv_cb.penable <= 0;
	   apb_vif.drv_cb.paddr   <= 0;
	   apb_vif.drv_cb.pwdata  <= 0;
	   apb_vif.drv_cb.pstrb   <= 0;
	   wait(apb_vif.prst_n == 1);

	   if(req.xact_type == apb_transaction::WRITE) begin
	      // Set up phase
	      @(apb_vif.drv_cb);
	      apb_vif.drv_cb.psel    <= 1;
	      apb_vif.drv_cb.pwrite  <= 1;
	      apb_vif.drv_cb.paddr   <= req.addr;
	      apb_vif.drv_cb.pwdata  <= req.data;
	      apb_vif.drv_cb.pstrb  <= 4'hF;
	      // Access phase
	      @(apb_vif.drv_cb);
	      apb_vif.drv_cb.penable <= 1;
	      // Wait pready = 1
	      wait(apb_vif.drv_cb.pready == 1'b1);
	      rsp.pslverr = apb_vif.drv_cb.pslverr;
	      `uvm_info(get_type_name(),$sformatf("WRITE complete: addr=0x%0h data=0x%0h ",req.addr,req.data),UVM_LOW)
	      // IDLE phae
	      @(apb_vif.drv_cb);
	      apb_vif.drv_cb.psel    <= 0;
	      apb_vif.drv_cb.pwrite  <= 0;
	      apb_vif.drv_cb.penable <= 0;
	      apb_vif.drv_cb.pwdata  <= 0;
	      apb_vif.drv_cb.paddr   <= 0;
	   end
	   if(req.xact_type == apb_transaction::READ) begin
	      // Set up phase
	      @(apb_vif.drv_cb);
	      apb_vif.drv_cb.psel    <= 1;
              apb_vif.drv_cb.paddr   <= req.addr;
	      apb_vif.drv_cb.pwrite  <= 0;
	      // Access phase
	      @(apb_vif.drv_cb);
	      apb_vif.drv_cb.penable <= 1;
	      // Wait pready = 1
	      wait(apb_vif.drv_cb.pready == 1'b1);
	      rsp.data    = apb_vif.drv_cb.prdata;
	      rsp.pslverr = apb_vif.drv_cb.pslverr;
	      `uvm_info(get_type_name(),$sformatf("READ complete: addr=0x%0h data=0x%0h rec_data=0x%0h",req.addr,req.data,rsp.data),UVM_LOW)
	      // Idle phase
	      @(apb_vif.drv_cb);
	      apb_vif.drv_cb.psel    <= 0;
	      apb_vif.drv_cb.penable <= 0; 
	   end
	endtask
endclass
