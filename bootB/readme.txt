This Directory will contain The second stage boot Loader

This boot loader
   [*] will switch to protected mode
   [*] prepare the switch by:-
	1. Disable interrupts
	2. Enabling A20 line
	3. Load the Global Descriptor Table

;-----------------------------------------------
;	General ideas
;
-> Still we are in 16bit mode
-> We need to switch to 32bit mode
-> Prepare for some high level language SEA
-> Once swiched to C then start probing disks for the stage C


} Well also load the 32bit BootC loader residing on a file system
} So this stage needs to know about file systems
	_ Am gonna implement the following first
		FAT		NTFS		EXT
	_ To be honest i only know these :)




>> https://www.youtube.com/watch?v=aDssfYbr10s

;----------------------------------------------
;	RULES

[*] FUNCTIONS = write them in capital letters
[*] Variables = Write them each word starting
		with a capital letter
[*] Macros    = Will deal with these later on
[*] LABLES    = Write them with an initial dot
		and Initial capital letter
		.Label

[*] New Rules will be added as we proceed


mkisofs -o isoname.iso -b binaryfile ./<directory>
