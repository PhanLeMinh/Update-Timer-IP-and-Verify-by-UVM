module apb_slave(
	input clk,	
	input rst_n,
	input psel,
	input pwrite,
	input penable,
	//input [31:0] pwdata,
	//input [3 :0] pstrb,
	output wr_en,	
	output rd_en,
	output pready
	// output pslverr
);

assign wr_en = psel & pwrite & penable;
assign rd_en = psel & !pwrite & penable;

//PSTRB

//assign wdata[7 : 0] = pstrb[0] ? pwdata[7 : 0] : 8'h0;
//assign wdata[15: 8] = pstrb[1] ? pwdata[15: 8] : 8'h0;
//assign wdata[23:16] = pstrb[2] ? pwdata[23:16] : 8'h0;
//assign wdata[31:24] = pstrb[3] ? pwdata[31:24] : 8'h0;
//pready
//after 1 cycle psel and penable (1,1) 
//DFF
reg pready_r;
assign pready = pready_r;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		pready_r <= 0;
	end
	else if(psel && penable && pwrite) begin // wr_en 
		pready_r <= 1;
	end
	else if(psel & penable & !pwrite) begin // rd_en
		pready_r <= 1;
	end
	else begin
		pready_r <= 0;
	end
end


endmodule
