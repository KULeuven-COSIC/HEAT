`timescale 1ns / 1ps

/*================================================================================
This HDL-source code of the Ring-LWE Encryption Scheme is released under the 
MPL 1.1/GPL 2.0/LGPL 2.1 triple license.

------------------------------------------------------------------------------
Copyright (c) 2014, KU Leuven. All rights reserved.

The initial developer of this source code is Sujoy Sinha Roy, KU Leuven.
Contact Sujoy.SinhaRoy@esat.kuleuven.be for comments & questions.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright 
     notice, this list of conditions and the following disclaimer in 
     the documentation and/or other materials provided with the distribution.

  3. The names of the authors may not be used to endorse or promote products
     derived from this HDL-source code without specific prior written permission.

THIS HDL-SOURCE CODE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL KU LEUVEN OR 
ANY CONTRIBUTORS TO THIS HDL-SOURCE CODE BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

================================================================================*/

/*
module mux4_18bits_special(in1, in2, in3, in4, sel2, primsel, out);
input [17:0] in1, in2, in3, in4;
input [1:0] sel2;
input primsel;
output [17:0] out;

assign out = (sel2==2'd0) ? in1
				//:(sel2==2'd1 || primsel==1'd1) ? in2
				:(sel2==2'd1) ? in2
				:(sel2==2'd2) ? in3
				:in4;

endmodule
*/

module mux4_30bits_special(in1, in2, in3, in4, sel2, primsel, out);
input [29:0] in1, in2, in3, in4;
input [1:0] sel2;
input primsel;
output [29:0] out;

assign out = (sel2==2'd0) ? in1
				//:(sel2==2'd1 || primsel==1'd1) ? in2
				:(sel2==2'd1) ? in2
				:(sel2==2'd2) ? in3
				:in4;

endmodule
