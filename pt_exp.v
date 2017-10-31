module pt_exp(base,exponent,modulus,clk,rst,C,done,done_encrypt);
input wire[31:0] base;
input wire[31:0]exponent;
input wire[31:0]modulus;
input clk;
input rst;
output [31:0] C;
input done;
output done_encrypt;

reg [31:0] C;
reg[31:0] Cint;
reg[63:0] baseint;
reg [31:0] exponentint;
reg [31:0] Caftmod;
//reg [5:0]count;
reg[31:0] rem;
reg done_encrypt;
reg beginsignal;

 
always @(posedge clk)
begin
	if(!rst)
	begin
		C<=32'h0000_0000;
		baseint<=0;
	//	count<=0;
		exponentint <= 0;
		 Cint <=32'h0000_0001;
	 	Caftmod<=32'h0000_0001;
	 	//count<=0;
		rem<=exponent%2;
		done_encrypt<=0;
		rem<=0;
		beginsignal<=0;


	end 
	else 
	begin
		if(done)
		begin
		baseint<=base;
		exponentint<=exponent;
		beginsignal<=1;
		rem<=exponent%2;
		beginsignal<=1;
		end

		
		if(!exponentint && beginsignal)
			begin
			C<=Caftmod;
			done_encrypt<=1;
			
		if(done_encrypt==1 && beginsignal)
		begin
			done_encrypt<=0;
			beginsignal<=0;
			Caftmod<=1;
		end

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
				//count<=count+1;
			end
			else 
			begin	
				if(exponentint%2==1 && beginsignal)
				begin
					Caftmod<=(Caftmod*baseint)%modulus;
					baseint<=(baseint*baseint)%modulus;
					exponentint<=exponentint/2;
				//	count<=count+1;
				end
			end
		end
	end
end

endmodule
