task run_test();
	reg [31:0] task_rdata;
	reg [31:0] tcr_val;
	integer i;
	begin
		$display("=======================================");
		$display("===== Test case: Cnt Crtl Check =======");
		$display("=======================================");

		test_bench.write_pstrb(ADDR_TCR, 32'h0, BIT_FULL_1); //reset timer
		test_bench.write_pstrb(ADDR_TCR, 32'h0000_0003, BIT_FULL_1); //enable timer = 1, div_en = 1 => control mode 
		test_bench.read(ADDR_TCR, task_rdata);
		repeat(50) @(posedge test_bench.sys_clk);
		//reset 
		#100;
                $display("assert reset");
                test_bench.sys_rst_n = 1'b0;
                #100;
                @(posedge test_bench.sys_clk);
                #1;
                $display("release reset");
                test_bench.sys_rst_n = 1'b1;

		for(i = 0;i <= 8; i = i + 1) begin
                        // cau hinh tcr_val
                        tcr_val = {20'h0, i[3:0], 6'h0, 1'b1, 1'b1};
                        test_bench.write_pstrb(ADDR_TCR, tcr_val, BIT_FULL_1);
                        test_bench.read(ADDR_TCR, task_rdata);
                        repeat(900) @(posedge test_bench.sys_clk);
			#100;
                $display("assert reset");
                test_bench.sys_rst_n = 1'b0;
                #100;
                @(posedge test_bench.sys_clk);
                #1;
                $display("release reset");
                test_bench.sys_rst_n = 1'b1;
		test_bench.write_pstrb(ADDR_TCR, 32'h0, BIT_FULL_1);
                end



		// div_en = 1 , div_val = 3 => limit = 7
		test_bench.write_pstrb(ADDR_TCR, 32'h0, BIT_FULL_1); //reset timer
		test_bench.write_pstrb(ADDR_TCR, 32'h0000_0203, BIT_FULL_1);
	        test_bench.read(ADDR_TCR, task_rdata);
		if(task_rdata[0] !== 32'h1) begin
                        $display("t = %0t ERROR: timer_en bit not set correctly!", $time);
                end else begin
                        $display("t = %0t PASSED: timer_en bit set correctly!", $time);
                end

		if(task_rdata[1] !== 32'h1) begin
			$display("t = %0t ERROR: div_en not set correctly", $time);
		end else if(task_rdata[11:8] !== 4'd3) begin
			$display("t = %0t ERROR: div_val not set correctly", $time);
		end else begin
			$display("t = %0t PASSED: div_en & div_val set correctly", $time);
		end

		//check counter increase slower than sys_clk
		repeat(50) @(posedge test_bench.sys_clk);
		test_bench.write_pstrb(ADDR_THCSR, 32'h0000_0001, BIT_FULL_1); // halt_req = 1
		test_bench.read(ADDR_THCSR, task_rdata);
		repeat(10) @(posedge test_bench.sys_clk);
		test_bench.write_pstrb(ADDR_THCSR, 32'h0000_0000, BIT_FULL_1); //halt_req = 0
		test_bench.read(ADDR_THCSR, task_rdata);
		repeat(50) @(posedge test_bench.sys_clk);

		

	end
endtask
