;===============================================
;	GDT and A20Line 16bit Routines
;

%ifndef	__A20__LINE__GDT__INC__
%define	__A20__LINE__GDT__INC__


;;;---------------------------------------------
;;		A20 LINE FUNCTIONS
;
		;***** A20 Enable ******
		;	ax = 1(ok) | 0(fail)
A20_Enable:
	pusha

	call	A20_Status
	cmp	ax, 1
	je	.SUCCESS

	call	A20_KEYBOARD_IO			; Try the keyboard IO port
	call	A20_Status			; This works for me
	cmp	ax, 1
	je	.SUCCESS

	call	A20_KEYBOARD_CONTROLLER		; Try the keyboard controller
	call	A20_Status
	cmp	ax, 1
	je	.SUCCESS

	call	A20_BIOS			; Try The BIOS
	call	A20_Status
	cmp	ax, 1
	je	.SUCCESS

	call	A20_FAST_GATE			; Try fast A20 gate
	call	A20_Status
	cmp	ax, 1
	je	.SUCCESS


  .FAILED:
	popa
	mov	ax, 0
  	jmp	.Done

  .SUCCESS:
  	popa
	mov	ax, 1

  .Done:
  	ret
				;----- Bios A20 Enable Done --------
				


		;***** Bios A20 Enable ******
		;
		
	A20_BIOS:
		mov	ax, 0x2403			; Test check BIOS support
		int	0x15

		jb	.Exit				; If not supported just exit
		cmp	ah, 0				; 
		jnz	.Exit				; Also no support

		mov	ax, 0x2402			; Get A20 status via
		int	0x15
		jb	.Exit				; On Fail
		
		cmp	ah, 0
		jnz	.Exit				; Another Fail

		cmp	al, 1
		jz	.Exit				; Arleady activated

		mov	ax, 0x2401			; Try enabling
		int	0x15
		
	.Exit:
   		ret
				;----- Bios A20 Enable Done --------
				
				
				
		;***** Fast Gate A20 Enable ******
		;

	A20_FAST_GATE:
		push	ax
		cli

		in	al, 0x92
		test	al, 2
		jnz	.ArleadyEn

		or	al, 2
		and	al, 0xFE
		out	0x92, al

    .ArleadyEn:
    	sti
		pop	ax
		ret
				;----- Fast Gate A20 Enable Done --------
				

		;***** Keyboard Port A20 Enable ******
		;

	A20_KEYBOARD_IO:
		cli
		pusha
	
		call	Wait_Input
		mov	al, 0xAD		; Disable Keyboard
		out	0x64, al
		call	Wait_Input
	
		mov	al, 0xD0		; Tell controller to read IO port
		out	0x64, al
		call	Wait_Input
	
		in	al, 0x60		; Store output port data
		push	eax
		call	Wait_Input
	
		mov	al, 0xD1		; Tell controller to write to IO port
		out	0x64, al
		call	Wait_Input
	
		pop	eax
		or	al, 2
		out	0x60, al
	
		call	Wait_Input
		mov	al, 0xAE
		out	0x64, al
	
		call	Wait_Input
	
		popa
		sti
		ret
	
	Wait_Input:
	   	push	ax
	
		in	al, 0x64
		test	al, 2
		jnz	Wait_Input
		pop	ax

		ret

	Wait_Output:
	   	push	ax
		
		in	al, 0x64
		test	al, 1
		jnz	Wait_Output
		pop	ax
		
		ret		
				;----- KB port A20 Enable Done --------
				
				
		;***** Keyboard controller A20 Enable ******
		;

	A20_KEYBOARD_CONTROLLER:
		cli
		push	ax

		mov	al, 0xDD
		out	0x64, al

		pop	ax
		sti
		ret
				;----- KB controller A20 Enable Done --------
				
				
		;***** Check A20 Status ******
		;

	A20_Status:
		pushf
		push	ds
		push	es
		push	di
		push	si

		xor	ax, ax
		mov	es, ax			; es = 0

		not	ax
		mov	ds, ax			; ds = 0xFFFF

		xor	ax, ax
		mov	ax, 0x0500
		mov	di, ax			; di = 0x0500

		xor	ax, ax
		mov	ax, 0x0510
		mov	si, ax			; si = 0x0510

		; Save memory locations
		;
		mov	al, byte [es:di]
		push	ax
		mov	al, byte [ds:si]
		push	ax
	
		; Write test values to locations
		;
		mov	byte [es:di], 0x00	;  00500
		mov	byte [ds:si], 0xFF	; 100500

		cmp	byte [es:di], 0xFF

		pop	ax
		mov	byte [ds:si], al

		pop	ax
		mov	byte [es:di], al

		mov	ax, 0
		je	.exit			; A20 disabled ax = 0

		mov	ax, 1			; A20 enabled ax = 1
   	.exit:
   		pop	si
		pop	di
		pop	es
		pop	ds
		popf
   		ret	
		
		
;;;---------------------------------------------
;;		Global Descriptor Table
;

GDT_INSTALL:
	cli
	pusha
	lgdt	[GDT_Address]
	popa
	sti
	ret


GDT_START:
	Null_Seg:
		dd	0
		dd	0
		
	Code_Seg:
		dw	0xFFFF					; limit low
		dw	0						; base low
		db	0						; base middle
		db	10011010b				; access
		db	11001111b				; granularity
		db	0						; base high
	Data_Seg:
		dw	0xFFFF					; limit low
		dw	0						; base low
		db	0						; base middle
		db	10010010b				; access
		db	11001111b				; granularity
		db	0						; base high

GDT_END:

GDT_Address:
	dw	GDT_END - GDT_START - 1			; limit
	dd	GDT_START						; Base Address


	Null_Segment	equ	Null_Seg - GDT_START
	Code_Segment	equ	Code_Seg - GDT_START
	Data_Segment	equ	Data_Seg - GDT_START


%endif		;__A20__LINE__GDT__INC__
