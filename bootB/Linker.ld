/*
*       Linker.ld
*/
OUTPUT_FORMAT("binary")
ENTRY(_Start)
SECTIONS
{
        . = 0x000500;
        .text   : { 
        	*(.text)
        	*(.rodata)
         }
         
        .data   : {
         	*(.data)
         }
         
        .bss    : {
        	*(.bss) 
        }
}

