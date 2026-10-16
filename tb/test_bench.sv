`timescale 1ns/1ps

module test_bench;
   import uvm_pkg::*;
   import apb_pkg::*;


   /** Instance APB Interface */
   apb_if   apb_vif();
   timer_if timer_vif();
   apb_configuration apb_cfg;

   timer_top dut(.sys_clk      (apb_vif.pclk),
                 .sys_rst_n    (apb_vif.prst_n),
		 // APB interface
		 .tim_psel     (apb_vif.psel),
		 .tim_pwrite   (apb_vif.pwrite),
		 .tim_penable  (apb_vif.penable),
		 .tim_paddr    (apb_vif.paddr),
		 .tim_pwdata   (apb_vif.pwdata),
		 .tim_pstrb    (apb_vif.pstrb),
		 .tim_pready   (apb_vif.pready),
		 .tim_prdata   (apb_vif.prdata),
		 .tim_pslverr  (apb_vif.pslverr),
		 // Timer interface
		 .dbg_mode     (timer_vif.dbg_mode),
		 .tim_int      (timer_vif.tim_int),
		 .pwm_out      (timer_vif.pwm_out),
		 .pwm_int      (timer_vif.pwm_int)
		 );

   initial begin
      apb_vif.pclk = 0;
      #10;
      forever #2.5 apb_vif.pclk = ~apb_vif.pclk;
   end

   initial begin
      apb_vif.prst_n = 0;
      #20;
      apb_vif.prst_n = 1;
   end

   /** Set VIP interface on the environment */
   initial begin
      uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top","apb_vif",apb_vif);
      uvm_config_db#(virtual timer_if)::set(null,"uvm_test_top","timer_vif",timer_vif);
      apb_cfg = new();
      uvm_config_db#(apb_configuration)::set(null,"uvm_test_top","apb_cfg",apb_cfg);

      /** Start the UVM tets */
      run_test();
   end
endmodule
