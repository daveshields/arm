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

	.data	0


	.global	dave
dave:	.int	75

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

	.global	save_cp
	.global	save_xl
	.global	save_xr
	.global	save_xs
	.global	save_wa
	.global	save_wb
	.global	save_wc
	.global	save_w0

#
# words saved during exit(-3)
# 
	.align 2

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

reg_pc: .word	0		    	@ return pc from caller
reg_xs:	.word	0			@ minimal stack pointer

	.set	r_size,10*cfp_b
reg_size:	.word   r_size		@ used only in sysxi in osint

# reg_rp is used to pass pointer to real operand for real arithmetic
# this is not needed for arm version, since real operands are single word.

reg_rp:	.word	0

# reg_fl is used to communicate condition codes between minimal and c code.

	.global	reg_fl
reg_fl:	.word	0			@ condition code register for numeric operations
	

	.align	2
#  constants

	.global	ten
ten:	.word	10		    	@ constant 10

	.global	inf
inf:	.word	0
	.word	    0x7ff00000	    	@ double precision infinity

	.global	lowspin
lowspmin:	.word	0

#sav_block: times r_size db 0		@ save minimal registers during push/pop reg

sav_block:
	.rept	r_size	
	.word	0
	.endr
	.word	0

	.align	2
	.global	ppoff
ppoff:	.word	0			@ offset for ppm exits

	.global	compsp
ppoff_:	.word	ppoff
compsp_: .word	compsp
sav_compsp_:	.word	sav_compsp

compsp: .word	0			@ compiler's stack pointer

	.global	sav_compsp
sav_compsp:
	.word	0			@ save compsp here
	.global	osisp
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
minimal_id:	.word	0		@ id for call to minimal from c. see proc minimal below.

	.set	setreal,0

#	setup a number of internal addresses in the compiler that cannot
#	be directly accessed from within c because of naming difficulties.

	.global	id1
id1:	.word   0
	.if	setreal
	.word	     2
       	.word	    1
	.word  "1x\x00\x00\x00"
	.endif

	.global	id1blk
id1blk:	.word	 152
	.word	  0
	.rept	152
	.byte	0
	.endr


	.global	id2blk
id2blk:	.word	 152
	.word	  0
	.rept	152
	.byte	0
	.endr

	.global	ticblk
ticblk:	.word	 0
      	.word	0

	.global	tscblk
tscblk:	 .word	  512
      	.word	0
	.rept	512
	.byte	0
	.endr

#	standard input buffer block.

	.global	inpbuf
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


