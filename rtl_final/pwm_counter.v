module pwm_counter(
		   input clk,
		   input rst_n,
		   input pwm_tick, //from counter control
		   input pwm_en, //from register
		   input [31:0] period, //from TCMP0 register
		   output [31:0] pwm_cnt,
		   output pwm_period_match
		   );

reg [31:0] pwm_cnt_r;
wire [31:0] pwm_cnt_tmp;

assign pwm_cnt_tmp = pwm_period_match ? 32'b0 :
                                        pwm_tick ? pwm_cnt_r + 1 : pwm_cnt_r;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin	
		pwm_cnt_r <= 0;
	end
	else begin
		pwm_cnt_r <= pwm_cnt_tmp;
	end
end

assign pwm_cnt = pwm_cnt_r;
assign pwm_period_match = (pwm_cnt == period);
	
endmodule
