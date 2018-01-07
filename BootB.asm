
bits 16


jmp	MAIN_LOADER

DriveNo		db	0		; Device from which we were booted



MAIN_LOADER:
	
	mov	byte [DriveNo], dl	; Save boot drive number

	;----------------------------------------------
	;	Setup the segment registers
	;----------------------------------------------

	mov	ax, cs
	mov	ds, ax
	mov	es, ax

	cli
	add	ax, End_Of_Stage2		; Stack Begins above us
	mov	ss, ax
	mov	sp, 4096			; 4k Stack
	sti



cli
hlt

End_Of_Stage2:











