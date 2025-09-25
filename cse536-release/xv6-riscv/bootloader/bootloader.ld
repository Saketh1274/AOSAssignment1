OUTPUT_ARCH( "riscv" )

/* Task: ensure the correct starting function. */
ENTRY( _entry )

SECTIONS
{
  /* Task: ensure the correct entry address based on where -kernel in QEMU jumps. */
  . = 0x80000000;

  /* Task lay out the sections as mentioned in the handout */
  .text : { *(.text*) }
  ecode = .;

  .rodata : { *(.rodata*) }
  erodata = .;

  .data : { *(.data*) }
  edata = .;

  .bss : { 
    *(.bss*) 

    bl_stack = .;
    . = . + (8 * 4096);  
    bl_stack_end = .;

    ebss = .;}
  ebss = .;

  end = .;
}
