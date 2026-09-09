module counter(
	input clk,
	input rst_n,
	input cnt_en,
	input [3:0] pstrb,
	input [31:0] wdata, //from register
	input tdr0_wr_sel, //from register
	input tdr1_wr_sel, //from register
	input timer_en_neg, //from register
	output [63:0] cnt 
);

parameter CNT_DEFAULT = 32'h0;
wire [31:0] cnt0_tmp;
wire [31:0] cnt1_tmp;
wire [63:0] cnt_plus_1;
reg [31:0] cnt0;
reg [31:0] cnt1;

// counter 31-0
assign cnt0_tmp[7:  0] = pstrb[0] & tdr0_wr_sel ? wdata[7:0] : timer_en_neg ? 8'h0 : 
	                                 		             cnt_en ? cnt_plus_1[7:  0] : cnt0[7:0];
assign cnt0_tmp[15: 8] = pstrb[1] & tdr0_wr_sel ? wdata[15:8] :timer_en_neg ? 8'h0 :
                                                                     cnt_en ? cnt_plus_1[15: 8] : cnt0[15:8];
assign cnt0_tmp[23:16] = pstrb[2] & tdr0_wr_sel ? wdata[23:16] : timer_en_neg ? 8'h0 :
                                                                     cnt_en ? cnt_plus_1[23:16] : cnt0[23:16];
assign cnt0_tmp[31:24] = pstrb[3] & tdr0_wr_sel ? wdata[31:24] : timer_en_neg ? 8'h0 :
                                                                     cnt_en ? cnt_plus_1[31:24] : cnt0[31:24];

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		cnt0 <= CNT_DEFAULT;
	end
	else begin 
		cnt0 <= cnt0_tmp;
	end
end	

// counter 63-32
assign cnt1_tmp[7:  0] = pstrb[0] & tdr1_wr_sel ? wdata[7:  0]: timer_en_neg ? 8'h0 :
                                                                      cnt_en ? cnt_plus_1[39:32] : cnt1[7:0];
assign cnt1_tmp[15: 8] = pstrb[1] & tdr1_wr_sel ? wdata[15: 8]: timer_en_neg ? 8'h0 :
                                                                      cnt_en ? cnt_plus_1[47:40] : cnt1[15:8];
assign cnt1_tmp[23:16] = pstrb[2] & tdr1_wr_sel ? wdata[23:16]: timer_en_neg ? 8'h0 :
                                                                      cnt_en ? cnt_plus_1[55:48] : cnt1[23:16];
assign cnt1_tmp[31:24] = pstrb[3] & tdr1_wr_sel ? wdata[31:24]: timer_en_neg ? 8'h0 :
                                                                      cnt_en ? cnt_plus_1[63:56] : cnt1[31:24];

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		cnt1 <= CNT_DEFAULT;
	end
	else begin
		cnt1 <= cnt1_tmp;
	end
end

assign cnt_plus_1 = cnt + 1'b1;
assign cnt = {cnt1, cnt0};


endmodule
