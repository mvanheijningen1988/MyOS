/*
 * This is a simple bootloader for x86 architecture.
 * It switches to protected mode and loads a kernel into memory.
 * Created by Michael van Heijningen on 2025/03/29.
 */

#include "boot/i386/boot.h"
#include "boot/i386/offset.h"

.file "boot.S"                              # This is the source file name
.text                                       # This is the text section where the code resides
.code16                                     # This is a 16-bit code segment
.globl _start                               # Entry point for the bootloader

_start:
    xor %ax, %ax                            # Clear AX register
    mov %ax, %es                            # Set extra segment to 0
    mov %ax, %ss                            # Set stack segment to 0
    mov %ax, %ds                            # Set data segment to 0 
    mov %dl, Boot_Drive                     # Move boot drive number to boot_drive
    mov $0x7C00, %sp                        # Set up stack (grows downward from load address)

.read_variables:
    movb $0x1, Sectors                      # Load number of sectors to read into register
    movb $0x2, Sector                       # Load sector number into register
    mov $BOOTLOADER_STACK_MEM_OFFSET, %bx   # Load segment address 0x7E00 into BX                     
    call read_sectors                       # Call the function to read sectors

.show_welcome_message:    
    mov $welcome_message, %si               # Load welcome message
    call print_string                       # Call the function to print the string
    mov $real_mode_message, %si             # Load real mode message
    call print_string                       # Call the function to print the string

.load_kernel:
    movb $0x01, Sectors                     # Load number of sectors to read into register
    movb $0x02, Sector                      # Load sector number into register
    mov $KERNEL_PRE_OFFSET, %bx             # Load segment address 0x9000 into BX
    call read_sectors                       # Call the function to read sectors

    mov $kernel_loaded_message, %si         # Load kernel loaded message
    call print_string                       # Call the function to print the string

.switch_to_protected_mode:
    mov $protected_mode_message, %si        # Load protected mode message
    call print_string                       # Call the function to print the string
    call switch_to_protected_mode           # Call the function to switch to protected mode

jmp .   

read_sectors:
    mov $0x02, %ah                          # BIOS function: read sectors
    mov Sectors, %al                        # Number of sectors to read
    mov $0x00, %ch                          # Cylinder number
    mov Sector, %cl                         # Sector number
    mov $0x00, %dh                          # Head number
    mov Boot_Drive, %dl                     # Boot drive number

    int $0x13                               # Call BIOS interrupt

    jc .error                               # If carry flag is set, there was an error

    ret                                     # Return if successful

.error:
    pusha                                   # Save all registers
    mov $0x0E, %ah                          # BIOS teletype output function
    mov $'E', %al                           # Error message character
    int $0x10                               # Print error message
    popa                                    # Restore all registers
    ret

print_string:
    mov $0x0E, %ah                          # BIOS teletype output function
.next_char:
    lodsb                                   # Load the next byte from [SI] into AL, increment SI
    test %al, %al                           # Check if the character is null (end of string)
    jz .done                                # If null, we're done
    int $0x10                               # Print the character in AL
    jmp .next_char                          # Repeat for the next character

.done:
    ret                                     # Return to the caller

switch_to_protected_mode:
    cli                                     # Clear interrupts
    lgdt gdt_descriptor                     # Load GDT

    mov %cr0, %eax                          # Read control register 0
    or $0x1, %eax                           # Set PE (Protection Enable) bit
    mov %eax, %cr0                          # Write back to control register 0

    ljmp $0x08, $protected_mode_start       # Far jump to code segment 0x08

# -------------------------
# 32-bit Protected Mode
# -------------------------
.code32
protected_mode_start:
    mov $0x10, %ax                      # Load data segment selector
    mov %ax, %ds                        # Set data segment
    mov %ax, %es                        # Set extra segment
    mov %ax, %fs                        # Set FS segment
    mov %ax, %gs                        # Set GS segment
    mov %ax, %ss                        # Set stack segment
    xor %esp, %esp                      # Clear stack pointer (or set to known value)

    mov $0xB8000, %edi                  # VGA text mode address
    movb $'x', %al                      # Character to print
    movb $0x07, %ah                     # Attribute: light gray on black
    movw %ax, (%edi)                    # Write character + attribute

halt:
    hlt
    jmp halt

# -------------------------
# GDT Setup
# -------------------------
.align 8
# -------------------------
# GDT Entries (3 total)
# -------------------------
gdt:
    # --- Null Descriptor (mandatory) ---
    .word 0x0000              # Limit 15:0
    .word 0x0000              # Base 15:0
    .byte 0x00                # Base 23:16
    .byte 0x00                # Access byte
    .byte 0x00                # Flags + Limit 19:16
    .byte 0x00                # Base 31:24

    # --- Code Segment Descriptor ---
    .word 0xFFFF              # Limit 15:0 (0xFFFFF total, granularity = 4K)
    .word 0x0000              # Base 15:0
    .byte 0x00                # Base 23:16
    .byte 0x9A                # Access: present, ring 0, code, readable
    .byte 0xCF                # Flags: 4K granularity, 32-bit, Limit 19:16 = 0xF
    .byte 0x00                # Base 31:24

    # --- Data Segment Descriptor ---
    .word 0xFFFF              # Limit 15:0
    .word 0x0000              # Base 15:0
    .byte 0x00                # Base 23:16
    .byte 0x92                # Access: present, ring 0, data, writable
    .byte 0xCF                # Flags: 4K granularity, 32-bit, Limit 19:16 = 0xF
    .byte 0x00                # Base 31:24

gdt_end:

gdt_descriptor:
    .word gdt_end - gdt - 1   # Size of GDT - 1
    .long gdt                 # Linear address of GDT

.fill 507-(.-_start), 1, 0          # Add zeroes to make it total 512 bytes, subtract variables and signature

Boot_Drive: .byte 0x00              # Boot drive number
Sector:     .byte 0x00                 # Sector number
Sectors:    .byte 0x00                 # Number of sectors to read

.word BOOTLOADER_SIGNATURE          # Magic bytes that tell BIOS that this is bootable

.data
welcome_message: .asciz "Welcome to the bootloader!\r\n" # Welcome message
real_mode_message: .asciz "Running in 16-bit real mode.\r\n" # Message for 16-bit mode
protected_mode_message: .asciz "Switching to protected mode.\r\n" # Message for protected mode
kernel_loaded_message: .asciz "Kernel loaded successfully.\r\n" # Message for kernel load
kernel_start: .asciz "Kernel start address: 0x9000\r\n" # Kernel start address message