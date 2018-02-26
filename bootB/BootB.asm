;org	0x500

bits 16

;----------------------------------------------------
;; Repair Segments to zero
;

extern MAIN
global _Start
section .text

_Start:
					; Data Segments
	mov	ax, 0
	mov	ds, ax
	mov	es, ax
					; Stack Segment
	mov	ax, 0x900
	mov	ss, ax
	add	ax, 0xF6FF
	mov	sp, ax			; Setup 4k Stack
			;---- Done ---------

	jmp New_Section

;[[[----3xt3rnal 1nclud35----]]]

	%include	"A20LINEGDT.inc"
	%include	"STDIO.inc"

	;[[[---- Done With 1nclud35 ----]]]

;[[[---- Strings ----]]]

	LodMsg	db	"[***] Booting Core.img...!", 0xa,0xd,0
	A20Msg	db	"__[*] Enabling A20 line...!", 0xa, 0xd, 0
	GdtMsg	db	"__[*] Installing GDT...!", 0xa, 0xd, 0
	PmoMsg	db	"__[*] Jumping to protected mode...!", 0xa, 0xd, 0
		
	ErrMsg	db	0xa,0xd,"\/\/\ Error Booting Core.img...!", 0xa,0xd
			db	"\/\/\ Press any Key to restart...!", 0

	;[[[---- Done With 5tr1ng5 ----]]]

New_Section:

	mov	si, LodMsg
	call Bios_Print

;----------------------------------------------------
;; Road to Protected Mode
;
;================	; Enable A20 line
	mov	si, A20Msg
	call Bios_Print

	call	A20_Enable

	cmp	ax, 1
	je	A20_SUCKS

	mov	si, ErrMsg
	call Bios_Print
	
	call Bios_Reboot

A20_SUCKS:
			;---- A20 Enable Done ---------


;================	; Install A GDT

	mov	si, GdtMsg
	call Bios_Print
	
	call	GDT_INSTALL
		
			;---- GDT install Done ---------


;================	; The jump

	mov	si, PmoMsg
	call Bios_Print

	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	jmp	Code_Segment:Segment_Fix

bits 32	

Segment_Fix:
	mov	ax, Data_Segment
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
			;---- The Jump Done -------------

;================	; Calling C code

	MOV	EAX, 0XB8000
	MOV BYTE [EAX], 'a'

	call MAIN

			;---- Okay Sea Called -------------
			

cli
hlt
