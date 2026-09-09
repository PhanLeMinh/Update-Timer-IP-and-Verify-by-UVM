module register(
	input clk,	
	input rst_n,
	input [11:0] addr,
	input [31:0] wdata,
	input wr_en,
	input rd_en,
	input [3:0] pstrb,
	input [63:0] cnt,
	input debug_mode,
	output tim_int,
	output reg div_en,
	output reg [3:0] div_val,
	output halt_req_out,
	output reg timer_en,
	output[31:0] rdata,
        output pslverr,
	output timer_en_neg,
	output tdr0_wr_sel,
	output tdr1_wr_sel,
	
	output reg div_mode,
	output reg pwm_en,
	output reg [15:0] prescaler
);

parameter ADDR_TCR   = 12'h00; 
parameter ADDR_TDR0  = 12'h04;  
parameter ADDR_TDR1  = 12'h08;
parameter ADDR_TCMP0 = 12'h0C;
parameter ADDR_TCMP1 = 12'h10;
parameter ADDR_TIER  = 12'h14;
parameter ADDR_TISR  = 12'h18;
parameter ADDR_THCSR = 12'h1C;

parameter TCR_DEFAULT   = 32'h0000_0100; 
parameter TDR0_DEFAULT  = 32'h0000_1000;
parameter TDR1_DEFAULT  = 32'h0000_0000;
parameter TCMP0_DEFAULT = 32'hFFFF_FFFF;
parameter TCMP1_DEFAULT = 32'hFFFF_FFFF;
parameter TIER_DEFAULT  = 32'h0000_0000;
parameter TISR_DEFAULT  = 32'h0000_0000;
parameter THCSR_DEFAULT = 32'h0000_0000;

// kHAI BAO
// TCR
reg  [31:0] tcr_r;
wire timer_en_tmp;
wire div_en_tmp;
wire [3:0] div_val_tmp;
wire div_val_timer_en_err;
wire div_en_timer_en_err;
wire div_val_err;
wire [31:0] tcr_tmp;
reg timer_en_1d;

wire [15:0] prescaler_tmp;
wire div_mode_tmp;
wire pwm_en_tmp;
wire pwm_en_timer_en_err;


// TCMP0
reg  [31:0] tcmp0_r;
wire [31:0] tcmp0_tmp;

// TCMP1
reg  [31:0] tcmp1_r;
wire [31:0] tcmp1_tmp;

// TIER
reg  [31:0] tier_r;
wire int_en;
wire [31:0] tier_tmp;

// TISR
reg  [31:0] tisr_r;
wire int_st;
wire [31:0] tisr_tmp;
wire int_clr;
wire int_set;
wire pwm_int_st; // new

// THCSR
reg  [31:0] thcsr_r;
wire halt_ack;
reg  halt_req_r;
wire [31:0] thcsr_tmp;

reg  [31:0] rdata_r;
reg  [7 :0] reg_sel;
// Decoder
always @(*) 
begin
	case(addr)
		ADDR_TCR  :    reg_sel = 8'b0000_0001;
		ADDR_TDR0 :    reg_sel = 8'b0000_0010;
		ADDR_TDR1 :    reg_sel = 8'b0000_0100;
		ADDR_TCMP0:    reg_sel = 8'b0000_1000;
		ADDR_TCMP1:    reg_sel = 8'b0001_0000;
		ADDR_TIER :    reg_sel = 8'b0010_0000;
		ADDR_TISR :    reg_sel = 8'b0100_0000;
		ADDR_THCSR:    reg_sel = 8'b1000_0000;
		default:  reg_sel = 8'b0000_0000;
	endcase
end

// TCR
// reg_sel[0]
always @(posedge clk or negedge rst_n) 
begin
        if(!rst_n) begin
                timer_en_1d <= 1'b0;
        end else begin
                timer_en_1d <= timer_en;
        end 
end

assign timer_en_neg = ~timer_en & timer_en_1d;

// timer_en RW, bit 0
assign timer_en_tmp = (pstrb[0] & wr_en & reg_sel[0] & ~pslverr)  ? wdata[0] : timer_en;
// div_en RW, bit 1
assign div_en_tmp = (pstrb[0] & wr_en & reg_sel[0] & ~pslverr)    ? wdata[1] : div_en;
// div_mode RW, bit 2
assign div_mode_tmp = (pstrb[0] & wr_en & reg_sel[0] & ~pslverr)  ? wdata[2] : div_mode;
// pwm_en RW, bit 3
assign pwm_en_tmp = (pstrb[0] & wr_en & reg_sel[0] & ~pslverr)    ? wdata[3] : pwm_en;

// div_val RW, bit [11:8]
assign div_val_tmp = ((wdata[11:8] <= 8) & wr_en & reg_sel[0] & ~pslverr & pstrb[1])   ? wdata[11:8] : div_val;
// prescaler, bit [31:16]
assign prescaler_tmp[7: 0] = (pstrb[2] & wr_en & reg_sel[0] & ~pslverr) ? wdata[23:16] : prescaler[7:0];
assign prescaler_tmp[15:8] = (pstrb[3] & wr_en & reg_sel[0] & ~pslverr) ? wdata[31:24] : prescaler[15:8];

// Error
assign div_val_err = (pstrb[1] & reg_sel[0]) & (wdata[11:8] > 8);
assign div_val_timer_en_err = (pstrb[1] & wr_en & reg_sel[0]) & (wdata[11:8] != div_val) & timer_en;
assign div_en_timer_en_err = (pstrb[0] & wr_en & reg_sel[0]) & (wdata[1] != div_en) & timer_en;
assign pwm_en_timer_en_err = (pstrb[0] & wr_en & reg_sel[0]) & (wdata[3] != pwm_en) & timer_en;
assign pslverr = div_val_err | div_val_timer_en_err | div_en_timer_en_err | pwm_en_timer_en_err;
// TCR

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		div_en <= 0;
		div_val <= 4'b0001;
		timer_en <= 0;
		div_mode <= 0;
		pwm_en <= 0;
		prescaler <= 0;
	end
	else begin
		div_en <= div_en_tmp;
		div_val <= div_val_tmp;
		timer_en <= timer_en_tmp;
		div_mode <= div_mode_tmp;
		pwm_en <= pwm_en_tmp;
		prescaler <= prescaler_tmp;
	end
end


assign tdr0_wr_sel = wr_en & reg_sel[1]; 
assign tdr1_wr_sel = wr_en & reg_sel[2];

// TCMP0
// reg_sel[3]
assign tcmp0_tmp[7:  0] = (pstrb[0] & wr_en & reg_sel[3]) ? wdata[7:0] : tcmp0_r[7:0];
assign tcmp0_tmp[15: 8] = (pstrb[1] & wr_en & reg_sel[3]) ? wdata[15:8] : tcmp0_r[15:8];
assign tcmp0_tmp[23:16] = (pstrb[2] & wr_en & reg_sel[3]) ? wdata[23:16] : tcmp0_r[23:16];
assign tcmp0_tmp[31:24] = (pstrb[3] & wr_en & reg_sel[3]) ? wdata[31:24] : tcmp0_r[31:24];
always @(posedge clk or negedge rst_n)
begin
        if(!rst_n) begin
                tcmp0_r <= TCMP0_DEFAULT;
        end 
        else begin
                tcmp0_r <= tcmp0_tmp;
        end 
end

// TCMP1
// reg_sel[4]
assign tcmp1_tmp[7:  0] = (pstrb[0] & wr_en & reg_sel[4]) ? wdata[7:0] : tcmp1_r[7:0];
assign tcmp1_tmp[15: 8] = (pstrb[1] & wr_en & reg_sel[4]) ? wdata[15:8] : tcmp1_r[15:8];
assign tcmp1_tmp[23:16] = (pstrb[2] & wr_en & reg_sel[4]) ? wdata[23:16] : tcmp1_r[23:16];
assign tcmp1_tmp[31:24] = (pstrb[3] & wr_en & reg_sel[4]) ? wdata[31:24] : tcmp1_r[31:24];
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		tcmp1_r <= TCMP1_DEFAULT;
	end 
	else begin
		tcmp1_r <= tcmp1_tmp;
	end
end

// Compare value with counter
wire [63:0] compare_val; 
assign compare_val = {tcmp1_r, tcmp0_r};

// TIER
// reg_sel[5]
// Bit[0] int_en 
assign int_en = (pstrb[0] & wr_en & reg_sel[5]) ? wdata[0] : tier_r[0];  
assign tier_tmp = {31'h0, int_en};
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		tier_r <= TIER_DEFAULT;
	end
	else begin
		tier_r <= tier_tmp;
	end
end

// TISR
// reg_sel[6]
// Bit[0] int_st
// Bit[1] pwm_int_st - flag interrupt of PWM
assign int_set = (cnt == compare_val);
assign int_clr = pstrb[0] & wr_en & wdata[0]  & reg_sel[6] ;

//assign int_st  = int_clr ? 1'b0 :
	         //int_set ? 1'b1 : tisr_r[0];
assign int_st = tisr_r[0];
//assign tisr_tmp = {31'h0, int_st};
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		tisr_r <= TISR_DEFAULT;
	end else if(int_clr) begin
		tisr_r[0] <= 1'b0;
		//tisr_r <= {31'h0, int_st};
	end else if(int_set) begin
		tisr_r[0] <= 1'b1;
	end
	else begin
		tisr_r[0] <= tisr_r[0];
	end

end

// Interrupt
// int_st xay ra khi cnt 64 bit == tcmp 64 bit 
// int_en = 1 moi xuat ra output
assign tim_int = int_st & int_en;


// THCSR
// halt_ack bit 1 RO
// halt_req bit 0 RW
// reg_se[7]
assign halt_req = (pstrb[0] & wr_en & reg_sel[7]) ? wdata[0]: halt_req_r;
assign halt_ack = halt_req_r & debug_mode;
assign halt_req_out =  halt_ack;
assign thcsr_tmp = {30'h0, halt_ack, halt_req_r};
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		halt_req_r <= 1'b0;
	end
	else begin
		halt_req_r <= halt_req;
	end
end

// READ
always @(*)
begin
	if(rd_en) 
	begin
		case(addr)
               		 ADDR_TCR  :    rdata_r = {prescaler, 4'h0, div_val[3:0], 4'h0, pwm_en, div_mode, div_en, timer_en};
               		 ADDR_TDR0 :    rdata_r = cnt[31:0];
               		 ADDR_TDR1 :    rdata_r = cnt[63:32];
               		 ADDR_TCMP0:    rdata_r = tcmp0_r;
               		 ADDR_TCMP1:    rdata_r = tcmp1_r;
               		 ADDR_TIER :    rdata_r = tier_r;
               		 ADDR_TISR :    rdata_r = tisr_r;
               		 ADDR_THCSR:    rdata_r = thcsr_tmp;
               		 default:  rdata_r = 32'h0;
        	endcase
	end
	else begin
		rdata_r = 32'h0;
	end
end

assign rdata = rdata_r;


endmodule
