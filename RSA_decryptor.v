module RSA_decryptor (  clk,
			rst,
			encrypted_message,
			msg_received_sig,
			n,
			decrypted_message,
			donegcd,
			encrypt_key
			);
			
input [63:0] encrypted_message;
input clk,rst;
input msg_received_sig;
output donegcd;
output[63:0] decrypted_message;
output[63:0] n;
output [63:0]encrypt_key;

wire done_decrypt;
wire clk;
wire rst;
wire [31:0] random;
wire full;
wire empty;
wire [31:0] fifo_out;
wire [31:0] prime_out;
wire full1;
wire empty1;
wire [31:0]fifo_out1;
wire [63:0]decrypt_key;
wire [63:0]encrypt_key;
wire donegcd;
wire doneprimality;
wire is_prime;
reg start_primality;
reg start_gcd;
reg [31:0] p;
reg [31:0] q;
wire [63:0] n;
wire [63:0] phi_n;
wire write_fifo;
reg [1:0]  count_prime_rd;
wire read_fifo2;
reg read_fifo2_del;
//assign start_primality =  1'b1;


assign n = p * q;
assign phi_n = (p-1) * (q-1);
assign read_fifo2=(~empty1 && ~count_prime_rd[1]);

always @(posedge clk)
begin
	if(~rst)
		read_fifo2_del<=1'b0;
	else
		read_fifo2_del<=read_fifo2;
end

always @ (posedge clk)
begin

	if(~rst)
	begin
		start_primality <= 'd1;
		p <= 'd0;
		q <= 'd0;
		count_prime_rd<='d0;
		start_gcd<='d0;
		//read_fifo2<=1'b0;
	end
	else
	begin
		if(doneprimality)
			start_primality <= 1'b1;
		else if(start_primality && ~empty)
			start_primality <= 1'b0;
		
		
		if(read_fifo2_del&&count_prime_rd==2'b00)
		begin
			p <= fifo_out1;	
			count_prime_rd<=count_prime_rd+1;
		end
		else if(read_fifo2_del && count_prime_rd==2'b01)
		begin
			q<= fifo_out1;
			count_prime_rd<=count_prime_rd+1;
			start_gcd<='d1;
		end
		if(start_gcd)
			start_gcd<='d0;
			
	end
end

LFSR LFSR1 (
		.clk(clk),
		.rst(rst),
		.rnd_valid_out(write_fifo),
		.rnd(random)
	   );

fifo fifo1 ( .clk(clk),
	    .reset_n(rst),
	    .data_in(random),
	    .write(write_fifo),
	    .read(~empty && start_primality),
	    .fifo_full(full),
	    .fifo_empty(empty),
	    .data_out(fifo_out)
	    );
primality_tester primality1 (
			.clock(clk),
			.reset(rst),
			.start_pt(~empty && start_primality),
			.number(fifo_out),
			.prime_out(prime_out),//check for 0
			.done(doneprimality),
			.is_prime(is_prime)
		     );

fifo fifo2 ( .clk(clk),
	    .reset_n(rst),
	    .data_in(prime_out),
	    .write(doneprimality && is_prime),
	    .read(read_fifo2),
	    .fifo_full(full1),
	    .fifo_empty(empty1),
	    .data_out(fifo_out1)
	    );

encryption_key encryption_key1(
				.clk(clk),
				.reset_n(rst),
				.phi_n(phi_n),//from multiply
				.e(encrypt_key),
				.d(decrypt_key),	
				.start_compute(start_gcd),//from multiply
				.done_compute(donegcd)
			      );
modexp1 modexp_decrypt_inst 
	(
	.clk(clk),
	.rst(rst),
	.base(encrypted_message),
	.exponent(decrypt_key),
	.modulus(n),//from multiply
	.C(decrypted_message),
	.done(msg_received_sig), //input
	.done_encrypt(done_decrypt)  //output

	); 

endmodule
