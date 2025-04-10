/*
 * Stage 1.5 Bootloader
 * Stage 1.5 is responsible for locating the kernel, loading it into memory and handoff control to it.
 * This part of the boot process is run in real mode, which is a 16-bit mode of the x86 architecture 
 */

.file "strage1-5.S"
.section .text
.code16
.globl start, _start

.include "src/boot/i386/memory.S"
.include "src/boot/i386/constants.S"

start:
_start:

call load_kernel

jmp halt

.include "src/boot/i386/ext.S"
.include "src/boot/i386/print.S"

halt:
    hlt                                 # Halt the CPU
    jmp halt                            # Infinite loop to prevent further execution
