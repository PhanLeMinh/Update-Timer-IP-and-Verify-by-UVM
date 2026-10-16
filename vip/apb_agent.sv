class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent)

	apb_driver    apb_drv;
	apb_monitor   apb_mon;
	apb_sequencer apb_seq;

	virtual apb_if apb_vif;
	apb_configuration apb_cfg;

	function new(string name = "apb_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_vif",apb_vif))
		   `uvm_fatal(get_type_name(),"Failed to get apb_vif from uvm_config_db")
		if(!uvm_config_db#(apb_configuration)::get(this,"","apb_cfg",apb_cfg))
                   `uvm_fatal(get_type_name(),"Failed to get apb_cfg from uvm_config_db")

		if(is_active) begin
		   `uvm_info(get_type_name(),"Active agent is configured",UVM_LOW)
		   apb_drv = apb_driver::type_id::create("apb_driver",this);
		   apb_mon = apb_monitor::type_id::create("apb_monitor",this);
		   apb_seq = apb_sequencer::type_id::create("apb_sequencer",this);

		   uvm_config_db#(virtual apb_if)::set(this,"apb_driver","apb_vif",apb_vif);
		   uvm_config_db#(virtual apb_if)::set(this,"apb_monitor","apb_vif",apb_vif);
		   uvm_config_db#(apb_configuration)::set(this,"apb_driver","apb_cfg",apb_cfg);
		   uvm_config_db#(apb_configuration)::set(this,"apb_monitor","apb_cfg",apb_cfg);
		end
		else begin
		   `uvm_info(get_type_name(),"Passive agent is configured",UVM_LOW)
		   apb_mon = apb_monitor::type_id::create("apb_monitor",this);

		   uvm_config_db#(virtual apb_if)::set(this,"apb_monitor","apb_vif",apb_vif);
		   uvm_config_db#(apb_configuration)::set(this,"apb_monitor","apb_cfg",apb_cfg);
		end
	endfunction

	virtual function void connect_phase(uvm_phase phase);
	   super.connect_phase(phase);
	   if(get_is_active() == UVM_ACTIVE) begin
	      apb_drv.seq_item_port.connect(apb_seq.seq_item_export);
	   end
	endfunction
endclass
