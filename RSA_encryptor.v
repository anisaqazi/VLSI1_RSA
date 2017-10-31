module RSA_encryptor(	clk,
			rst,
			Message,//from TB
			encrypted_msg,
			n,
			exponent,
			public_key_rcvd,
			done_encrypt);

input [63:0] Message;
input [63:0] exponent;
input clk,rst;
input [63:0] n;
output [63:0] encrypted_msg;
input public_key_rcvd;
output done_encrypt;



modexp1 modexp1_encrypt_inst
	(
	.clk(clk),
	.rst(rst),
	.base(Message),
	.exponent(exponent),
	.modulus(n),//from multiply
	.C(encrypted_msg),
	.done(public_key_rcvd), //input
	.done_encrypt(done_encrypt)  //output
	);



endmodule
