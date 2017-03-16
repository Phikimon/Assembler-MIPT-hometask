ASM=nasm

SRCPATH=./src/
INCLUDEDIR=$(SRCPATH)

COMPOPTIONS=-felf64 -i $(INCLUDEDIR)
EXEPATH=./executables/

all: ScanPrint #SumUntilZero 

SumUntilZero: $(SRCPATH)SumUntilZero.asm
	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@

#PrintBinHexOct: ./src/PrintBinHexOct.asm
#	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
#	ld $(EXEPATH)$@.o -o $(EXEPATH)$@
#
#ScanBinHexOct:  ./src/ScanBinHexOct.asm
#	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
#	ld $(EXEPATH)$@.o -o $(EXEPATH)$@

ScanPrint: ./src/ScanPrint.asm ./src/ScanBinHexOct.asm ./src/PrintBinHexOct.asm
	$(ASM) $(COMPOPTIONS) $(SRCPATH)$@.asm -o $(EXEPATH)$@.o
	ld $(EXEPATH)$@.o -o $(EXEPATH)$@
