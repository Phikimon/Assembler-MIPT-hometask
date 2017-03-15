ASM=nasm
FORMAT=-felf64
SRCPATH=./src/
EXEPATH=./executables/

all: SumUntilZero PrintBinHexOct

SumUntilZero: $(SRCPATH)SumUntilZero.asm
	$(ASM) $(FORMAT) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@

PrintBinHexOct: ./src/PrintBinHexOct.asm
	$(ASM) $(FORMAT) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@
