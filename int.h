# copyright 1987-2012 robert b. k. dewar and mark emmer.

# copyright 2012-2015 david shields
	.data		
#	.syntax		unified

#	results are usually returned in r0; real results in r0:r1

#	r11 is frame pointer; 
#	r12 is procedure entry temporary workspace
#	r14 is link register, return address at function exit

#	The work registers w1, w2 and w3 are used only to translate a single minimal instruction.

#	w1 is often used to load addresses of variables to be loaded.
#	w2 is often used to load addresses of variables to be stored into.

#	w0 is used to hold the return value from functions.

	w0	.req	r0	@ work register, does not persist across inctructions
	w1	.req	r1	@ used to fetch first operand
	w2	.req	r2	@ used to fetch second operand
	w3	.req	r3	@ temporary work register
	wa	.req	r4
	wb	.req	r5
	wc	.req	r6
	xl	.req	r7
	xt	.req	r7
	xr	.req	r8
	cp	.req	r9
	ia	.req	r10
	pr	.req	r11	@ pool base register
	rc	.req	r12
	xs	.req	sp

	.set	cfp_c_val,4
	.set	log_cfp_b,2
	.set	log_cfp_c,2

	.set	cfp_m_,4294967295
	.set	cfp_n_,32

