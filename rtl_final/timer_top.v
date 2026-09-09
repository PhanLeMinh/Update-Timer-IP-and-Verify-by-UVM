module timer_top(
	input sys_clk,
	input sys_rst_n,
	input tim_psel,
	input tim_pwrite,
	input tim_penable,
	input dbg_mode,
	input [11:0] tim_paddr,
	input [31:0] tim_pwdata,
	input [3 :0] tim_pstrb,
	output 	      tim_pready,
	output [31:0] tim_prdata,
	output        tim_pslverr,
	output        tim_int
);
wire write_en;
wire read_en ;
wire div_en  ;
wire [3:0] div_val;
wire halt_req;
wire timer_en;
wire [63:0] count;
wire count_en;
wire tdr0_wr_sel;
wire tdr1_wr_sel;
wire timer_en_neg;

wire div_mode;
wire pwm_en;
wire [15:0] prescaler;

	apb_slave module1(
			  .clk        (sys_clk    ),
			  .rst_n      (sys_rst_n  ),
			  .psel	      (tim_psel   ),
			  .pwrite     (tim_pwrite ),
			  .penable    (tim_penable),
			  .wr_en      (write_en   ),
			  .rd_en      (read_en    ),
			  .pready     (tim_pready )
	);

	register module2(
                          .clk        (sys_clk    ),  
                          .rst_n      (sys_rst_n  ),
			  .addr       (tim_paddr  ),
		   	  .wdata      (tim_pwdata ),
			  .wr_en      (write_en   ),
			  .rd_en      (read_en    ),
			  .pstrb      (tim_pstrb  ),
			  .cnt        (count      ),
			  .debug_mode (dbg_mode),
			  .tim_int    (tim_int    ),
			  .div_en     (div_en     ),
			  .div_val    (div_val    ),
			  .halt_req_out   (halt_req   ),
			  .timer_en   (timer_en   ),
			  .rdata      (tim_prdata ),
			  .pslverr    (tim_pslverr),
			  .timer_en_neg(timer_en_neg),
			  .tdr0_wr_sel(tdr0_wr_sel),
			  .tdr1_wr_sel(tdr1_wr_sel),
			  .div_mode   (div_mode),
			  .pwm_en     (pwm_en),
			  .prescaler  (prescaler)
	);

	counter_control module3(
	 		  .clk        (sys_clk    ),
                          .rst_n      (sys_rst_n  ),
			  .div_en     (div_en     ),
			  .div_val    (div_val    ),
			  .halt_req   (halt_req   ),
			  .timer_en   (timer_en   ),
			  .debug_mode (dbg_mode   ),
			  .cnt_en     (count_en   ),
			  .div_mode   (div_mode   ),
			  .prescaler  (prescaler  )
	);

	counter module4(
			  .clk        (sys_clk    ),
                          .rst_n      (sys_rst_n  ),
			  .wdata      (tim_pwdata ),
			  .pstrb      (tim_pstrb),
			  .cnt_en     (count_en   ),
			  .timer_en_neg(timer_en_neg),
			  .tdr0_wr_sel(tdr0_wr_sel),
			  .tdr1_wr_sel(tdr1_wr_sel),
			  .cnt        (count      )
	);
endmodule
