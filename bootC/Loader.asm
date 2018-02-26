;#------------------------------------------------------------------------
;#																		;
;#						3rd Stage Loader								;
;#				This will b made as a .asm & .c							;
;#	 			in a cross compiler environment							;	
;#			***************************************						;
;#					BootC.asm	(c)	Spider_OS							;
;#------------------------------------------------------------------------

bits 32

section .text
;extern Loader_Start
global start
global printf
start:
	mov	eax, 0xFFFFFF
	mov	esp, eax

	;call	Loader_Start
	;push chart
	cli
	hlt

printf:
	mov	eax, [esp+4]
	mov	esi, eax
	
	mov	al, byte [esi]
	mov	ebx, 0xB8000
	
	mov	byte [ebx], al
	mov	byte [ebx], al

section .data
	cursor db 0
	chart	db 'A'
	
