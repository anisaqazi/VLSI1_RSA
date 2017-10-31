module primality_tester(clock,reset,number,prime_out,start_pt,is_prime,done);

input clock,reset,start_pt;
input [31:0] number;
output [31:0] prime_out;
output done;
output is_prime;
wire [31:0] number;
reg [31:0] temp_reg;
reg [31:0] s_reg;
reg [31:0] prime_out;
reg [31:0] a_reg;
reg [31:0] i_reg;
reg [31:0] v_reg;
//wire [31:0] temp_vreg;
reg start_check;
reg [1:0] pt_state;
reg [1:0] pt_next_state;
reg [2:0] ch_next_state;
reg [2:0] ch_state;
reg [2:0] count;
reg is_prime;
reg done;
reg exp_req;
wire exp_done;
wire[31:0] exponent;
parameter PT_IDLE=2'd0,PT_INITIALIZE=2'd1,PT_COMPUTE=2'd2,PT_END=2'd3;
parameter CH_IDLE=0,CH_V_CHECK=2,CH_INITIALIZE=1,CH_COMPUTE=3,CH_END=4;

pt_exp exp_inst
	(
	.clk(clock),
	.rst(reset),
	.base(a_reg),
	.exponent(s_reg),
	.modulus(number),//from multiply
	.C(exponent),
	.done(exp_req), //input
	.done_encrypt(exp_done)  //output
	);

always @ (posedge clock)
begin
	if(!reset)
	begin
		 pt_state <= 2'b0;
		 ch_state <= 3'b0;
		

	end
	else
	begin
		pt_state <= pt_next_state;		
		ch_state <= ch_next_state;
	end
end

always @ (posedge clock)
begin
	if(!reset)
	begin
                 s_reg <= 1;
                 temp_reg <= 0;
		 start_check <= 0;

	end
	else
	begin
		if(pt_next_state==PT_IDLE)
		begin
			if (start_check == 1)
				start_check <= 0;
		end
		if(pt_next_state==PT_INITIALIZE)
		begin
			s_reg <= 1;
			temp_reg <=0;
			
		end
		if(pt_next_state==PT_COMPUTE)
                begin   
			if(s_reg % 2 ==0)
			begin
				s_reg <= (s_reg/2);
                	        temp_reg <=temp_reg +1;
			end
			else
			begin
				temp_reg <= 0;
        	                s_reg <= number -1;
			end
                end
		if(pt_next_state == PT_END)
		begin
                        	start_check <= 1;

		end

	end
end


always @(*)
begin

	case(pt_state)
		PT_IDLE:if(start_pt ==1)
		begin
			pt_next_state  = PT_INITIALIZE;
		end
		else
		begin
			pt_next_state  = PT_IDLE;

		end
		PT_INITIALIZE:
		begin
			pt_next_state  = PT_COMPUTE;
		end

		PT_COMPUTE:if(s_reg % 2 ==0)
		begin
			pt_next_state  = PT_COMPUTE;
				
		end
		else
		begin
			pt_next_state  = PT_END;

		end

		PT_END:
		begin
			pt_next_state  = PT_IDLE;		
		end
		endcase

end


always @ (posedge clock)
begin
	if(!reset)
        begin
                 count <= 0;
                 a_reg <= 0;
                 v_reg <= 0;
                 prime_out <= 0;
		 exp_req <=0;
		 done <=0;
		 is_prime <= 1; 

        end
	else 			
	begin
        	if(ch_next_state == CH_IDLE) 	
		begin			
				done <=0;	
				count <=0;
		end

		if(ch_next_state  == CH_INITIALIZE)
		begin
			if(s_reg % 2 !=0)
			begin
        	                a_reg <= 2;
				i_reg <=0;
				is_prime <=1;
			end
			else
				is_prime <=1;
				
			count <=  count + 1;	
		end	
		if(ch_next_state  == CH_V_CHECK)
        	begin
			if(ch_state == CH_INITIALIZE) 
				exp_req <= 1;
			if(exp_req)
				exp_req <=0;
		
		end
		if(ch_next_state  == CH_COMPUTE)
        	begin
			if(v_reg == 1)
        	        begin
        	              is_prime <= 1;

			end
			else 
			begin
				if(v_reg != number -1 )
        		        begin
        		                if(i_reg == temp_reg -1)
        	        	        begin
						is_prime <= 0;

	        	                end
        		                else
        		                begin
        	        	                i_reg <= i_reg +1;
        	                	        v_reg <= (v_reg ** 2) % number;
	
        		                end
				end
        			else
    		    	       	begin
						is_prime <=1;

		                end
			end

        	end
		if(ch_next_state  == CH_END)
        	begin
			
        	        if(count == 5)
				done <= 1; 
			if(number % 2 ==0)
			begin
				prime_out <= 0;
				is_prime<=0;
				done <= 1;	
			end
			else if(is_prime || v_reg == 1)
				prime_out <= number;
			else
				prime_out <= 0;
		end
		if(exp_done)
			v_reg <= exponent;
	
	end	

end
always @(*)
begin

        case(ch_state)
                CH_IDLE:if(start_check == 1)
                begin
                        ch_next_state  = CH_INITIALIZE;
                end
		else
		begin
			ch_next_state  = CH_IDLE;
		end
                CH_INITIALIZE:if(number %2 != 0)
                begin
			ch_next_state  = CH_V_CHECK;
                end
		else
					
			ch_next_state  = CH_END;
		
		CH_V_CHECK:if(v_reg != 1 && exp_done)
		begin 
			ch_next_state  = CH_COMPUTE;
		end
		else if (~exp_done)
		begin
			ch_next_state  = CH_V_CHECK;
		end
		else
		begin
			ch_next_state  = CH_END;

		end
                CH_COMPUTE:if(v_reg != number -1)
                begin
			if(!is_prime)
			begin
				ch_next_state  = CH_END;

			end
			else
			begin
				ch_next_state  = CH_COMPUTE;

			end
	
                end
                else
                begin
                        ch_next_state  = CH_END;

                end

                CH_END:if((count == 5)||(number%2 =='d0))
                begin
                        ch_next_state  = CH_IDLE;
                end
		else
		begin
			ch_next_state  = CH_INITIALIZE;
		end
       	endcase

end
endmodule

