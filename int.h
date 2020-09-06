# copyright 1987-2012 robert b. k. dewar and mark emmer.

# copyright 2012-2015 david shields
#
# this file is part of macro spitbol.
#
#     macro spitbol is free software: you can redistribute it and/or modify
#     it under the terms of the gnu general public license as published by
#     the free software foundation, either version 2 of the license, or
#     (at your option) any later version.
#
#     macro spitbol is distributed in the hope that it will be useful,
#     but without any warranty; without even the implied warranty of
#     merchantability or fitness for a particular purpose.  see the
#     gnu general public license for more details.
#
#     you should have received a copy of the gnu general public license
#     along with macro spitbol.	 if not, see <http://www.gnu.org/licenses/>.

	.code	32

#	results are usually returned in r0; real results in r0:r1

#	r11 is frame pointer; 
#	r12 is procedure entry temporary workspace
#	r14 is link register, return address at function exit


	w0	.req	r0	@ work register, does not persist across inctructions
	w1	.req	r1	@ used to fetch first operand
	w2	.req	r2	@ used to fetch second operand
	wa	.req	r3
	wb	.req	r4
	wc	.req	r5
	ia	.req	r5	@ is overlaps wc
	xl	.req	r6
	xr	.req	r7
	cp	.req	r8
	xs	.req	sp

	.set	cfp_c_val,4
	.set	log_cfp_b,2
	.set	log_cfp_c,2

	.set	cfp_m_,4294967295:1
	
	.set	cfp_n_,32

