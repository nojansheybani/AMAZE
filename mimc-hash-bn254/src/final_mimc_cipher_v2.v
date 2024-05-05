//  @author : Secure, Trusted, and Assured Microelectronics (STAM) Center
//
//  Copyright (c) 2024 STAM Center (SCAI/ASU)
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


// Module that implements MiMC block cipher (exponent = 7, rounds = 91).

module final_mimc_cipher_v2 #(
	parameter N_BITS = 254
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] in,
	input  [N_BITS-1:0] key,
	output [N_BITS-1:0] out,
	output done
);

mimc_cipher #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD("peasant"),
	.GALOIS_POW_7_METHOD("parallel"),
	.MIMC_CIPHER_ROUND_METHOD("v2")
) MIMC_CIPHER (
	.clk(clk),
	.rst(rst),
	.en(en),
	.in(in),
	.key(key),
	.out(out),
	.done(done)
);

endmodule
