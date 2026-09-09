class apb_driver extends uvm_driver;
	`uvm_component_utils(apb_driver)

	function new(string name = "apb_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);	
		super.build_phase(phase);
	endfunction

	virtual task driver();
	endtask
endclass
