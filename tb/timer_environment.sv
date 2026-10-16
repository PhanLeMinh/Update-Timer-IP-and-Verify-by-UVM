class timer_environment extends uvm_env;
   `uvm_component_utils(timer_environment)

   apb_agent apb_agt;
   timer_scoreboard timer_scb;

   virtual apb_if apb_vif;
   apb_configuration apb_cfg;

   timer_reg_block       reg_model;
   timer_reg2apb_adapter apb_adapter;

   uvm_reg_predictor#(apb_transaction) apb_predictor;

   function new(string name = "timer_environment",uvm_component parent);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_vif",apb_vif))
         `uvm_fatal(get_type_name(),"Failed to get apb_vif from uvm_config_db")
      if(!uvm_config_db#(apb_configuration)::get(this,"","apb_cfg",apb_cfg))
         `uvm_fatal(get_type_name(),"Failed to get apb_cfg from uvm_config_db")
      
      apb_agt   = apb_agent::type_id::create("apb_agent",this);
      timer_scb = timer_scoreboard::type_id::create("timer_scoreboard",this);

      uvm_config_db#(virtual apb_if)::set(this,"apb_agent","apb_vif",apb_vif);
      uvm_config_db#(apb_configuration)::set(this,"apb_agent","apb_cfg",apb_cfg);

      reg_model     = timer_reg_block::type_id::create("reg_model");
      reg_model.build();

      apb_adapter   = timer_reg2apb_adapter::type_id::create("apb_adapter");
      apb_predictor = uvm_reg_predictor#(apb_transaction)::type_id::create("apb_predictor",this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(reg_model.apb_map.get_parent() == null) begin
         reg_model.apb_map.set_sequencer(apb_agt.apb_seq, apb_adapter);
      end

      // Connect monitor to Scoreboard
      apb_agt.apb_mon.item_observed_port.connect(timer_scb.apb_collect_export);

      // Predictor connect
      apb_predictor.map     = reg_model.apb_map;
      apb_predictor.adapter = apb_adapter;
      apb_agt.apb_mon.item_observed_port.connect(apb_predictor.bus_in);
   endfunction

endclass
