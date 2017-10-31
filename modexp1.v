module modexp1(base,exponent,modulus,clk,rst,C,done,done_encrypt);
input wire[63:0] base;
input wire[63:0]exponent;
input wire[63:0]modulus;
input clk;
input rst;
output [63:0] C;
input done;
output done_encrypt;

reg [63:0] C;
reg[63:0] Cint;
reg[127:0] baseint;
reg [63:0] exponentint;
reg [63:0] Caftmod;
reg [5:0]count;
reg[63:0] rem;
reg done_encrypt;
reg done_encrypt_del;
reg beginsignal;
reg start;

//assign start=done;

always @(posedge clk)
begin
	if(!rst)
		done_encrypt_del<=0;
	else
		done_encrypt_del<=done_encrypt;
	
end
 
always @(posedge clk)
begin
	if(!rst)
	begin
		C<=64'h0000000000000000;
		//baseint<=base;
		baseint<=0;
		count<=0;
		exponentint <= 0;
		//exponentint <= exponent;
		 Cint <=64'h0000000000000001;
	 	Caftmod<=64'h0000000000000001;
	 	count<=0;
		rem<=0;
		done_encrypt<=0;
		beginsignal<=0;
		
		
		


	end 
	else 
	begin
		if(done||start)
		begin
		baseint<=base;
		exponentint<=exponent;
		beginsignal<=1;
		rem<=exponent%2;
		beginsignal<=1;
		start<=0;
		end
		if(!exponentint && beginsignal)
			begin
			C<=Caftmod;
			done_encrypt<=1;
		end

		if(done_encrypt==1 && beginsignal)
		begin
			done_encrypt<=0;
			beginsignal<=0;
			Caftmod<=1;
			start<=1;
			
		
		end
		else
		begin
			rem<=exponentint%2;

			if(exponentint%2==0 && beginsignal)
			begin
				Cint<=Cint;
				Caftmod<=Caftmod;
				baseint<=(baseint*baseint)%modulus;
				exponentint<=exponentint/2;
				count<=count+1;
			end
			else 
			begin	
				if(exponentint%2==1 && beginsignal)
				begin
					Caftmod<=(Caftmod*baseint)%modulus;
					baseint<=(baseint*baseint)%modulus;
					exponentint<=exponentint/2;
					count<=count+1;
				end
			end
		end
	end
end

endmodule
