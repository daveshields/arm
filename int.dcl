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
#

	.include "int.h"

	.code	32

	.extern	osisp
	.extern	compsp
	.extern	save_regs
	.extern	restore_regs
	.extern	_rc_
	.extern	reg_fl
	.extern	reg_w0

	.global	mxint

	.ifdef zz_trace
	.extern	zz
	.extern	zzz
	.extern	zz_cp
	.extern	zz_xl
	.extern	zz_xr
	.extern	zz_xs
	.extern	zz_wa
	.extern	zz_wb
	.extern	zz_wc
	.extern	zz_w0
	.extern	zz_zz
	.extern	zz_id
	.extern	zz_de
	.extern	zz_0
	.extern	zz_1
	.extern	zz_2
	.extern	zz_3
	.extern	zz_4
	.extern	zz_arg
	.extern	zz_num
	.endif

	.global	start


#
#
#   table to recover type word from type ordinal
#

	.extern		_rc_
	.global		typet
	.section 	data

	.word	b_art	@ arblk type word - 0
	.word	b_cdc	@ cdblk type word - 1
	.word	b_exl	@ exblk type word - 2
	.word	b_icl	@ icblk type word - 3
	.word	b_nml	@ nmblk type word - 4
	.word	p_aba	@ p0blk type word - 5
	.word	p_alt	@ p1blk type word - 6
	.word	p_any	@ p2blk type word - 7
# next needed only if support real arithmetic cnra
#	.word	b_rcl	; rcblk type word - 8
	.word	b_scl	@ scblk type word - 9
	.word	b_sel	@ seblk type word - 10
	.word	b_tbt	@ tbblk type word - 11
	.word	b_vct	@ vcblk type word - 12
	.word	b_xnt	@ xnblk type word - 13
	.word	b_xrt	@ xrblk type word - 14
	.word	b_bct	@ bcblk type word - 15
	.word	b_pdt	@ pdblk type word - 16
	.word	b_trt	@ trblk type word - 17
	.word	b_bft	@ bfblk type word   18
	.word	b_cct	@ ccblk type word - 19
	.word	b_cmt	@ cmblk type word - 20
	.word	b_ctt	@ ctblk type word - 21
	.word	b_dfc	@ dfblk type word - 22
	.word	b_efc	@ efblk type word - 23
	.word	b_evt	@ evblk type word - 24
	.word	b_ffc	@ ffblk type word - 25
	.word	b_kvt	@ kvblk type word - 26
	.word	b_pfc	@ pfblk type word - 27
	.word	b_tet	@ teblk type word - 28

	.global	gbcnt
	.global	headv
	.global	mxlen
	.global	stage
	.global	timsx
	.global	dnamb
	.global	dnamp
	.global	state
	.global	b_efc
	.global	b_icl
	.global	b_scl
	.global	b_vct
	.global	b_xnt
	.global	b_xrt
	.global	stbas
	.global	statb
	.global	polct
	.global	typet
	.global	lowspmin
	.global	flprt
	.global	flptr
	.global	gtcef
	.global	hshtb
	.global	pmhbs
	.global	r_fcb
	.global	c_aaa
	.global	c_yyy
	.global	g_aaa
	.global	w_yyy
	.global	s_aaa
	.global	s_yyy
	.global	r_cod
	.global	kvstn
	.global	kvdmp
	.global	kvftr
	.global	kvcom
	.global	kvpfl
	.global	cswfl
	.global	stmcs
	.global	stmct
	.global	b_rcl
	.global	end_min_data


	.extern ldr_
	.extern str_
	.extern itr_
	.extern adr_
	.extern sbr_
	.extern mlr_
	.extern dvr_
	.extern ngr_
	.extern atn_
	.extern chp_
	.extern cos_
	.extern etx_
	.extern lnf_
	.extern sin_
	.extern sqr_
	.extern tan_
	.extern cpr_
	.extern ovr_

#	%macro	zzz	3
#	section	.data
#%%desc:	db	%3,0
#	section	.text
#	mov	m_word [zz_id],%1
#	mov	m_word [zz_zz],%2
#	mov	m_word [zz_de],%%desc
#	call	zzz
#	%endmacro

	.extern	reg_ia,reg_wa,reg_fl,reg_w0,reg_wc

#	integer arithmetic instructions
#	.extern	cvd__
#	%macro	cvd_
#	call	cvd__
#	%endmacro


#	%macro	adi_	arg
#	add	ia,\arg
#	seto	byte [reg_fl]
#	%endmacro
#
#	.extern	dvi__
#	%macro	dvi_	arg
#	call	dvi__
#	%endmacro
#
#	.extern	rmi__
#	%macro	rmi_	arg
#	mov	rax,r1
#	call	rmi__
#	%endmacro
#

#	%macro	ino_	arg
#	mov	al,byte [reg_fl]
#	or	al,al
#	jno	%1
#	%endmacro
#
#	%macro	iov_	arg
#	mov	al,byte [reg_fl]
#	or	al,al
#	jo	%1
#	%endmacro
#
#	%macro	ldi_	arg
#	mov	ia,\arg
#	%endmacro
#
#	%macro	mli_	arg
#	imul	ia,\arg
#	seto	byte [reg_fl]
#	%endmacro
#
#	%macro	ngi_	0
#	neg	ia
#	seto	byte [reg_fl]
#	%endmacro

#	.extern	f_rti
#	%macro	rti_	0
#	call	f_rti
#	mov	ia,m_word [reg_ia]
#	%endmacro

#	%macro	sbi_	1
#	sub	ia,%1
#	mov	rax,0
#	seto	byte [reg_fl]
#	%endmacro
#
#	%macro	sti_	1
#	mov	%1,ia
#	%endmacro

#	code pointer instructions (cp maintained in location reg_cp)

#	.extern	reg_cp

#	%macro	lcp_	1
#	mov	rax,%1
#	mov	m_word [reg_cp],rax
#	%endmacro
#
#	%macro	lcw_	1
#	mov	rax,m_word [reg_cp]		@ load address of code word
#	mov	rax,m_word [rax]		@ load code word
#	mov	%1,rax
#	mov	rax,m_word [reg_cp]		@ load address of code word
#	add	rax,cfp_b
#	mov	m_word [reg_cp],rax
#	%endmacro
#
#	%macro	scp_	1
#	mov	rax,m_word [reg_cp]
#	mov	%1,rax
#	%endmacro
#
#	%macro	icp_	0
#	mov	rax,m_word [reg_cp]
#	add	rax,cfp_b
#	mov	m_word [reg_cp],rax
#	%endmacro
#
#	%macro	rov_	1
#	mov	al,byte [reg_fl]
#	or	al,al
#	jne	%1
#	%endmacro
#
#	%macro	rno_	1
#	mov	al,byte [reg_fl]
#	or	al,al
#	je	%1
#	%endmacro


