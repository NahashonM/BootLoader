#------------------------------------------------------------------------
#																		;
#				makefile for second Stage Loader						;
#			***************************************						;
#					BootB.asm	(c)	Spider_OS							;
#------------------------------------------------------------------------

#colors
R = \033[031m
G = \033[032m
B = \033[034m
Br= \033[033m
W = \033[039m

targetarch	= elf_i386

nasmparam	= -f elf
gccparam	= -ffreestanding -nostdinc -m32 -c
ldparam		= -m $(targetarch) --ignore-unresolved-symbol _GLOBAL_OFFSET_TABLE_ -T Linker.ld

objects = BootB.o CoreB.o STDIO.o
Target	= BootB.bin

%.o: %.c
	@echo "$(Br)	/Compiling $(@) with gcc"
	@gcc $(gccparam) $< -o $@

%.o: %.asm
	@echo "$(Br)	/Compiling $(@) with nasm"
	@nasm $(nasmparam) $< -o $@

%.bin: $(objects)
	@echo "$(Br)	/Linking $(objects) with ld"
	@ld $(ldparam) $(objects) -o $@
	
Make: $(Target)
	@echo "$(B)[***] Making BootB.asm"
	@echo "$(G)[___] BootB Successfull $(W)"

clean:
	rm -rf *.o
	rm -rf *.bin
