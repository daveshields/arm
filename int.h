# copyright 1987-2012 robert b. k. dewar and mark emmer.

# copyright 2012-2015 david shields
	.data		
	.syntax		unified

#	results are usually returned in r0; real results in r0:r1

#	r11 is frame pointer; 
#	r12 is procedure entry temporary workspace
#	r14 is link register, return address at function exit


	w0	.req	r0	@ work register, does not persist across inctructions
	w1	.req	r1	@ used to fetch first operand
	w2	.req	r2	@ used to fetch second operand
	w3	.req	r3	@ temporary work register
	wa	.req	r3
	wb	.req	r4
	wc	.req	r5
	ia	.req	r5	@ is overlaps wc
	xl	.req	r6
	xt	.req	r6
	xr	.req	r7
	cp	.req	r8
	rc	.req	r10	@ return code (_rc_ in x64 version)
	pr	.req	r11	@ pool base register
	xs	.req	sp

	.set	cfp_c_val,4
	.set	log_cfp_b,2
	.set	log_cfp_c,2

	.set	cfp_m_,4294967295
	.set	cfp_n_,32

