module euclidean_loop(	clk,
			reset_n,
			start_compute,	
			a,
			b,
			d_out,
			a_out,
			done
		);


input		clk;
input		reset_n;
input		start_compute;	
input	[63:0]	a;
input	[63:0]	b;
output	[63:0]	a_out;
output	[63:0]	d_out;
output		done;

wire		clk;
wire		reset_n;
wire		start_compute;	
wire	[63:0]	a;
wire	[63:0]	b;
reg	 [63:0]	a_out;
reg	 [63:0]	b_reg;

reg	signed [63:0]	y;
reg	signed [63:0]	y_prev;
reg	signed [63:0]	d_out;
reg		done;
reg		done_reg;

reg  signed [63:0]	tmp_b;
wire signed [63:0]	tmp_a_by_b;
wire signed [127:0]	tmp_a_by_b_into_y;

reg [1:0] state;
reg [1:0] next_state;
parameter IDLE=2'd0, COMPUTE=2'd1, CHECK_COMPUTE=2'd2, END=2'd3;


always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		state	<= 2'b0;
		tmp_b	<='d2;
	end
	else	
		state 	<= next_state;
end

always @(*)
begin
	case(state)
		IDLE:	begin
				if(start_compute)
					next_state=COMPUTE;
				else
					next_state=IDLE;	
			end
		COMPUTE:begin
				next_state=CHECK_COMPUTE;
			end
		CHECK_COMPUTE:	begin
				if(b_reg==0)
					next_state=END;
				else
					next_state=COMPUTE;
			end
		END:	begin
				if(~start_compute)
					next_state=IDLE;	
			end
	endcase
end


assign tmp_a_by_b=(a_out/b_reg);
assign tmp_a_by_b_into_y=(tmp_a_by_b*y);

always @(posedge clk)
begin
	if(~reset_n)
	begin
		y	<= 'd0;
		y_prev	<= 'd0;
		a_out	<= 'd0;
		b_reg	<= 'd1;
		done	<= 'd0;
	end
	else
	begin
		if(next_state==IDLE)
		begin
			y	<= 'd1;
			y_prev	<= 'd0;
			a_out	<= a;
			b_reg	<= b;
		      	done	<= 'd0;
		end	
		else if(next_state==COMPUTE)
		begin
			y_prev	<= y;	
			y	<= y_prev-tmp_a_by_b_into_y;
			a_out	<= b_reg;
			b_reg	<= a_out%b_reg;
		end
		else if(next_state==END)
		begin
		      d_out	<= y+y_prev;	
		      done	<= 'd1;
		end
	end
end

always @(posedge clk)
begin
	if(!reset_n)
		done_reg <=0;
	else
		done_reg <=done;
end

endmodule
