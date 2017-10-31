module LFSR (
    clk,
    rst,
    rnd_valid_out,
    rnd
    );

input clk;
input rst;
output rnd_valid_out;
output [31:0] rnd;

//reg [31:0] rnd;
wire [31:0] rnd;
reg 	[31:0]	fifo_data[15:0];
reg [3:0]	data_count;
reg [31:0] random, random_next, random_done;
reg [5:0] cnt, cnt_next; //to keep track of the shifts
wire fb = random[31] ^ random[21] ^ random[1] ^ random[0];
wire rnd_valid_out;
reg rnd_valid;
assign rnd_valid_out=rnd_valid;

always @(posedge clk)
begin
 	if (!rst)
 	begin
		//data_count<='d0;

		fifo_data[0]<='d526;
		fifo_data[1]<='d873;
		fifo_data[2]<='d137;
		fifo_data[3]<='d36;
		fifo_data[4]<='d432;
		fifo_data[5]<='d989;
		fifo_data[6]<='d566;
		fifo_data[7]<='d325;
		fifo_data[8]<='d23;
		fifo_data[9]<='d98;
		fifo_data[10]<='d900;
		fifo_data[11]<='d17;
		fifo_data[12]<='d691;
		fifo_data[13]<='d784;
		fifo_data[14]<='d3209;
		fifo_data[15]<='d321;
 	end
 	else
 	begin
		//data_count<=data_count+1;
		//rnd<=fifo_data[data_count];
 	end
end


always @ (posedge clk)
begin
 if (!rst)
 begin
  random <= 32'hF; //An LFSR cannot have an all 0 state, thus rst to FF
  cnt <= 0;
  rnd_valid<=1'b0;
  data_count<='d0;
  //random_done<=32'hFFFFFFFF;
 end

 else
 begin
  random <= random_next;
  cnt <= cnt_next;
  if (cnt == 32)
  begin
  cnt <= 0;
  rnd_valid<=1'b1;
  data_count<=data_count+1;
  random_done = random; //assign the random number to output after 32 shifts
  end
  else if(rnd_valid)
  	rnd_valid<=1'b0;
	 

 end
end

always @ (*)
begin
 random_next = random; //default state stays the same
 cnt_next = cnt;

  random_next = {random[30:0], fb}; //shift left the xor'd every posedge clk
  cnt_next = cnt + 1;

/* if (cnt == 32)
 begin
  cnt = 0;
  random_done = random; //assign the random number to output after 32 shifts
 end
  */
end


assign rnd = random_done;

endmodule
