ASM=nasm

SRCPATH=./src/
INCLUDEDIR=$(SRCPATH)

COMPOPTIONS=-felf64 -i $(INCLUDEDIR)
EXEPATH=./executables/

all: printf

SumUntilZero: $(SRCPATH)SumUntilZero.asm
	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@

ScanPrint: ./src/ScanPrint.asm ./src/ScanBinHexOct.asm ./src/PrintBinHexOct.asm
	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@

printf: ./src/printf.asm ./src/printflib.asm ./src/PrintBinHexOct.asm
	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@
