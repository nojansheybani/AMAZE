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


// Module that performs multiplication between two elements in Galois Field with Prime order.
// Performs a large multiplication first and then performs a Barrett reduction.

// Pipelined design: supports multiple in-flight computations.
//     - Latency: 18 clock cycles
//     - Accepts new request in each of the first 6 clock cycles in every 18-clock-cycle period.

// WARNING: Currently, only a field with N_BITS = 254 bits is supported.

// Barrett Reduction Algorithm: https://doi.org/10.1007/3-540-47721-7_24
//     (Refer to Diagram Five)

module galois_mult_barrett_sync #(
	parameter N_BITS = 254,
	parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001, // Size: N_BITS
	parameter R = 255'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925 // Size: N_BITS + 1
) (
	input clk,
	input  [N_BITS-1:0] num1,
	input  [N_BITS-1:0] num2,
	output [N_BITS-1:0] product,
	output reg ready // Indicates: ready to accept new request in the current clock cycle
);

localparam MULT_LATENCY = 6; // Clock cylces
localparam COMPUTE_PHASES = 18;

reg [$clog2(COMPUTE_PHASES)-1:0] compute_phase = 0;

reg [N_BITS-1:0] result;
reg [256-1:0] mult_num1;
reg [256-1:0] mult_num2;
reg [N_BITS:0] w_saved [0:MULT_LATENCY-1];

wire [(2*N_BITS)-1:0] w;
wire [2*(N_BITS+1)-1:0] y;
wire [(2*N_BITS)-1:0] z;
wire [(N_BITS+1)-1:0] x1;
wire [(N_BITS+1)-1:0] x2;
wire [(N_BITS+1)-1:0] x3;
wire [2*256-1:0] mult_product;

// Operation logic
always @(posedge clk) begin
	compute_phase <= (compute_phase + 1'b1) % COMPUTE_PHASES;

	if (0 <= compute_phase && compute_phase <= 5) begin
		w_saved[1] <= w_saved[0];
		w_saved[2] <= w_saved[1];
		w_saved[3] <= w_saved[2];
		w_saved[4] <= w_saved[3];
		w_saved[5] <= w_saved[4];
		mult_num1 <= {2'b0, num1};
		mult_num2 <= {2'b0, num2};
	end else if (6 <= compute_phase && compute_phase <= 11) begin
		w_saved[0] <= w[N_BITS:0];
		w_saved[1] <= w_saved[0];
		w_saved[2] <= w_saved[1];
		w_saved[3] <= w_saved[2];
		w_saved[4] <= w_saved[3];
		w_saved[5] <= w_saved[4];
		mult_num1 <= {1'b0, w[2*N_BITS-1:N_BITS-1]};
		mult_num2 <= {1'b0, R};
	end else if (12 <= compute_phase && compute_phase <= 17) begin
		mult_num1 <= {2'b0, y[2*N_BITS:N_BITS+1]};
		mult_num2 <= {2'b0, PRIME_MODULUS};
	end

	if (0 <= compute_phase && compute_phase <= 5) begin
		ready <= 1'b1;
	end else begin
		ready <= 1'b0;
	end
end

assign w = mult_product[2*N_BITS-1:0];
assign y = mult_product[2*(N_BITS+1)-1:0];
assign z = mult_product[2*N_BITS-1:0];

assign x1 = w_saved[MULT_LATENCY-1][N_BITS:0] - z[N_BITS:0];
assign x2 = (x1 >= {1'b0, PRIME_MODULUS}) ? x1 - {1'b0, PRIME_MODULUS} : x1;
assign x3 = (x2 >= {1'b0, PRIME_MODULUS}) ? x2 - {1'b0, PRIME_MODULUS} : x2;
assign product = x3[N_BITS-1:0];

mult_256_sync MULT (
	.clk(clk),
	.num1(mult_num1),
	.num2(mult_num2),
	.product(mult_product)
);

endmodule
