`timescale 1ns/1ps

module test_bench;
reg sys_clk;
reg sys_rst_n;
reg tim_psel;
reg tim_pwrite;
reg tim_penable;
reg tim_dbg_mode;
reg [11:0] tim_paddr;
reg [31:0] tim_pwdata;
reg [3 :0] tim_pstrb;
wire [31:0] tim_prdata;
wire tim_pslverr;
wire tim_int;
wire tim_pready;

parameter   ADDR_TCR    =   12'h0;
parameter   ADDR_TDR0   =   12'h4;
parameter   ADDR_TDR1   =   12'h8;
parameter   ADDR_TCMP0  =   12'hC;
parameter   ADDR_TCMP1  =   12'h10;
parameter   ADDR_TIER   =   12'h14;
parameter   ADDR_TISR   =   12'h18;
parameter   ADDR_THCSR  =   12'h1C;

timer_top dut(
        .sys_clk      (sys_clk    ),
        .sys_rst_n    (sys_rst_n  ),
        .tim_psel     (tim_psel   ),
        .tim_pwrite   (tim_pwrite ),
        .tim_penable  (tim_penable),
        .dbg_mode (tim_dbg_mode),
        .tim_paddr    (tim_paddr  ),
        .tim_pwdata   (tim_pwdata ),
        .tim_pstrb   (tim_pstrb ),
        .tim_pready   (tim_pready ),
        .tim_prdata   (tim_prdata ),
        .tim_pslverr  (tim_pslverr),
        .tim_int      (tim_int    )

);

initial begin
        sys_clk = 0;
        forever #25 sys_clk = ~sys_clk;
end

initial begin
        sys_rst_n = 0;
        #25;
        sys_rst_n = 1;
end

task apb_write(input [11:0] addr, input [31:0] data);
	begin
		@(posedge sys_clk);
		tim_psel <= 1;
		tim_pwrite <= 1;
		tim_penable <= 0;
		tim_paddr <= addr;
		tim_pwdata <= data;
		tim_pstrb <= 4'hf;
		@(posedge sys_clk);
		tim_penable <= 1;
		wait(tim_pready);
		@(posedge sys_clk);
		tim_psel <= 0;
		tim_pwrite <= 0;
		tim_penable <= 0;
	end

endtask

task apb_read(input [11:0] addr, output [31:0] data);
	begin
		@(posedge sys_clk);
		tim_psel <= 1;
		tim_pwrite <= 0;
		tim_paddr <= addr;
		@(posedge sys_clk);
		tim_penable <= 1;
		wait(tim_pready);
		data = tim_prdata;
		@(posedge sys_clk);
		tim_psel <= 0;
		tim_penable <= 0;
	end
endtask

reg [31:0] rdata;
initial begin
        tim_psel = 0;
        tim_penable = 0;
        tim_pwrite = 0;
        tim_paddr = 32'h0;
        tim_pwdata = 32'h0;
        tim_pstrb = 4'b0;
        tim_dbg_mode = 0;
	wait(sys_rst_n == 1);
	$display("---Start Write---");
	apb_write(ADDR_TCR, 32'h0004_0007);
	repeat(200) @(posedge sys_clk);
	$display("---Capture Data---");
	apb_read(ADDR_TDR0, rdata);
	$display("TDR0; 32'd%0d", rdata);
        $finish;
end

endmodule
