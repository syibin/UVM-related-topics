module xor32x2 (in1, in2, out);

input 	[31:0] 		in1;
input 	[31:0] 		in2;
output 	[31:0]		out;

wire 	[31:0]		out;

xor2i0	xor_0	(.A(in1[0]),	.B(in2[0]), 	.Q(out[0]));
xor2i0	xor_1	(.A(in1[1]),	.B(in2[1]), 	.Q(out[1]));
xor2i0	xor_2	(.A(in1[2]),	.B(in2[2]), 	.Q(out[2]));
xor2i0	xor_3	(.A(in1[3]),	.B(in2[3]), 	.Q(out[3]));
xor2i0	xor_4	(.A(in1[4]),	.B(in2[4]), 	.Q(out[4]));
xor2i0	xor_5	(.A(in1[5]),	.B(in2[5]), 	.Q(out[5]));
xor2i0	xor_6	(.A(in1[6]),	.B(in2[6]), 	.Q(out[6]));
xor2i0	xor_7	(.A(in1[7]),	.B(in2[7]), 	.Q(out[7]));
xor2i0	xor_8	(.A(in1[8]),	.B(in2[8]), 	.Q(out[8]));
xor2i0	xor_9	(.A(in1[9]),	.B(in2[9]), 	.Q(out[9]));
xor2i0	xor_10	(.A(in1[10]),	.B(in2[10]), 	.Q(out[10]));
xor2i0	xor_11	(.A(in1[11]),	.B(in2[11]), 	.Q(out[11]));
xor2i0	xor_12	(.A(in1[12]),	.B(in2[12]), 	.Q(out[12]));
xor2i0	xor_13	(.A(in1[13]),	.B(in2[13]), 	.Q(out[13]));
xor2i0	xor_14	(.A(in1[14]),	.B(in2[14]), 	.Q(out[14]));
xor2i0	xor_15	(.A(in1[15]),	.B(in2[15]), 	.Q(out[15]));
xor2i0	xor_16	(.A(in1[16]),	.B(in2[16]), 	.Q(out[16]));
xor2i0	xor_17	(.A(in1[17]),	.B(in2[17]), 	.Q(out[17]));
xor2i0	xor_18	(.A(in1[18]),	.B(in2[18]), 	.Q(out[18]));
xor2i0	xor_19	(.A(in1[19]),	.B(in2[19]), 	.Q(out[19]));
xor2i0	xor_20	(.A(in1[20]),	.B(in2[20]), 	.Q(out[20]));
xor2i0	xor_21	(.A(in1[21]),	.B(in2[21]), 	.Q(out[21]));
xor2i0	xor_22	(.A(in1[22]),	.B(in2[22]), 	.Q(out[22]));
xor2i0	xor_23	(.A(in1[23]),	.B(in2[23]), 	.Q(out[23]));
xor2i0	xor_24	(.A(in1[24]),	.B(in2[24]), 	.Q(out[24]));
xor2i0	xor_25	(.A(in1[25]),	.B(in2[25]), 	.Q(out[25]));
xor2i0	xor_26	(.A(in1[26]),	.B(in2[26]), 	.Q(out[26]));
xor2i0	xor_27	(.A(in1[27]),	.B(in2[27]), 	.Q(out[27]));
xor2i0	xor_28	(.A(in1[28]),	.B(in2[28]), 	.Q(out[28]));
xor2i0	xor_29	(.A(in1[29]),	.B(in2[29]), 	.Q(out[29]));
xor2i0	xor_30	(.A(in1[30]),	.B(in2[30]), 	.Q(out[30]));
xor2i0	xor_31	(.A(in1[31]),	.B(in2[31]), 	.Q(out[31]));

endmodule 
