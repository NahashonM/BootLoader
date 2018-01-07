# --------------------------------------------------------------------
#		(c)Sp!d3r OS Bootloader Makefile
#	Apart from compiling the BootA and BootB binaries
#     The Makefile also creates a floppy image of size 4gb
#    The image is then used to create a bootable Disk image
#
# --------------------------------------------------------------------

# Name of floppy drive img
FloName = Spider.img
# Size of floppy drive in bytes 512mb
FloSize = 1440
cmdFNF  = echo "\033[032m[***]Image Arleady Exists"
cmdFNN  = sudo mkfs.msdos -C $(FloName) $(FloSize) \
	  && sudo mkfs.fat -F 12 $(FloName)
mountDIR = ./floppyA
echmount = echo "\033[032mArleady Mounted"
chkmount = mountpoint -q 
mountcmd = sudo mount -o loop
umountcmd = sudo umount /dev/loop0
echumount = echo "\033[032mNot Mounted"

#ISO
isodir = Spider
isomes = echo "\033[032m[******]DIRECTORY NOT FOUND"
vlabel = "Spider Zero"
isonam = "Sp!d3r OS.iso"

NasmPar = -f bin
Stage1Loader = BootA.bin
Stage2Loader = BootB.bin
Objects = $(Stage1Loader) $(Stage2Loader) # kernel.bin

%.bin: %.asm
	nasm $(NasmPar) $< -o $@

# ;---------------------------------------
# ;	Make Copy The images to Iso directory
#
dumpflop: floppy $(Objects)
	echo "[***] mount floppy first"
	test -e $(FloName) && $(chkmount) $(mountDIR) && $(echmount) ||\
	       	$(mountcmd) $(FloName) $(mountDIR) || $(cmdFNF)

	echo "[***] Copy all other files into it"
	sudo cp $(Stage2Loader) $(mountDIR)

	echo "[***] unmount the floppy drive and DD it"
	$(chkmount) $(mountDIR) && $(umountcmd) || $(echumount)

	sudo dd if=$(Stage1Loader) of=$(FloName) seek=0 count=1 conv=notrunc


# ;---------------------------------------
# ;	Make FLOPPY IMAGE
#
floppy: 
	test -e $(FloName) && $(cmdFNF) || $(cmdFNN)


# ;---------------------------------------
# ;	Make ISO IMAGE
iso: dumpflop
	test -d $(isodir) && $(isomes) || mkdir $(isodir)
	cp $(FloName) $(isodir)
	genisoimage -quiet -V $(vlabel) -input-charset iso8859-1 -o $(isonam) -b $(FloName) \
	    -hide $(FloName) $(isodir)/



mountFloppy:
	test -e $(FloName) && $(chkmount) $(mountDIR) && $(echmount) ||\
	       	$(mountcmd) $(FloName) $(mountDIR) || $(cmdFNF)

unmountFloppy:
	$(chkmount) $(mountDIR) && $(umountcmd) || $(echumount)

clean:
	rm -rf Spider
	rm -rf *.bin
	rm -rf *.img
	rm -rf *.iso




