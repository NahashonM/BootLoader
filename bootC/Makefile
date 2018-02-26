#------------------------------------------------------------------------
#																		;
#			 	  makefile for 3rd Stage Loader							;
#				This will b made as a .asm & .c							;
#	 			in a cross compiler environment							;	
#			***************************************						;
#					BootC.asm	(c)	Spider_OS							;
#------------------------------------------------------------------------

#colors
R = \033[031m
G = \033[032m
B = \033[034m
Br= \033[033m
W = \033[039m


nasmparam	= -f elf32
gccparam	= -m32 -c
linkscript	= Linker.ld
ldparam		= -m elf_i386 -T $(linkscript)

imagename	= BootC.bin
objects 	= Loader.o CLoader.o

%.o: %.asm
	@nasm $(nasmparam) $< -o $@
	
%.o: %.c
	@gcc $(gccparam) $< -o $@

%.bin: $(objects)
	ld $(ldparam) $(objects) -o $@

Make: $(imagename)
	@echo "$(B)[***] Making BootC.asm"
	@echo "$(G)[___] BootC Successfull $(W)"
	
clean:
	rm -rf *.bin
	rm -rf *.o
