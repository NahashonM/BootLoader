#------------------------------------------------------------------------
#																		;
#				makefile for first Stage Loader							;
#			***************************************						;
#					BootA.asm	(c)	Spider_OS							;
#------------------------------------------------------------------------

#colors
R = \033[031m
G = \033[032m
B = \033[034m
Br= \033[033m
W = \033[039m

objects = BootA.bin

%.bin: %.asm
	@nasm -f bin $< -o $@
	
Make: $(objects)
	@echo "$(B)[***] Making BootA.asm"
	@echo "$(G)[___] BootA Successfull $(W)"
	
clean:
	rm -rf *.bin
