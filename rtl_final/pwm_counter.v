module pwm_counter(
		   input clk,
		   input rst_n,
		   input pwm_en,
		   input pwm_tick, //from counter control
		   input [31:0] tcmp0_period, //from TCMP0 register
		   input [31:0] tcmp1_duty, //from TCMP1 register
		   output [31:0] tdr0_pwm_cnt,
		   output pwm_period_match,
		   output pwm_out
		   );
parameter TDR0_DEFAULT = 32'b0;
reg [31:0] tdr0_pwm_cnt_r;
wire [31:0] pwm_cnt_tmp;

assign pwm_cnt_tmp = pwm_period_match ? 32'b0 :
                                        pwm_tick ? tdr0_pwm_cnt_r + 1 : tdr0_pwm_cnt_r;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin	
		tdr0_pwm_cnt_r <= TDR0_DEFAULT;
	end
	else begin
		tdr0_pwm_cnt_r <= pwm_cnt_tmp;
	end
end

assign tdr0_pwm_cnt = tdr0_pwm_cnt_r;
assign pwm_period_match = (tdr0_pwm_cnt == tcmp0_period) & pwm_tick;
assign pwm_out = !pwm_en ? 0 : (tdr0_pwm_cnt < tcmp1_duty) ? 1 : 0;
	
endmodule
