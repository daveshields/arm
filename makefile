# SPITBOL makefile using gnu as

ws?=64

debug?=0

os?=unix

OS=$(os)
WS=$(ws)
DEBUG=$(debug)

CC=gcc
ELF=elf$(WS)


ifeq	($(DEBUG),0)
CFLAGS= -D m32 -m32 -static 
else
CFLAGS= -D m32 -g -m32
endif

# Assembler info 
# Assembler
ASM=as
ifeq	($(DEBUG),0)
ASMFLAGS = 
else
ASMFLAGS = -g
endif

# Tools for processing Minimal source file.
BASEBOL =   ./bin/sbl
# Objects for SPITBOL's LOAD function.  AIX 4 has dlxxx function library.
#LOBJS=  load.o
#LOBJS=  dlfcn.o load.o
LOBJS=

spitbol: 
#	rm sbl sbl.lex sbl.s sbl.err err.s
#	$(ASM) $(ASMFLAGS) int.asm
	$(BASEBOL) lex.sbl 
	$(BASEBOL) -x asm.sbl
#	$(BASEBOL) -x -1=sbl.err -2=err.asm err.sbl
#	$(ASM) $(ASMFLAGS) err.asm
#	$(ASM) $(ASMFLAGS) sbl.asm
#stop:
#	$(CC) $(CFLAGS) -c osint/*.c
#	$(CC) $(CFLAGS) *.o -osbl -lm
# link spitbol with dynamic linking
spitbol-dynamic: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -osbl -lm 

sbl.go:	sbl.lex go.sbl
	$(BASEBOL) -x -u i32 go.sbl


# install binaries from ./bin as the system spitbol compilers
install:
	sudo cp ./bin/sbl /usr/local/bin
clean:
	rm -f  *.o *.lst *.map *.err err.lex sbl.lex sbl.err sbl.asm err.asm ./sbl  

z:
	nm -n sbl.o >s.nm
	sbl map-$(WS).sbl <s.nm >s.dic
	sbl z.sbl <ad >ae

sclean:
# clean up after sanity-check
	make clean
	rm tbol*
