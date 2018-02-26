bits 16

JumpCheck	equ	0xDAD


jmp Main
nop

	;---------------------------------------------------------
	;	BPB BLOCK	:)
	;
OEMLabel		db "Sp!d3r OS "	; Disk label


BytesPerSector		dw 512		; Bytes per sector
SectorsPerCluster	db 1		; Sectors per cluster
ReservedForBoot		dw 1		; Reserved sectors for boot record
NumberOfFats		db 2		; Number of copies of the FAT
RootDirEntries		dw 224		; Number of entries in root dir
LogicalSectors		dw 2880		; Number of logical sectors
MediumByte		db 0F0h		; Medium descriptor byte
SectorsPerFat		dw 9		; Sectors per FAT
SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
Sides			dw 2		; Number of sides/heads
HiddenSectors		dd 0		; Number of hidden sectors
LargeSectors		dd 0		; Number of LBA sectors
Driveno			dw 0		; Drive No: 0
Signature		db 41		; Drive signature: 41 for floppy
VolumeID		dd 00000000h	; Volume ID: any number
VolumeLabel		db "Sp!d3r_OS    "; Volume Label: any 11 chars
FileSystem		db "FAT12   "	; File system type: don't change!

RootDirOffset	equ	19	; bootsect : reserved : FATS
RootDirSize	equ	14	; (224 * 32) / 9 = 14
FATSects	equ	18	; 2fats * 9bytesperfat
FATOffset	equ	1	; logically 1 (reserv 0, Fat 1)
DataSectorBase	equ	31	; reserv(0) + FATs(18) + RootDir(14)
SizeOfCluster	equ	512	; (sectorspercluster * bytespersector)
ImageLoadSeg	equ	0050h	; This is where we'll load the stage 2 Loader
				; was thinking of loading at 0A21:0000
ImageLoadOfset	equ	0000h	; And this is that locations offset
EOF		equ	0FF8h	; FAT12 EOF Marker

	;---------------------------------------------------------
	;	Beginnig of Main Code
	;
Main:
	cmp	ax, JumpCheck
	je	Main_BootLoader

	mov	ax, JumpCheck
	mov	[DriveNo], dl

	cli
	mov	si, 07C0h
	mov	ds, si
	mov	es, si

	add	si, 544
	mov	ss, si
	mov	sp, 4096
	sti

	jmp	07C0h:0000

	;---------------------------------------------------------
	;	Beginnig of Main Code
	;
Main_BootLoader:

	mov	si, message
	call	Bios_Print


	;---------------------------------------------------------
	;		Now We read the Root Dir		 ;
	;---------------------------------------------------------

	mov	bx, DiskBuffer				; buffer offset
	mov	byte [ReadSects], RootDirSize		; Size of RootDir

	mov	ax, RootDirOffset			; Offset of DIR
	call	LBA_CHS					; Set_Registers
	call	Bios_Read

	;---------------------------------------------------------
	;		Search for Stage2Loader			 ;
	;---------------------------------------------------------

	call Search_Loader


	;---------------------------------------------------------
	;			Now We get FAT			 ;
	;---------------------------------------------------------

	mov	bx, DiskBuffer				; buffer offset
	mov	byte [ReadSects], FATSects		; Size of FATs

	mov	ax, FATOffset				; Offset of FATs
	call	LBA_CHS					; Set_Registers
	call	Bios_Read


	;---------------------------------------------------------
	;		Load The BootB.bin Image		  ;
	;---------------------------------------------------------

	;------ Set Base address to load image in ES :::::::::::::
	;------ Store Offset in BX	:::::::::::::::::::::
	;------ BX offset will be increased after every cluster read

	mov	ax, ImageLoadSeg			; Base to load image
	mov	es, ax
	mov	bx, 0000h				; offset from Base to load
							; We'll need to increase this
							; After every Read
	call	Load_Image

	xor	dx, dx
	mov	dl, byte [DriveNo]
	;---------------------------------------------------------
	;			Jump to the Image		  ;
	;---------------------------------------------------------

	jmp	ImageLoadSeg:ImageLoadOfset


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;\/\/\/\//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;---------------------------------------------------------
;	You are now banished from this segment		 ;
;		"_"   "_"   "_"   "_"			 ;
;---------------------------------------------------------


	;---------------------------------------------------------
	;	BIOS ROUTINES
	;=========================================================

;**********************************************************	
;------Print Function--------------------------------------
;

Bios_Print:
   pusha
   mov	ah, 0eh

.Print_Repeat:
	lodsb
	cmp	al, 0
	je	.Bios_Print_End
	int 10h

	jmp	.Print_Repeat

.Bios_Print_End:
     popa
     ret


;**********************************************************	
;------ Reset Floppy Function -----------------------------
;

Bios_Reset_Floppy:	; IN: [bootdev] = boot device; OUT: carry set on error
	mov	ax, 0
	mov	dl, byte [DriveNo]
	stc
	int	13h
    ret

;**********************************************************	
;------Restart PC Function--------------------------------------
;

Bios_Restart:
	mov	ax, 0
	int	16h				; Wait for keystroke
	mov	ax, 0
	int	19h				; Reboot the system


;**********************************************************	
;------Read Function--------------------------------------
;

Bios_Read:
	mov	dl, byte [DriveNo]
	mov	ah, 2
	mov	al, byte [ReadSects] 

	pusha
.Bios_Read_Start:
	popa
	pusha					; Save all registers
	
	stc
	int	13h				; Bios Read function
	
	jnc	.Bios_Read_Done			; If reading went okay

	call	Bios_Reset_Floppy		; Reset Floppy on error
	jnc	.Bios_Read_Start

	mov	si, ErrorMessage		; on error print error message
	call	Bios_Print
	call	Bios_Restart			; Restart PC
.Bios_Read_Done:
     popa
     ret




	;---------------------------------------------------------
	;	BOOTLOADER ROUTINES
	;=========================================================

;**********************************************************	
;------	LBA -> CHS	::	Function ------------------

;  abs_Head = LBA / sectorsPerTrack % numofHeads 
;  abs_Track= LBA / SectorsPerTrack / numofHeads
;
LBA_CHS:
   push	bx
	
	mov	bx, ax
	
	; calculate the physical sector and store in cl

	mov	dx, 0
	div	word [SectorsPerTrack]		; dl => sector
	
	add	dl, 1h				; physical start 1
	mov	cl, dl				; Store in cl

	; Calculate the Heads from quotient in ax
	
	mov	dx, 0
	mov	ax, bx
	div	word [SectorsPerTrack]

	mov	dx, 0
	div	word [Sides]
	mov	dh, dl
	mov	ch, al
   pop	bx
   ret

;**********************************************************	
;------	Search Stage 2 Loader Function ------------------

Search_Loader:
	mov	di, DiskBuffer

	mov	cx, word [RootDirEntries]
	mov	ax, 0

.Next_Entry:
	xchg cx, dx			; We use CX in the inner loop...

	mov	si, Loader2Name		; Start searching for kernel filename
	mov	cx, 11			; rep cmpsb increases the array pointer
					; so well have to reasign si every time
	rep cmpsb
	je	.Loader_Found		; Pointer DI will be at offset 11

	add	ax, 32
	mov	di, DiskBuffer
	add	di, ax

	xchg	dx, cx
	loop	.Next_Entry

	mov	si, ErrorMessage
	call	Bios_Print
	call	Bios_Restart

.Loader_Found:
	mov	ax, word [es:di + 0Fh]		; di will be at 11 add 15 to get to 26
	mov	word [Loader2Cluster], ax	; Save its Cluster number
    ret


;**********************************************************	
; ------   Load Stage 2 image Function ------------------
; -- We'll Load Cluster By Cluster
;

Load_Image:

	mov	al, byte [SectorsPerCluster]		; Size of 1 cluster
	mov	byte [ReadSects], al			; We'll one cluster at a time

	;--------------------------------------------------------
	;------Above Params load the first cluster----------------
	;	

.Next_Cluster:
	mov	ax, [Loader2Cluster]			; Ofset of 1st cluster in data sect

	push	bx
	push	ax

	add	ax, DataSectorBase			; add data sect offset to get lba

	call	LBA_CHS					; Set_Registers
	call	Bios_Read				; read that cluster

	;**************************************
	; --- FAT Entry = ( (LBA x 3) / 2 )+ 1

	pop	ax
	mov	dx, 0

	mov	bx, 03h
	mul	bx
	mov	bx, 02h
	div	bx

	;****************************************
	;----- Get FAT entry of cluster in cx ---
	;
	mov	bx, DiskBuffer
	add	bx, ax
	mov	ax, word [bx]
	
	;****************************************
	; ---- FAT offset is in AX --------------
	; ---- We need to know if even/odd offset
	; ---- Odd cluster offset point to a byte
	; ----    whose lower 4bits are of previous
	; ----    cluster ofset
	; ----  XX XY YY ZZ ZA AA

	or	dx, dx					; check if remainder is 0
	jz	.Even_Cluster				;  after dvision by two

.Odd_Cluster:
	;
	; Odd cluster first 4 bytes are of
	;     the cluster pointer below it

	shr	ax, 4
	jmp	.Check_Next

.Even_Cluster:
	;
	; even cluster last 4 bytes are of nxt
	;     cluster

	and	ax, 0x0FFF				; shift em out by 4

.Check_Next:
	mov	word [Loader2Cluster], ax		; Store cluster
	pop	bx					; restore read mem offset

	cmp	ax, EOF					; FF8h = FAT12 EOF
	jae	.Image_Load_End

	add	bx, SizeOfCluster			; Add offset size of cluster
	jmp	.Next_Cluster

.Image_Load_End:
    ret


	;---------------------------------------------------------
	;	BOOTLOADER DATA AND STRINGS
	;

;**********************************************************	
;------DATA VARIABLES--------------------------------------
;

Loader2Cluster	dw	0
Loader2Name	db	"BOOTB   BIN",0
DriveNo		db	0
ReadSects	db	0


;**********************************************************	
;------STRING VARIABLES -----------------------------------
;

message		db	"[*] Loading.!",0xa,0xd,0
ErrorMessage	db	"[*] Error Loading. Press any key to restart!",0xa,0xd,0



DiskBuffer:


times 510-($-$$) db 0
dw	0xAA55
