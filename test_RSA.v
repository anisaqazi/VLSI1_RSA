module test_RSA;


reg 		clk;
reg 		reset_n;
reg [63:0]	Message;

wire [63:0]	decrypted_message;
wire [63:0]	encrypted_message;
wire [63:0]	n;
wire [63:0]	encrypt_key;

initial 
begin
	clk = 1'b0;
	reset_n = 1'b0;
	#40;
	reset_n = 1'b1;
	Message = 'd2321;
	#4000000;
	Message = 'd8;
	#4000000;
	Message = 'd542;
	#4000000;
	Message = 'd1580;
	#4000000;
	Message = 'd1453;
	#4000000;
	Message = 'd874;
	#4000000000000;
end

always 
	#20 clk = ~clk;


RSA_decryptor RSA_decryptor_inst(.clk			(clk),
				.rst			(reset_n),
				.encrypted_message	(encrypted_message),
				.msg_received_sig	(done_encrypt),
				.n			(n),
				.decrypted_message	(decrypted_message),
				.donegcd		(donegcd),
				.encrypt_key		(encrypt_key)
			);

RSA_encryptor RSA_encryptor_inst(	.clk		(clk),
					.rst		(reset_n),
					.Message	(Message),//from TB
					.encrypted_msg	(encrypted_message),
					.n		(n),
					.exponent	(encrypt_key),
					.public_key_rcvd(donegcd),
					.done_encrypt	(done_encrypt));


endmodule
