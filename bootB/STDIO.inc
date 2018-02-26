;===============================================
;	16bit BIOS Routines
;

%ifndef	__16BIT_STDIO_INC___
%define	__16BIT_STDIO_INC___

Bios_Print:
	pusha
  .Print_Loop:
	lodsb
	cmp	al, 0
	je	.Print_Done
	
	mov	ah, 0xe
	int	10h
	jmp	.Print_Loop

  .Print_Done:
  	popa
  	ret
			;------ Bios_Print Done---------


Bios_Reboot:
	mov	ax, 0
	int	16h
	
	mov	ax, 0
	int	19h
	
			;------ Bios_Reboot Done---------



%endif	;__16BIT_STDIO_INC___
