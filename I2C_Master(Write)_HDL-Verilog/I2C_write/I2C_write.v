`timescale 1ns/1ns

module I2C_write(CLK,SCLK,SDIN,regdata,GO,ACK,reset,rstACK,ACK1,ACK2,ACK3,ldnACK1,ldnACK2,ldnACK3);

input CLK;
input GO;
input reset;
input [26:0] regdata;
inout SDIN;
output SCLK;
output ACK,ACK1,ACK2,ACK3,ldnACK1,ldnACK2,ldnACK3;
output rstACK;

reg [4:0] bitcount;
reg [26:0] Q;
reg ACK1,ACK2,ACK3;
wire SEL;
wire LDEN,SHEN,retbitcount;
wire bitcounEN,SCLK_Temp;
wire ldnACK1,ldnACK2,ldnACK3;
wire SDO;

//引入控制器(狀態機)
I2C_control I2C_control_0
(
.reset(reset),
.CLK(CLK),
.GO(GO),
.bitcount(bitcount[4:0]),
.SCLK_Temp(SCLK_Temp),
.bitcountEN(bitcountEN),
.rstbitcount(rstbitcount),
.LDEN(LDEN),
.ldnACK1(ldnACK1),
.ldnACK2(ldnACK2),
.ldnACK3(ldnACK3),
.rstACK(rstACK),
.SHEN(SHEN),
.SDO(SDO),
.SCLK(SCLK)
);

//計數器
always @(posedge CLK or posedge reset)
begin
	if(reset)
		bitcount<=0;
	else
	begin
		if(rstbitcount)
			bitcount<=0;
		else if(bitcountEN)
			bitcount<=bitcount+1;
	end
end

//並串接輸入&串接輸出移位暫存器
always @(posedge CLK or posedge reset)
begin
	if(reset)
		Q<=0;
	else
	begin
		if(LDEN)
			Q<=regdata;
		else if(SHEN)
		begin
			Q[26:1]<=Q[25:0];
			Q[0]<=0;
		end
	end
end

//具載入功能與同步清除功能之暫存器
always @(posedge CLK or posedge reset)
begin
	if(reset)
	begin
		ACK1<=1'b0;
		ACK2<=1'b0;
		ACK3<=1'b0;
	end
	else if(rstACK)
	begin
		ACK1<=1'b0;
		ACK2<=1'b0;
		ACK3<=1'b0;
	end
	else
	begin
		if(ldnACK1)
			ACK1<=SDIN;
		if(ldnACK2)
			ACK2<=SDIN;
		if(ldnACK3)
			ACK3<=SDIN;
	end
end

//多工器
	//多工器一
	assign SEL=SHEN?Q[26]:SDO;
	//多工器二
	assign SDIN=SEL?1'bz:0;

//三輸入OR GATE
assign ACK=ACK1|ACK2|ACK3;

endmodule