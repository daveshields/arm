# copyright 1987-2012 robert b. k. dewar and mark emmer.
# copyright 2012-2020 david shields
#
# this file is part of macro spitbol.
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


	.code	32
	.intel_syntax

#	ws is bits per word, cfp_b is bytes per word, cfp_c is characters per word


	.set	cfp_b,4
	.set	cfp_c,4

	.include "int.h"

	.globl	reg_block
	.globl	reg_w0
	.globl	reg_wa
	.globl	reg_wb
	.globl	reg_ia
	.globl	reg_wc
	.globl	reg_xr
	.globl	reg_xl
	.globl	reg_cp
	.globl	reg_ra
	.globl	reg_pc
	.globl	reg_xs
	.globl	reg_size

	.globl	reg_rp

	.globl	minimal
	.extern	calltab
	.extern	stacksiz

#	values below must agree with calltab defined in x64.hdr and also in osint/osint.h

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
	.set	minimal_enevs,10
	.set	minimal_engts,12

#	---------------------------------------

#	this file contains the assembly language routines that interface
#	the macro spitbol compiler written in 80386 assembly language to its
#	operating system interface functions written in c.

#	contents:

#	o overview
#	o .globl variables accessed by osint functions
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
#	the following form in the 80386 vexlon of the compiler:

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

#	    (a) saves all compiler registers in .globl variables
#		accessible by c functions
#	    (b) calls the osint function written in c
#	    (c) restores all compiler registers from the .globl variables
#	    (d) inspects the osint function's return value to determine
#		which of the n+1 returns should be taken and does so

#	(3) a set of c language osint functions is established, one per
#	    osint function, named differently than the interface routines.
#	    each osint function can access compiler registers via .globl
#	    variables.	no arguments are passed via the call.

#	    when an osint function returns, it must return a value indicating
#	    which of the n+1 exits should be taken.  these return values are
#	    defined in header file 'inter.h'.

#	note:  in the actual implementation below, the saving and restoring
#	of registers is actually done in one common routine accessed by all
#	interface routines.

#	other notes:

#	some c ompilers transform "internal" .globl names to
#	"external" .globl names by adding a leading underscore at the front
#	of the internal name.  thus, the function name 'osopen' becomes
#	'_osopen'.  however, not all c compilers follow this convention.

#	.globl variables

	segment	.data
#
# words saved during exit(-3)
# 
	.align 2
reg_block:
reg_ia: .word	0				@ register ia (ia)
reg_w0:	.word	0				@ register w0 (w0)
reg_wa:	.word	0				@ register wa (wa)
reg_wb:	.word	0				@ register wb (wb)
reg_wc:	.word	0				@ register wc (wc)
reg_xl:	.word	0				@ register xl (xl)
reg_xr:	.word	0				@ register xr (xr)
reg_cp:	.word	0				@ register cp
reg_ra:	.single	0.0				@ register ra

# these locations save information needed to return after calling osint
# and after a restart from exit()

reg_pc: .word	0		    		@ return pc from caller
reg_xs:	.word	0				@ minimal stack pointer

r_size	equ	10*cfp_b
reg_size:	.word   r_size			@ used only in sysxi in osint

# end of words saved during exit(-3)

# reg_rp is used to pass pointer to real operand for real arithmetic

reg_rp:	.word	0

# reg_fl is used to communicate condition codes between minimal and c code.

	.globl	reg_fl
reg_fl:	.word	0				@ condition code register for numeric operations
	

	.align	2
#  constants

	.globl	ten
ten:	.word	10		    		@ constant 10
	.globl	inf
inf:	.word	0
	.word	    0x7ff00000	    		@ double precision infinity

	.globl	sav_block
#sav_block: times r_size db 0			@ save minimal registers during push/pop reg
sav_block: times 44 db 0			@ save minimal registers during push/pop reg

	.align	2
	.globl	ppoff
ppoff:	.word	0				@ offset for ppm exits
	.globl	compsp
compsp: .word	0				@ compiler's stack pointer
	.globl	sav_compsp
sav_compsp:
	.word	0				@ save compsp here
	.globl	osisp
osisp:	.word	0				@ osint's stack pointer
	.globl	_rc_
_rc_:	dd   0					@ return code from osint procedure

	.align	2
	.globl	save_cp
	.globl	save_xl
	.globl	save_xr
	.globl	save_xs
	.globl	save_wa
	.globl	save_wb
	.globl	save_wc
	.globl	save_w0
save_cp:	.word	0			@ saved cp value
save_ia:	.word	0			@ saved ia value
save_xl:	.word	0			@ saved xl value
save_xr:	.word	0			@ saved xr value
save_xs:	.word	0			@ saved sp value
save_wa:	.word	0			@ saved wa value
save_wb:	.word	0			@ saved wb value
save_wc:	.word	0			@ saved wc value
save_w0:	.word	0			@ saved w0 value

	.globl	minimal_id
minimal_id:	.word	0			@ id for call to minimal from c. see proc minimal below.

#
%define setreal 0

#	setup a number of internal addresses in the compiler that cannot
#	be directly accessed from within c because of naming difficulties.

	.globl	id1
id1:	dd   0
%if setreal == 1
	.word	     2

       .word	    1
	.word  "1x\x00\x00\x00"
%endif

	.globl	id1blk
id1blk	.word	 152
	.word	  0
	times	152 db 0

	.globl	id2blk
id2blk	.word	 152
	.word	  0
	times	152 db 0

	.globl	ticblk
ticblk:	.word	 0
      .word	0

	.globl	tscblk
tscblk:	 .word	  512
      .word	0
	times	512 db 0

#	standard input buffer block.

	.globl	inpbuf
inpbuf:	.word	0				@ type word
      .word	0				@ block length
      .word	1024				@ buffer size
      .word	0				@ remaining chars to read
      .word	0				@ offset to next character to read
      .word	0				@ file position of buffer
      .word	0				@ physical position in file
	times	1024 db 0			@ buffer

	.globl	ttybuf
ttybuf:	.word	  0		@ type word
	.word	  0				@ block length
	.word	  260				@ buffer size	(260 ok in ms-dos with cinread())
	.word	  0				@ remaining chars to read
	.word	  0				@ offset to next char to read
	.word	  0				@ file position of buffer
	.word	  0				@ physical position in file
	times	260 db 0			@ buffer
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
	.globl	save_regs
save_regs:
						@ save registers
	str	wc,save_ia
	str	xl,save_xl
	str	xr,save_xr
	str	xs,save_xs
	str	wa,save_wa
	str	wb,save_wb
	str	wc,save_wc
	str	w0,save_w0
	mov	PC,lr

	.globl	restore_regs
restore_regs:
						@ restore regs, except for sp. that is caller's responsibility
	ldr	wc,save_ia
	ldr	xl,save_xl
	ldr	xr,save_xr
#	ldr	xs,save_xs			@ caller restores sp
	ldr	wa,save_wa
	ldr	wb,save_wb
	ldr	wc,save_wc
	ldr	w0,save_w0
	mov	PC,lr
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
	.globl	startup
#   oxrnals for minimal calls from assembly language.

#   the order of entries here must correspond to the order of
#   calltab entries in the inter assembly language module.

calltab_relaj equ   0
calltab_relcr equ   1
calltab_reloc equ   2
calltab_alloc equ   3
calltab_alocs equ   4
calltab_alost equ   5
calltab_blkln equ   6
calltab_insta equ   7
calltab_rstrt equ   8
calltab_start equ   9
calltab_filnm equ   10
calltab_dtype equ   11
calltab_enevs equ   12
calltab_engts equ   13

startup:
	pop	w0				@ discard return
	call	stackinit			@ initialize minimal stack
	ldr	w0,compsp			@ get minimal's stack pointer
	str 	w0,reg_wa			@ startup stack pointer

	cld					@ default to up direction for string ops
#	 getoff	 w0,dffnc		 # get address of ppm offset
	str	w0,ppoff			@ save for use later
	ldr	xs,osisp			@ switch to new c stack
	ldr	w1,calltab_start
	str	w1,minimal_id
	call	minimal				@ load regs, switch stack, start compiler

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




	.globl	stackinit
stackinit:
	mov	w0,xs
	str	w0,compsp		@ save as minimal's stack pointer
	ldr	w1,stacksiz
	sub	w0,w0,w1		@ end of minimal stack is where c stack will start
	str	w0,osisp		@ save new c stack pointer
	add	w0,#cfp_b*100		@ 100 words smaller for chk
	.extern	lowspmin
	str	w0,lowspmin
	mov	PC,lrret

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
#	  pushad				@ save all registers for c
	ldr	wa,reg_wa		@ restore registers
	ldr	wb,reg_wb
	ldr	wc,reg_wc		@
	ldr	xr,reg_xr
	ldr	xl,reg_xl

	str	xs,osisp		@ save osint stack pointer
	cmp	compsp,#0		@ is there a compiler stack?
	je	min1			@ jump if none yet
	mov	xs,compsp		@ switch to compiler stack

 min1:
	mov	w0,minimal_id		@ get oxrnal
	call   calltab+w0*cfp_b    	@ off to the minimal code

	ldr	xs,osisp		@ switch to osint stack

	ldr	reg_wa,wa		@ save registers
	ldr	reg_wb,wb
	ldr	reg_wc,wc
	ldr	reg_xr,xr
	ldr	reg_xl,xl
	mov	PC,lr


	.align	2
	.globl		hasfpu
hasfpu:	.word	0
	.globl	cprtmsg
cprtmsg:
	.ascii	    ' copyright 1987-2020 robert b. k. dewar and mark emmer.',0,0
	.align	2


#	interface routines

#	each interface routine takes the following form:

#		sysxx	call	ccaller @ call common interface
#		      .word	zysxx		@ dd	  of c osint function
#			db	n		@ offset to instruction after
#						@   last procedure exit

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


call_adr:	.word	0

syscall_init:
#	save registers in .globl variables

	ldr	reg_wa,wa		 	@ save registers
	ldr	reg_wb,wb
	ldr	reg_wc,wc		 	@ (also _reg_ia)
	ldr	reg_xr,xr
	ldr	reg_xl,xl
	ldr	reg_ia,ia
	mov	PC,lr

syscall_exit:
	mov	rc,w0				@ save return code from function
	str	xs,osisp		 	@ save osint's stack pointer
	ldr	xs,compsp		 	@ restore compiler's stack pointer
	ldr	wa,reg_wa		 	@ restore registers
	ldr	wb,reg_wb
	ldr	wc,reg_wc
	ldr	xr,reg_xr
	ldr	xl,reg_xl
	ldr	ia,reg_ia
	cld
	ldr	w0,reg_pc
	jmp	w0

	.macro	syscall	proc,id
	pop	w0				@ pop return address
	str	w0,reg_pc
	call	syscall_init
#	save compiler stack and switch to osint stack
	str	xs,compsp	 		@ save compiler's stack pointer
	mov	xs,osisp		 	@ load osint's stack pointer
	call	\proc
	jmp	syscall_exit			@ was a call for debugging purposes, but that would cause
						@ crash when the compilers stack pointer blew up
	.endm

	.globl sysax
	.extern	zysax
sysax:	syscall	  zysax,1

	.globl sysbs
	.extern	zysbs
sysbs:	syscall	  zysbs,2

	.globl sysbx
	.extern	zysbx
sysbx:	str	xs,reg_xs
	syscall	zysbx,2

#	 .globl syscr
#	.extern	zyscr
#syscr:	 syscall    zyscr @	,0

	.globl sysdc
	.extern	zysdc
sysdc:	syscall	zysdc,4

	.globl sysdm
	.extern	zysdm
sysdm:	syscall	zysdm,5

	.globl sysdt
	.extern	zysdt
sysdt:	syscall	zysdt,6

	.globl sysea
	.extern	zysea
sysea:	syscall	zysea,7

	.globl sysef
	.extern	zysef
sysef:	syscall	zysef,8

	.globl sysej
	.extern	zysej
sysej:	syscall	zysej,9

	.globl sysem
	.extern	zysem
sysem:	syscall	zysem,10

	.globl sysen
	.extern	zysen
sysen:	syscall	zysen,11

	.globl sysep
	.extern	zysep
sysep:	syscall	zysep,12

	.globl sysex
	.extern	zysex
sysex:	mov	[reg_xs],xs
	syscall	zysex,13

	.globl sysfc
	.extern	zysfc
#?? TODO fix below
sysfc:	pop	w0				@ <<<<remove stacked scblk>>>>
	lea	xs,[xs+wc*cfp_b]
	push	w0
	syscall	zysfc,14

	.globl sysgc
	.extern	zysgc
sysgc:	syscall	zysgc,15

	.globl syshs
	.extern	zyshs
syshs:	str	xs,reg_xs
	syscall	zyshs,16

	.globl sysid
	.extern	zysid
sysid:	syscall	zysid,17

	.globl sysif
	.extern	zysif
sysif:	syscall	zysif,18

	.globl sysil
	.extern	zysil
sysil:	syscall zysil,19

	.globl sysin
	.extern	zysin
sysin:	syscall	zysin,20

	.globl sysio
	.extern	zysio
sysio:	syscall	zysio,21

	.globl sysld
	.extern	zysld
sysld:	syscall zysld,22

	.globl sysmm
	.extern	zysmm
sysmm:	syscall	zysmm,23

	.globl sysmx
	.extern	zysmx
sysmx:	syscall	zysmx,24

	.globl sysou
	.extern	zysou
sysou:	syscall	zysou,25

	.globl syspi
	.extern	zyspi
syspi:	syscall	zyspi,26

	.globl syspl
	.extern	zyspl
syspl:	syscall	zyspl,27

	.globl syspp
	.extern	zyspp
syspp:	syscall	zyspp,28

	.globl syspr
	.extern	zyspr
syspr:	syscall	zyspr,29

	.globl sysrd
	.extern	zysrd
sysrd:	syscall	zysrd,30

	.globl sysri
	.extern	zysri
sysri:	syscall	zysri,32

	.globl sysrw
	.extern	zysrw
sysrw:	syscall	zysrw,33

	.globl sysst
	.extern	zysst
sysst:	syscall	zysst,34

	.globl systm
	.extern	zystm
systm:	syscall	zystm,35

	.globl systt
	.extern	zystt
systt:	syscall	zystt,36

	.globl sysul
	.extern	zysul
sysul:	syscall	zysul,37

	.globl sysxi
	.extern	zysxi
sysxi:	str	xs,[reg_xs]
	syscall	zysxi,38

	.macro	callext	proc,id
	.extern	\proc
	call	\proc
	add	xs,\id				@ pop arguments
	.endm

#	x64 hardware divide, expressed in form of minimal register mappings, requires dividend be
#	placed in w0, which is then sign extended into wc:w0. after the divide, w0 contains the
#	quotient, wc contains the remainder.
#
#	cvd__ - convert by division
#
#	input	ia = number <=0 to convert
#	output	ia / 10
#		wa ecx) = remainder + '0'
	.globl	cvd__
cvd__:
	.extern	i_cvd
	mov	reg_ia,ia
	mov	reg_wa,wa
	call	i_cvd
	mov	ia,reg_ia
	mov	wa,reg_wa
	mov	PC,lr


ocode:
	or	w0,w0				@ test for 0
	jz	setovr				@ jump if 0 divisor
	xchg	w0,ia				@ ia to w0, divisor to ia
	cdq					@ extend dividend
	idiv	ia		 		@ perform division. w0=quotient, wc=remainder
	seto	byte reg_fl
	mov	ia,wc
	mov	PC,lr

setovr: mov	al,1				@ set overflow indicator
	mov	byte [reg_fl],al
	mov	PC,lr

	.macro	real_op name,proc
	.globl	\name
	.extern	\proc
\name:
	str	w0,reg_rp
	call	\proc
	mov	PC,lr
	.endm

#	no real operations for bootstrap

#	real_op	ldr_,f_ldr
#	real_op	str_,f_str
#	real_op	adr_,f_adr
#	real_op	sbr_,f_sbr
#	real_op	mlr_,f_mlr
#	real_op	dvr_,f_dvr
#	real_op	ngr_,f_ngr
#	real_op cpr_,f_cpr

	.macro	int_op ent,proc
	.globl	\ent
	.extern	\proc
\ent:
	mov	reg_ia,ia
	call	\proc
	mov	PC,lr
	.endm

	int_op itr_,f_itr
	int_op rti_,f_rti

	.macro	math_op ent,proc
	.globl	\ent
	.extern	\proc
\ent:
	call	\proc
	mov	PC,lr
	.endm

*	don't support math functions for bootstrap

#	math_op	atn_,f_atn
#	math_op	chp_,f_chp
#	math_op	cos_,f_cos
#	math_op	etx_,f_etx
#	math_op	lnf_,f_lnf
#	math_op	sin_,f_sin
#	math_op	sqr_,f_sqr
#	math_op	tan_,f_tan

#	ovr_ test for overflow value in ra
	.globl	ovr_
ovr_:
#	mov	ax, word [reg_ra+6]		@ get top 2 bytes
#	and	ax, 0x7ff0			@ check for infinity or nan
#	add	ax, 0x10			@ set/clear overflow accoxrngly
	mov	PC,lr

	.globl	get_fp				@ get frame pointer

get_fp:
	 ldr	 w0,reg_xs		 	@ minimal's xs
	 add	 w0,4				@ pop return from call to sysbx or sysxi
	 ret					@ done

	.extern	rereloc

	.globl	restart
	.extern	stbas
	.extern	statb
	.extern	stage
	.extern	gbcnt
	.extern	lmodstk
	.extern	startbrk
	.extern	outptr
	.extern	swcoup

#	scstr is offset to start of string in scblk, or two words

scstr	equ	cfp_c+cfp_c

#
restart:
	pop	w0				@ discard return
	pop	w0				@ discard dummy
	pop	w0				@ get lowest legal stack value

	ldr	w1,stacksiz
	add	w0,w1
	mov	xs,w0				@ switch to this stack
	call	stackinit			@ initialize minimal stack

						@ set up for stack relocation
	lea	w0,tscblk+scstr			@ top of saved stack
	mov	wb,lmodstk			@ bottom of saved stack
	mov	wa,stbas			@ wa = stbas from exit() time
	sub	wb,w0				@ wb = size of saved stack
	mov	wc,wa
	sub	wc,wb				@ wc = stack bottom from exit() time
	mov	wb,wa
	sub	wb,xs				@ wb =	 stbas - new stbas

	str	xs,stbas	 		@ save initial sp
#	 getoff	 w0,dffnc		 	@ get address of ppm offset
	ldr	ppoff,w0	 		@ save for use later
#
#	restore stack from tscblk.
#
	ldr	xl,lmodstk			@ -> bottom word of stack in tscblk
#?? fix below
	lea	xr,tscblk+scstr			@ -> top word of stack	
	cmp	xl,xr				@ any stack to transfer?
	je	re3				@  skip if not
	sub	xl,4
	std
re1:	lodsd					@ get old stack word to w0
	cmp	w0,wc				@ below old stack bottom?
	jb	re2				@   j. if w0 < wc
	cmp	w0,wa				@ above old stack top?
	ja	re2				@   j. if w0 > wa
	sub	w0,wb				@ within old stack, perform relocation
re2:	push	w0				@ transfer word of stack
	cmp	xl,xr				@ if not at end of relocation then
	jae	re1				@    loop back

re3:	cld
	str	xs,compsp			@ save compiler's stack pointer
	ldr	xs,osisp			@ back to osint's stack pointer
	call   rereloc				@ relocate compiler pointers into stack
	mov	w0,statb			@ start of static region to xr
	str	w0,reg_xr
	mov	w0,minimal_insta
	jmp	minimal				@ initialize static region 
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
	call   startbrk				@ start control-c logic

	mov	w0,stage			@ is this a -w call?
	cmp	w0,#4
	je	      re4			@ yes, do a complete fudge

#
#	jump back with return value = normal_return
	xor	w0,w0				@ set to zero to indicate normal return
	call	syscall_exit
	mov	PC,lr

#	here if -w produced load module.  simulate all the code that
#	would occur if we naively returned to sysbx.  clear the stack and
#	go for it.
#
re4:	mov	w0,stbas
	str	w0,compsp			@ empty the stack

#	code that would be executed if we had returned to makeexec:
#
	xor	w1,w1
	mov	gbcnt,w1			@ reset garbage collect count
	call	zystm				@ fetch execution time to reg_ia
	mov	w0,reg_ia			@ set time into compiler
	.extern	timsx
	str	w0,timsx

#	code that would be executed if we returned to sysbx:
#
	push	outptr				@ swcoup(outptr)
	.extern	swcoup
	call	swcoup
	add	xs,cfp_b

#	jump to minimal code to restart a save file.

	mov	w0,minimal_rstrt
	str	w0,minimal_id
	call	minimal				@ no return

%ifdef z_trace
	.extern	zz_ra
	.globl	zzz
	.extern	zz,zz_cp,zz_xl,zz_xr,zz_wa,zz_wb,zz_wc,zz_w0
zzz:
	pushf
	call	save_regs
	call	zz
	call	restore_regs
	popf
	mov	PC,lr
%endif
