#------------------------------------------------------------------------
#																		;
#		   makefile for compiling the boot binsries						;
#			**************************************						;
#					BootA.asm	(c)	Spider_OS							;
#------------------------------------------------------------------------

#colors
R = \033[031m
G = \033[032m
B = \033[034m
Br= \033[033m
W = \033[039m

# Floppy Image parameters
floppyname	= boot.img
floppysize	= 1440
floppymake  = sudo mkfs.msdos -C $(floppyname) $(floppysize) \
				&& sudo mkfs.fat -F 12 $(floppyname)
floppydel	= sudo rm -rf $(floppyname)

# External Makefiles
BootAlo 	= ./bootA/
BootBlo 	= ./bootB/
BootClo 	= ./bootC/

ExtMake		= make -C

# External files
Stage1		= BootA.bin
Stage2		= BootB.bin
Stage3		= BootC.bin

# Lengthy Commandline functions
mountDIR 	= /media/kingkrack/floppyA
checkmount	= mountpoint -q
mountcmd 	= sudo mount -o loop
umountcmd 	= sudo umount /dev/loop0

# ;---------------------------------------
# ;	Make FLOPPY IMAGE
bootimages:
	@echo "$(B)[***] Compiling boot images$(W)"
	@$(ExtMake) $(BootAlo) Make
	@$(ExtMake) $(BootBlo) Make
	@$(ExtMake) $(BootClo) Make
	@echo "$(G)[---] Done compiling boot images"


# ;---------------------------------------
# ;	Make FLOPPY IMAGE
floppy:
	@echo "$(B)[***] Creating FAT12 floppy image $(Br)"
	@test -e $(floppyname) && $(floppydel) && $(floppymake) || $(floppymake)
	@echo "$(G)[---] Done Creating floppy image"

# ;---------------------------------------
# ;	Make FLOPPY IMAGE bootable
Make: bootimages floppy
	@echo "$(B)[***] Making floppy image Bootable $(Br)"
	@echo "[___] Mounting Floppy image"
	@$(checkmount) $(mountDIR) && $(umountcmd) ||\
				$(mountcmd) $(floppyname) $(mountDIR)
	@echo "[___] Copying second stage loader"
	@sudo cp $(BootBlo)$(Stage2) $(mountDIR)
	@echo "[___] Copying final loader"
	@sudo cp $(BootClo)$(Stage3) $(mountDIR)
	
	@echo "[___] UnMounting Floppy image"
	@$(umountcmd)
	@echo "[___] Copying first stage loader to MBR"
	@sudo dd if=$(BootAlo)$(Stage1) of=$(floppyname) seek=0 count=1 conv=notrunc
	@echo "$(G)[---] Done making floppy image Bootable$(W)"

clean:
	@echo "$(R)[***] Cleaning Boot Images $(Br)"
	@$(ExtMake) $(BootAlo) clean
	@$(ExtMake) $(BootBlo) clean
	@$(ExtMake) $(BootClo) clean
	@$(floppydel)
	
	@echo "$(G)[---] Done Cleaning boot images $(W)"
