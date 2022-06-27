MEMORY
{
    rom     :   org = 0x000000    ,   len = 0x20000      
    ram     :   org = 0x020000    ,   len = 0xE0000
}

ENTRY(_mstart)
    __stacktop = ORIGIN(ram) + LENGTH(ram) - 0x1000 - 4;   /* Stack Top = 0x000F_EFFC */

SECTIONS {
    . = 0x0;
    .text : 
    { 
         KEEP(*(.stack))
         KEEP(*(.text)) 
    } > rom
    .rodata : { *(.rodata) }  > rom
    . = 0x20000;
    .sdata : { *(.sdata) }  > ram
    .data : { *(.data) }    > ram
    .sbss  : { *(.sbss) } > ram
    .bss  : { *(.bss) *(COMMON) } > ram
   

        }   

