interface apb_if();
	logic pclk;
	logic prst_n;
	logic psel;
        logic pwrite;
	logic penable;
	logic [`APB_ADDR_WIDTH-1:0] paddr;
	logic [`APB_DATA_WIDTH-1:0] pwdata;
	logic [3:0] pstrb;
	logic pready;
	logic [`APB_DATA_WIDTH-1:0] prdata;
	logic pslverr;

	clocking drv_cb @(posedge pclk);
	   default input #1step output #1;
	   input pready;
	   input prdata;
	   input pslverr;
	   
	   output psel;
	   output pwrite;
	   output penable;
	   output paddr;
	   output pwdata;
	   output pstrb;
	endclocking

	clocking mon_cb @(posedge pclk);
	   default input #1step;
	   input prst_n;
	   input psel;
	   input pwrite;
	   input penable;
	   input paddr;
	   input pwdata;
	   input pstrb;
	   input pready;
	   input prdata;
	   input pslverr;
	endclocking

endinterface
