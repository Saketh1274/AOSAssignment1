

.section .text
.global _entry
_entry:
        # task: setup a per-CPU stack for C and jump to start() function
        la sp, bl_stack_end
        li a0, 4096
        csrr a1, mhartid
        addi a1, a1, 1
        mul a0, a0, a1
        sub sp, sp, a0


        jal ra, start

spin:
        j spin
