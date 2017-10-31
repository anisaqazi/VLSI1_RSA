module encryption_key(	clk,
			reset_n,
			phi_n,
			e,
			d,
			start_compute,
			done_compute	
		);

input 		clk;
input		reset_n;
input	[63:0]	phi_n;
input		start_compute;
output	[63:0]	e;
output		done_compute;
output	[63:0]	d;

wire 		clk;
wire		reset_n;
wire	[63:0]	phi_n;
wire		start_compute;
reg	[63:0]	e;
wire	[63:0]	d;
reg		done_compute;

reg	eucli_loop_start;
wire	eucli_loop_done;
wire	[63:0]	gcd;

reg [10:0 ]num_cycles;

reg [1:0] state;
reg [1:0] next_state;
parameter IDLE=2'd0, COMPUTE_INITIALIZE=2'd1, COMPUTE=2'd2,  END=2'd3;


euclidean_loop	euclidean_loop_inst(	.clk		(clk),
					.reset_n	(reset_n),
					.start_compute	(eucli_loop_start),	
					.a		(phi_n),
					.b		(e),
					.d_out		(d),
					.a_out		(gcd),
					.done		(eucli_loop_done));

always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
		state	<= 2'b0;
	else	
		state 	<= next_state;
end

always @(*)
begin
	case(state)
		IDLE:			begin
						if(start_compute)
							next_state=COMPUTE_INITIALIZE;
						else
							next_state=IDLE;
					end
		COMPUTE_INITIALIZE:	begin
						next_state=COMPUTE;
				 
					end
		COMPUTE:		begin
						if(eucli_loop_done)
						begin
							if((gcd != 'd1)||(d[63]))
								next_state=COMPUTE_INITIALIZE;
							else
								next_state=END;	
						end
					end
		END:			begin
						if(start_compute==1'b0)
							next_state=IDLE;	
						
					end
	endcase 	
	
end

always @(posedge clk)
begin
	if(~reset_n)
	begin
		done_compute 	<= 'd0;
		e		<= 'd1;	
		eucli_loop_start<= 'd0;
		num_cycles	<= 'd0;		
	end
	else
	begin
		if(next_state==IDLE)
		begin
			done_compute 	<= 0;
			num_cycles	<= 'd0;	
			if(start_compute)
				e		<= 'd1;
		end	
		else if(next_state==COMPUTE_INITIALIZE)
		begin
			e		<= e + 'd2;
		end
		else if(next_state==COMPUTE)
		begin
			num_cycles<=num_cycles+1;
			if(num_cycles==0)
				eucli_loop_start<='d1;
			else
				eucli_loop_start<='d0;
		end
		else if(next_state==END)
		begin
			done_compute	<= 1;
			eucli_loop_start<='d0;
		end
	end
end

endmodule
