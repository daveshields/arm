# copyright 1987-2012 robert b. k. dewar and mark emmer.
# copyright 2012-2020 david shields
#
#
#     macro spitbol is free software: you can redistribute it and/or modify
#     it under the terms of the gnu general public license as published by
#     the free software foundation, either vexlon 2 of the license, or
#     (at your option) any later vexlon.
#
#     macro spitbol is distributed in the hope that it will be useful,
#     but without any warranty; without even the implied warranty of
#     merchantability or fitness for a particular purpose.  see the
#     gnu general public license for more details.
#
#     you should have received a copy of the gnu general public license
#     along with macro spitbol.	 if not, see <http://www.gnu.org/licenses/>.

	.set	cfp_b,4
	.set	cfp_c,4

	.include "int.h"

	.data
	.section	data


	.global	reg_block
	.global	reg_w0
	.global	reg_wa
	.global	reg_wb
	.global	reg_ia
	.global	reg_wc
	.global	reg_xr
	.global	reg_xl
	.global	reg_cp
	.global	reg_ra
	.global	reg_pc
	.global	reg_xs
	.global	reg_size

	.global	reg_rp

reg_block_:	.word	reg_block
reg_wo_:	.word	reg_w0
reg_wa_:	.word	reg_wa
reg_wb_:	.word	reg_wb
#reg_wc_:	.word	reg_ia
reg_wc_:	.word	reg_wc
reg_xr_:	.word	reg_xr
reg_xl_:	.word	reg_xl
reg_cp_:	.word	reg_cp
reg_ra_:	.word	reg_ra
reg_pc_:	.word	reg_pc
reg_xs_:	.word	reg_xs

reg_size_:	.word	reg_size

reg_rp_:	.word	reg_rp

	.global	save_cp
	.global	save_xl
	.global	save_xr
	.global	save_xs
	.global	save_wa
	.global	save_wb
	.global	save_wc
	.global	save_w0

save_cp_:	.word	save_cp
save_xl_:	.word	save_xl
save_xr_:	.word	save_xr
save_xs_:	.word	save_xs
save_wa_:	.word	save_wa
save_wb_:	.word	save_wb
save_wc_:	.word	save_wc
save_w0_:	.word	save_w0


#	address of global variables, where suffix '_' gives address of a variable

calltab_:	.word	calltab

stacksiz_:	.word	stacksiz
lowspmin_:	.word	lowspmin
stbas_:		.word	stbas
statb_:		.word	statb
stage_:		.word	stage
gbcnt_:		.word	gbcnt
lmodstk_:	.word	lmodstk
startbrk_:	.word	startbrk
outptr_:	.word	outptr
swcoup_:	.word	swcoup
timsx_:		.word	timsx

#
# words saved during exit(-3)
# 
	.align 2
reg_block_:	.word	reg_block
reg_block:
reg_ia: .word	0			@ register ia (ia)
reg_w0:	.word	0			@ register w0 (w0)
reg_wa:	.word	0			@ register wa (wa)
reg_wb:	.word	0			@ register wb (wb)
reg_wc:	.word	0			@ register wc (wc)
reg_xl:	.word	0			@ register xl (xl)
reg_xr:	.word	0			@ register xr (xr)
reg_cp:	.word	0			@ register cp
reg_ra:	.single	0.0			@ register ra

# these locations save information needed to return after calling osint
# and after a restart from exit()

#reg_pc: .word	0		    	@ return pc from caller
reg_xs:	.word	0			@ minimal stack pointer

	.set	r_size,10*cfp_b
reg_size:	.word   r_size		@ used only in sysxi in osint

# reg_rp is used to pass pointer to real operand for real arithmetic
# this is not needed for arm version, since real operands are single word.

reg_rp:	.word	0

# reg_fl is used to communicate condition codes between minimal and c code.

	.global	reg_fl
reg_fl_:	.word	reg_fl
reg_fl:	.word	0			@ condition code register for numeric operations
	

	.align	2
#  constants

	.global	ten
ten_:	.word	ten
ten:	.word	10		    	@ constant 10

inf_:	.word	inf
	.global	inf
inf:	.word	0
	.word	    0x7ff00000	    	@ double precision infinity

sav_block_:	.word	sav_block
	.global	sav_block

#sav_block: times r_size db 0		@ save minimal registers during push/pop reg

sav_block:
	.rept	r_size	
	.word	0
	.endr
	.word	0

	.align	2
	.global	ppoff
ppoff_:	.word	ppoff
ppoff:	.word	0			@ offset for ppm exits

	.global	compsp
compsp_: .word	compsp
compsp: .word	0			@ compiler's stack pointer
	.global	sav_compsp
sav_compsp_:	.word	sav_compsp
sav_compsp:
	.word	0			@ save compsp here
	.global	osisp
osisp_:	.word	osisp
osisp:	.word	0			@ osint's stack pointer

save_cp:	.word	0		@ saved cp value
#save_ia:	.word	0		@ saved ia value
save_xl:	.word	0		@ saved xl value
save_xr:	.word	0		@ saved xr value
save_xs:	.word	0		@ saved sp value
save_wa:	.word	0		@ saved wa value
save_wb:	.word	0		@ saved wb value
save_wc:	.word	0		@ saved wc value
save_w0:	.word	0		@ saved w0 value

	.global	minimal_id
minimal_id_:	word	minimal_id
minimal_id:	.word	0		@ id for call to minimal from c. see proc minimal below.

#
	.set	setreal,0

#	setup a number of internal addresses in the compiler that cannot
#	be directly accessed from within c because of naming difficulties.

	.global	id1
id1_:	.word	id1
id1:	.word   0
	.if	setreal
	.word	     2
       	.word	    1
	.word  "1x\x00\x00\x00"
	.endif

	.global	id1blk
id1blk_:	.word	id1blk
id1blk:	.word	 152
	.word	  0
	.rept	152
	.byte	0
	.endr


	.global	id2blk
id2blk_:	.word	id2blk
id2blk:	.word	 152
	.word	  0
	.rept	152
	.byte	0
	.endr

	.global	ticblk
ticblk_:	.word	ticblk
ticblk:	.word	 0
      	.word	0

	.global	tscblk
tscblk_:	.word	tscblk
tscblk:	 .word	  512
      	.word	0
	.rept	512
	.byte	0
	.endr

#	standard input buffer block.

	.global	inpbuf
inpbuf_:	.word	inpbuf
inpbuf:	.word	0			@ type word
	.word	0			@ block length
	.word	1024			@ buffer size
      	.word	0			@ remaining chars to read
      	.word	0			@ offset to next character to read
      	.word	0			@ file position of buffer
      	.word	0			@ physical position in file
	.rept	1024			@ buffer
	.byte	0
	.endr

	.global	ttybuf
ttybuf_:	.word	ttybuf
ttybuf:	.word	  0	@ type word
	.word	  0			@ block length
	.word	  260			@ buffer size	(260 ok in ms-dos with cinread())
	.word	  0			@ remaining chars to read
	.word	  0			@ offset to next char to read
	.word	  0			@ file position of buffer
	.word	  0			@ physical position in file
	.rept	260			@ buffer
	.byte	0
	.endr



	.code	32
	.section	.text
	.syntax		unified

#	cfp_b is bytes per word, cfp_c is characters per word


#	values below must agree with calltab defined in int.h and also in osint/osint.h

	.set	minimal_relaj,0
	.set	minimal_relcr,1
	.set	minimal_reloc,2
	.set	minimal_alloc,3
	.set	minimal_alocs,4
	.set	minimal_alost,5
	.set	minimal_blkln,6
	.set	minimal_insta,7
	.set	minimal_rstrt,8
	.set	minimal_start,9
	.set	minimal_filnm,10
	.set	minimal_dtype,11
	.set	minimal_enevs,12
	.set	minimal_engts,13

	.global	minimal

#	this file contains the assembly language routines that interface
#	the macro spitbol compiler written in assembly language to the
#	operating system interface functions written in c.

#	contents:

#	o overview
#	o .global variables accessed by osint functions
#	o interface routines between compiler and osint functions
#	o c callable function startup
#	o c callable function get_fp
#	o c callable function restart
#	o c callable function makeexec
#	o routines for minimal opcodes chk and cvd
#	o math functions for integer multiply, divide, and remainder
#	o math functions for real operation

#	overview

#	the macro spitbol compiler relies on a set of operating system
#	interface functions to provide all interaction with the host
#	operating system.  these functions are referred to as osint
#	functions.  a typical call to one of these osint functions takes
#	the following form in the arm version of the compiler:

#		...code to put arguments in registers...
#		call	sysxx		# call osint function
#	      .word	exit_1		# address of exit point 1
#	      .word	exit_2		# address of exit point 2
#		...	...		# ...
#	      .word	exit_n		# address of exit point n
#		...instruction following call...

#	the osint function 'sysxx' can then return in one of n+1 ways:
#	to one of the n exit points or to the instruction following the
#	last exit.  this is not really very complicated - the call places
#	the return address on the stack, so all the interface function has
#	to do is add the appropriate offset to the return address and then
#	pick up the exit address and jump to it or do a normal return via
#	an ret instruction.

#	unfortunately, a c function cannot handle this scheme.	so, an
#	intermediary set of routines have been established to allow the
#	interfacing of c functions.  the mechanism is as follows:

#	(1) the compiler calls osint functions as described above.

#	(2) a set of assembly language interface routines is established,
#	    one per osint function, named accoxrngly.	each interface
#	    routine ...

#	    (a) saves all compiler registers in .global variables
#		accessible by c functions
#	    (b) calls the osint function written in c
#	    (c) restores all compiler registers from the .global variables
#	    (d) inspects the osint function's return value to determine
#		which of the n+1 returns should be taken and does so

#	(3) a set of c language osint functions is established, one per
#	    osint function, named differently than the interface routines.
#	    each osint function can access compiler registers via .global
#	    variables.	no arguments are passed via the call.

#	    when an osint function returns, it must return a value indicating
#	    which of the n+1 exits should be taken.  these return values are
#	    defined in header file 'int.h'.

#	note:  in the actual implementation below, the saving and restoring
#	of registers is actually done in one common routine accessed by all
#	interface routines.

#	other notes:

#	some c ompilers transform "internal" .global names to
#	"external" .global names by adding a leading underscore at the front
#	of the internal name.  thus, the function name 'osopen' becomes
#	'_osopen'.  however, not all c compilers follow this convention.

#	.global variables

# end of words saved during exit(-3)
#
#	save and restore minimal and interface registers on stack.
#	used by any routine that needs to call back into the minimal
#	code in such a way that the minimal code might trigger another
#	sysxx call before returning.
#
#	note 1:	 pushregs returns a collectable value in xl, safe
#	for subsequent call to memory allocation routine.
#
#	note 2:	 these are not recuxlve routines.  only reg_xl is
#	saved on the stack, where it is accessible to the garbage
#	collector.  other registers are just moved to a temp area.
#
#	note 3:	 popregs does not restore reg_cp, because it may have
#	been modified by the minimal routine called between pushregs
#	and popregs as a result of a garbage collection.  calling of
#	another sysxx routine in between is not a problem, because
#	cp will have been preserved by minimal.
#
#	note 4:	 if there isn't a compiler stack yet, we don't bother
#	saving xl.  this only happens in call of nextef from sysxi when
#	reloading a save file.
#
#
	.global	save_regs
save_regs:
					@ save registers
#	str	wc,save_ia
	ldr	w1,=save_xl_
	str	xl,[w1]
	ldr	w1,=save_xr_
	str	xr,[w1]
	str	xs,save_xs
	str	wa,save_wa
	str	wb,save_wb
	str	wc,save_wc
	str	w0,save_w0
	mov	PC,LR

	.global	restore_regs
restore_regs:
					@ restore regs, except for sp. that is caller's responsibility
#	ldr	wc,=save_ia
	ldr	xl,=save_xl
	ldr	xr,=save_xr
#	ldr	xs,=save_xs		@ caller restores sp
	ldr	wa,=save_wa
	ldr	wb,=save_wb
	ldr	wc,=save_wc
	ldr	w0,=save_w0
	mov	PC,LR
# ;
# ;	  startup( char *dummy1, char *dummy2) - startup compiler
# ;
# ;	  an osint c function calls startup to transfer control
# ;	  to the compiler.
# ;
# ;	  (xr) = basemem
# ;	  (xl) = topmem - sizeof(word)
# ;
# ;	note: this function never returns.
# ;
#
	.global	startup
#   oxrnals for minimal calls from assembly language.


#   table of minimal entry points that can be called from c
#   via the minimal function (see inter.asm).
#
#   note that the order of entries in this table must correspond
#   to the order of entries in the call enumeration in osint.h
#   and osint.inc.
#

	.set	calltab_relaj,0
	.set	calltab_relcr,1
	.set	calltab_reloc,2
	.set	calltab_alloc,3
	.set	calltab_alocs,4
	.set	calltab_alost,5
	.set	calltab_blkln,6
	.set	calltab_insta,7
	.set	calltab_rstrt,8
	.set	calltab_start,9
	.set	calltab_filnm,10
	.set	calltab_dtype,11
	.set	calltab_enevs,12
	.set	calltab_engts,13


startup:
	pop	{w0}			@ discard return
	b	stackinit		@ initialize minimal stack
	ldr	w0,=compsp		@ get minimal's stack pointer
	str 	w0,reg_wa		@ startup stack pointer

	ldr	w2,=ppoff
	mov     w0,w2			@ save for use later
	ldr	xs,=osisp		@ switch to new c stack
	ldr	w1,calltab_
	str	w1,minimal_id
	bl	minimal			@ load regs, switch stack, start compiler

#	stackinit  -- initialize lowspmin from sp.

#	input:	sp - current c stack
#		stacksiz - size of desired minimal stack in bytes

#	uses:	w0

#	output: register wa, sp, lowspmin, compsp, osisp set up per diagram:

#	(high)	+----------------+
#		|  old c stack	 |
#		|----------------| <-- incoming sp, resultant wa (future xs)
#		|	     ^	 |
#		|	     |	 |
#		/ stacksiz bytes /
#		|	     |	 |
#		|	     |	 |
#		|----------- | --| <-- resultant lowspmin
#		| 400 bytes  v	 |
#		|----------------| <-- future c stack pointer, osisp
#		|  new c stack	 |
#	(low)	|		 |




	.global	stackinit
stackinit:
	mov	w0,xs
	ldr	w1,stacksiz_ 	@ save as minimal's stack pointer
	ldr	w1,[w1]
	sub	w0,w0,w1	@ end of minimal stack is where c stack will start
	ldr	w0,osisp	@ save new c stack pointer
	add	w0,#cfp_b*100	@ 100 words smaller for chk
	ldr	w1,lowspmin_
	str	w2,[w1]
	mov	PC,LR

#	mimimal -- call minimal function from c

#	usage:	.extern void minimal(word callno)

#	where:
#	  callno is an oxrnal defined in osint.h, osint.inc, and calltab.

#	minimal registers wa, wb, wc, xr, and xl are loaded and
#	saved from/to the register block.

#	note that before restart is called, we do not yet have compiler
#	stack to switch to.  in that case, just make the call on the
#	the osint stack.

minimal:
	ldr	wa,=reg_wa	@ restore registers
	ldr	wb,=reg_wb
	ldr	wc,=reg_wc	@
	ldr	xr,=reg_xr
	ldr	xl,=reg_xl

	str	xs,osisp	@ save osint stack pointer
	ldr	w1,compsp
	tst	w1,w1
	movne	xs,w2		@ switch to compiler stack
	ldr	w0,minimal_id	@ ordinal in calltab
#	for 64: have  
#		call  calltab+w0*cfp_b    @ off to the minimal code
	ldr	w1,calltab_	@ origin of calltab
	add	w1,w1,w0,lsl #2
	blx	w1

	ldr	xs,=osisp	@ switch to osint stack

	str	wa,reg_wa	@ save registers
	str	wb,reg_wb
	str	wc,reg_wc
	str	xr,reg_xr
	str	xl,reg_xl
	mov	PC,LR		@ return to minimal code

	.global	cvd_
	.type	cvd_,%function
cvd_:
	str	wc,reg_ia
	bl	cvd__
	ldr	wc,=reg_ia
	ldr	wa,=reg_wa
	mov	PC,LR		@ return to minimal code


	.global	dvi_
# need for .type is undocumented feature as as manual
# discovered by looking as assembler code generated by gcc.
	.type	dvi_,%function
dvi_:
	tst	w0,w0
	cmp	w0,w0			@ compare to see if zero (also clear v flag)
	beq	1f
	str	w0,reg_w0		@ store argument
	str	wc,reg_ia		@ make wc (ia) accessible to osint procedure
	bl	dvi__
	ldr	wc,=reg_wc
	b	2f
1:					@ here if divide by zero, force overflow
	mov	w1,#1
	lsl	w1,w1,#30		@ large integer
	mov	w2,w1
	muls	w1,w2,w1		@ force overflow to be set
2:
	mov	PC,LR			@ return to minimal code

	.global	rmi_
	.type	rmi_,%function
rmi_:
	tst	w0,w0
	cmp	w0,w0			@ compare to see if zero (also clear v flag)
	beq	1f
	str	w0,reg_w0		@ store argument
	str	wc,reg_ia		@ make wc (ia) accessible to osint procedure
	bl	rmi__
	ldr	wc,=reg_wc
	b	2f
1:					@ here if divide by zero, force overflow
	mov	w1,#1
	lsl	w1,w1,#30		@ large integer
	mov	w2,w1
	muls	w1,w2,w1		@ force overflow to be set
2:
	mov	PC,LR			@ return to minimal code

	.align	2
	.global	cprtmsg
cprtmsg:
	.ascii	    " copyright 1987-2020 robert b. k. dewar and mark emmer."
	.align	2


#	interface routines

#	each interface routine takes the following form:

#		sysxx	call	ccaller @ call common interface
#		      .word	zysxx	@ dd	  of c osint function
#			db	n	@ offset to instruction after
#					@   last procedure exit

#	in an effort to achieve portability of c osint functions, we
#	do not take take advantage of any "internal" to "external"
#	transformation of names by c compilers.	 so, a c osint function
#	representing sysxx is named _zysxx.  this renaming should satisfy
#	all c compilers.

#	important  one interface routine, sysfc, is passed arguments on
#	the stack.  these items are removed from the stack before calling
#	ccaller, as they are not needed by this implementation.

#	ccaller is called by the os interface routines to call the
#	real c os interface function.

#	general calling sequence is

#		call	ccaller
#	      .word	address_of_c_function
#		db	2*number_of_exit_points

#	control is never returned to a interface routine.  instead, control
#	is returned to the compiler (the caller of the interface routine).

#	the c function that is called must always return an integer
#	indicating the procedure exit to take or that a normal return
#	is to be performed.

#		c function	interpretation
#		return value
#		------------	-------------------------------------------
#		     <0		do normal return to instruction past
#				last procedure exit (distance passed
#				in by dummy routine and saved on stack)
#		      0		take procedure exit 1
#		      4		take procedure exit 2
#		      8		take procedure exit 3
#		     ...	...



syscall_init:

#	save registers in .global variables

	str	wa,reg_wa		 @ save registers
	str	wb,reg_wb
	str	wc,reg_wc		 @ (also _reg_ia)
	str	xl,reg_xl
	str	xr,reg_xr
	mov	PC,LR

syscall_exit:

	mov	rc,w0			@ save return code from function

	ldr	w1,=osisp
	str	xs,[w1]		 	@ save osint's stack pointer

	ldr	xs,=compsp
	ldr	wa,=reg_wa		 @ restore registers
	ldr	wb,=reg_wb
	ldr	wc,=reg_wc
	ldr	xr,=reg_xr
	ldr	xl,=reg_xl
#	ldr	w0,reg_pc_
#	ldr	w0,[w0]

	mov	PC,LR			@ return to syscall caller

	.macro	syscall	proc,id

# CHECK THESE CLOSELY
	bl	syscall_init

#	save compiler stack and switch to osint stack
#	adr	w0,compsp
#	str	xs,[w0]			@ save compiler's stack pointer

#	adr	w0,osisp		@ load osint's stack pointer
#	ldr	xs,[w0]

	bl	\proc
	bl	syscall_exit		@
#	was a call for debugging purposes,
#	but that would cause crash when the compilers stack pointer blew up
	.endm

	.global sysax
#	.extern	zysax
sysax:	syscall	  zysax,1

	.global sysbs
#	.extern	zysbs
sysbs:	
	syscall	  zysbs,2

	.global sysbx
#	.extern	zysbx
sysbx:	
	str	xs,reg_xs
	syscall	zysbx,2

#	 .global syscr
#	.extern	zyscr
#syscr:	 syscall    zyscr,0

	.global sysdc
#	.extern	zysdc
sysdc:	syscall	zysdc,4

	.global sysdm
#	.extern	zysdm
sysdm:	syscall	zysdm,5

	.global sysdt
#	.extern	zysdt
sysdt:	syscall	zysdt,6

	.global sysea
#	.extern	zysea
sysea:	syscall	zysea,7

	.global sysef
#	.extern	zysef
sysef:	syscall	zysef,8

	.global sysej
#	.extern	zysej
sysej:	syscall	zysej,9

	.global sysem
#	.extern	zysem
sysem:	syscall	zysem,10

	.global sysen
#	.extern	zysen
sysen:	syscall	zysen,11

	.global sysep
#	.extern	zysep
sysep:	syscall	zysep,12

	.global sysex
#	.extern	zysex
sysex:	
	str	xs,reg_xs

	syscall	zysex,13

	.global sysfc
#	.extern	zysfc
sysfc:	
	pop	{w0}			@ <<<<remove stacked scblk>>>>
#	lea	xs,[xs+wc*cfp_b]	@ x64 version
	lsl	w0,wc,#2
	add	xs,xs,w0		@ arm version
	push	{w0}
	syscall	zysfc,14

	.global sysgc
#	.extern	zysgc
sysgc:	syscall	zysgc,15

	.global syshs
#	.extern	zyshs
syshs:	
	str	xs,reg_xs
	syscall	zyshs,16

	.global sysid
#	.extern	zysid
sysid:	syscall	zysid,17

	.global sysif
#	.extern	zysif
sysif:	syscall	zysif,18

	.global sysil
#	.extern	zysil
sysil:	syscall zysil,19

	.global sysin
#	.extern	zysin
sysin:	syscall	zysin,20

	.global sysio
#	.extern	zysio
sysio:	syscall	zysio,21

	.global sysld
#	.extern	zysld
sysld:	syscall zysld,22

	.global sysmm
#	.extern	zysmm
sysmm:	syscall	zysmm,23

	.global sysmx
#	.extern	zysmx
sysmx:	syscall	zysmx,24

	.global sysou
#	.extern	zysou
sysou:	syscall	zysou,25

	.global syspi
#	.extern	zyspi
syspi:	syscall	zyspi,26

	.global syspl
#	.extern	zyspl
syspl:	syscall	zyspl,27

	.global syspp
#	.extern	zyspp
syspp:	syscall	zyspp,28

	.global syspr
#	.extern	zyspr
syspr:	syscall	zyspr,29

	.global sysrd
#	.extern	zysrd
sysrd:	syscall	zysrd,30

	.global sysri
#	.extern	zysri
sysri:	syscall	zysri,32

	.global sysrw
#	.extern	zysrw
sysrw:	syscall	zysrw,33

	.global sysst
#	.extern	zysst
sysst:	syscall	zysst,34

	.global systm
#	.extern	zystm
systm:	syscall	zystm,35

	.global systt
#	.extern	zystt
systt:	syscall	zystt,36

	.global sysul
#	.extern	zysul
sysul:	syscall	zysul,37

	.global sysxi
#	.extern	zysxi
sysxi:	
	str	xs,reg_xs
	syscall	zysxi,38

#	x64 hardware divide, expressed in form of minimal register mappings, requires dividend be
#	placed in w0, which is then sign extended into wc:w0. after the divide, w0 contains the
#	quotient, wc contains the remainder.
#
#	cvd__ - convert by division
#
#	input	ia = number <=0 to convert
#	output	ia / 10
#		wa ecx) = remainder + '0'

# assume no overflows for bootstrap, all operations on IA use code generated by asm.sbl
#	.global	cvd__
#$cvd__:
#	.extern	i_cvd
#	mov	reg_ia,ia
#	mov	reg_wa,wa
#	bl	i_cvd
#	ldr	wc,reg_ia
#	ldr	wa,reg_wa
#	mov	PC,lr

#$
#$ocode:
#$	or	w0,w0			@ test for 0
#$	bze	setovr			@ jump if 0 divisor
#$	xchg	w0,ia			@ ia to w0, divisor to ia
#$	cdq				@ extend dividend
#$	idiv	ia		 	@ perform division. w0=quotient, wc=remainder
#$	seto	byte reg_fl
#$	mov	ia,wc
#$	mov	PC,lr
#$
#$setovr: mov	al,1			@ set overflow indicator
#$	mov	byte [reg_fl],al
#$	mov	PC,lr
#$
	.macro	real_op name,proc
	.global	\name
#	.extern	\proc
\name:
	ldr	w1,reg_rp
	str	w0,[w1]
	bl	\proc
	mov	PC,lr
	.endm


#	real_op	ldr_,f_ldr
#	real_op	str_,f_str
#	real_op	adr_,f_adr
#	real_op	sbr_,f_sbr
#	real_op	mlr_,f_mlr
#	real_op	dvr_,f_dvr
#	real_op	ngr_,f_ngr
#	real_op cpr_,f_cpr

#	.macro	int_op ent,proc
#	.global	\ent
##	.extern	\proc
#\ent:
#	str	wc,reg_wc		@ is is kept in wc
#	bl	\proc
#	mov	PC,LR
#	.endm
#
#	int_op itr_,f_itr
#	int_op rti_,f_rti

#	.macro	math_op ent,proc
#	.global	\ent
##	.extern	\proc
#\ent:
#	bl	\proc
#	mov	PC,LR
#	.endm

#	don't support math functions for bootstrap

#	math_op	atn_,f_atn
#	math_op	chp_,f_chp
#	math_op	cos_,f_cos
#	math_op	etx_,f_etx
#	math_op	lnf_,f_lnf
#	math_op	sin_,f_sin
#	math_op	sqr_,f_sqr
#	math_op	tan_,f_tan

#	ovr_ test for overflow value in ra
#	.global	ovr_
#ovr_:
##	mov	ax, word [reg_ra+6]	@ get top 2 bytes
##	and	ax, 0x7ff0		@ check for infinity or nan
##	add	ax, 0x10		@ set/clear overflow accoxrngly
#	mov	PC,lr
#
	.global	get_fp			@ get frame pointer

get_fp:
	 ldr	 w0,reg_xs		 @ minimal's xs
#	 add	 w0,#4			@ pop return from call to sysbx or sysxi
	 mov	PC,lr			@ done


	.global	restart
#	scstr is offset to start of string in scblk, or two words

	.set	scstr,cfp_c+cfp_c

#
	.if	0
# restart only needed for save/load modules
restart:
#	pop	w0			@ discard return
#	pop	w0			@ discard dummy
#	pop	w0			@ get lowest legal stack value

	ldr	w1,=stacksiz
	add	w0,w1
	mov	xs,w0			@ switch to this stack
	bl	stackinit		@ initialize minimal stack

					@ set up for stack relocation
#	lea	w0,tscblk+scstr		@ top of saved stack
	ldr	w0,tscblk_		@ load address of saved stack
	add	w0,w0,#scstr

	ldr	wb,=lmodstk		@ bottom of saved stack
	ldr	wa,stbas_		@ wa = stbas from exit() time
	ldr	wa,[wa]
	sub	wb,wb,w0		@ wb = size of saved stack
	mov	wc,wa
	sub	wc,wb			@ wc = stack bottom from exit() time
	mov	wb,wa
	sub	wb,xs			@ wb =	 stbas - new stbas

	ldr	w2,stbas_	 	@ save initial sp
	str	xs,[w2]
#	 getoff	 w0,dffnc		 @ get address of ppm offset
	ldr	w0,=ppoff	 	@ save for use later
#
#	restore stack from tscblk.
#
	ldr	xl,=lmodstk		@ -> bottom word of stack in tscblk
#?? fix below
#	lea	xr,tscblk+scstr		@ -> top word of stack	(x64 version_
	ldr	w1,tscblk_		@ address of  tscblk
	add	w1,w1,#scstr		@ address of scstr entry
	ldr	xr,[w1]
	cmp	xl,xr			@ any stack to transfer?
	beq	3f			@  skip if not
	sub	xl,xl,#4
1:	
# ??
#	lodsd				@ get old stack word to w0
	ldr	w0,[xl]
	add	xl,#4

	cmp	w0,wc			@ below old stack bottom?
	blo	2f			@   j. if w0 < wc
	cmp	w0,wa			@ above old stack top?
	bhi	2f			@   j. if w0 > wa
	sub	w0,wb			@ within old stack, perform relocation
2:	
	push	{w0}			@ transfer word of stack
	cmp	xl,xr			@ if not at end of relocation then
	bhi	1b			@ branch if ge (unsigned)
	beq	1b			@ loop back
3:	
	str	xs,compsp		@ save compiler's stack pointer
	ldr	xs,=osisp		@ back to osint's stack pointer
	bl   	rereloc			@ relocate compiler pointers into stack
	ldr	w1,statb_		@ start of static region to xr
	ldr	w0,[w1]
	str	w0,reg_xr
	mov	w1,#minimal_insta
	b	minimal			@ initialize static region 
					@ was a call, but there is nothing to return to.  This was probably for 
					@ debugging purposes.

#
#	now pretend that we're executing the following c statement from
#	function zysxi:
#
#		return	normal_return;
#
#	if the load module was invoked by exit(), the return path is
#	as follows:  back to ccaller, back to s$ext following sysxi call,
#	back to user program following exit() call.
#
#	alternately, the user specified -w as a command line option, and
#	sysbx called makeexec, which in turn called sysxi.  the return path
#	should be:  back to ccaller, back to makeexec following sysxi call,
#	back to sysbx, back to minimal code.  if we allowed this to happen,
#	then it would require that stacked return address to sysbx still be
#	valid, which may not be true if some of the c programs have changed
#	size.  instead, we clear the stack and execute the restart code that
#	simulates resumption just past the sysbx call in the minimal code.
#	we distinguish this case by noting the variable stage is 4.
#
	bl   startbrk			@ start control-c logic

	ldr	w1,stage_		@ is this a -w call?
	ldr	w0,[w1]
	cmp	w0,#4
	beq	      re4		@ yes, do a complete fudge

#
#	jump back with return value = normal_return
	eor	w0,w0			@ set to zero to indicate normal return
	bl	syscall_exit
	mov	PC,LR

#	here if -w produced load module.  simulate all the code that
#	would occur if we naively returned to sysbx.  clear the stack and
#	go for it.
#
re4:	ldr	w1,stbas_
	ldr	w0,[w1]
	ldr	w2,compsp
	str	w0,[w2]			@ empty the stack

#	code that would be executed if we had returned to makeexec:
#
	eor	w1,w1
	ldr	w2,gbcnt_
	str	w1,[w2]			@ reset garbage collect count
	bl	zystm			@ fetch execution time to reg_ia
	ldr	w0,reg_ia		@ set time into compiler
	mov	wc,w0			@ ia is kept in wc
	ldr	w2,timsx_
	str	w0,[w2]

#	code that would be executed if we returned to sysbx:
#
#	push	outptr			@ swcoup(outptr)
	ldr	w1,=outptr_
	ldr	w1,[w1]
	push	{w1}
	bl	swcoup
	add	xs,#cfp_b

#	jump to minimal code to restart a save file.

	mov	w0,#minimal_rstrt
	str	w0,minimal_id
	bl	minimal			@ no return

	.endif

#%ifdef z_trace
#	.extern	zz_ra
#	.global	zzz
#	.extern	zz,zz_cp,zz_xl,zz_xr,zz_wa,zz_wb,zz_wc,zz_w0
#zzz:
#	pushf
#	bl	save_regs
#	bl	zz
#	bl	restore_regs
#	popf
#	mov	PC,lr
#%endif
