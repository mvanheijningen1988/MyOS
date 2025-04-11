/*
 * This file is not standalone and should not be compiled directly.
 * It is included in the bootloader and is responsible for loading the kernel from a EXT filesystem.
 */
.file "ext.S"

.equ MEMORY_IO_EXT_SUPERBLOCK_ADDRESS, (MEMORY_CONVENTIONAL_MEM_OFFSET + 0x200)

.equ EXT_SUPERBLOCK_INODES_COUNT_OFFSET, 0x00
.equ EXT_SUPERBLOCK_BLOCKS_COUNT_OFFSET, 0x04
.equ EXT_SUPERBLOCK_RBLOCKS_COUNT_OFFSET, 0x08
.equ EXT_SUPERBLOCK_FREE_BLOCKS_COUNT_OFFSET, 0x0C
.equ EXT_SUPERBLOCK_FREE_INODES_COUNT_OFFSET, 0x10
.equ EXT_SUPERBLOCK_FIRST_DATA_BLOCK_OFFSET, 0x14
.equ EXT_SUPERBLOCK_LOG_BLOCK_SIZE_OFFSET, 0x18
.equ EXT_SUPERBLOCK_BLOCKS_PER_GROUP_OFFSET, 0x20
.equ EXT_SUPERBLOCK_INODES_PER_GROUP_OFFSET, 0x28
.equ EXT_SUPERBLOCK_MAGIC_OFFSET, 0x38

.equ EXT_SUPERBLOCK_MAGIC_NUMBER, 0xEF53
.equ EXT_SUPERBLOCK_OFFSET, 0x0400
.equ EXT_SUPERBLOCK_SIZE, 0x0400
.equ EXT_SUPERBLOCK_SECTOR_START, 0x03              # (EXT_SUPERBLOCK_OFFSET / BOOT_SECTOR_SIZE) + 1 since 1 based
.equ EXT_SUPERBLOCK_SECTOR_SIZE, 0x02               # (EXT_SUPERBLOCK_SIZE / BOOT_SECTOR_SIZE)

load_kernel:    
    mov $MEMORY_IO_EXT_SUPERBLOCK_ADDRESS, %bx      # Load the address of the superblock memory address
    shr $0x04, %bx                                  # Shift right by 4 bits to get the address of the superblock
    mov %bx, %es                                    # Load the address of the superblock into ES
    call read_ext4_superblock                       # Call the function to read the EXT superblock
    call determine_block_size                       # Call the function to determine the block size
    ret 

read_ext4_superblock:   
    mov $0x0, %bx                                   # Clear the BX register                        
    mov $0x02, %ah                                  # BIOS function: read sectors
    mov $EXT_SUPERBLOCK_SECTOR_SIZE, %al            # Number of sectors to read
    mov $0x00, %ch                                  # Cylinder number
    mov $EXT_SUPERBLOCK_SECTOR_START, %cl           # Sector number (1-based)
    mov $0x00, %dh                                  # Head number
    mov MEMORY_BOOT_DRIVE_ADDRESS, %dl              # Boot drive number

    int $0x13                                       # Call BIOS interrupt stored in memory location [es:bx]
    jc .error                                       # If carry flag is set, there was an error

    cmp $EXT_SUPERBLOCK_SECTOR_SIZE, %al            # Check if the number of sectors read is 0
    jne .error                                      # If so, jump to error
    je .validate_superblock                         # If not, jump to validate superblock

.validate_superblock:   
    mov $EXT_SUPERBLOCK_MAGIC_OFFSET, %di           # Offset to the magic number
    movw %es:(%di), %ax                             # Read the magic number from the superblock
    cmpw $EXT_SUPERBLOCK_MAGIC_NUMBER, %ax          # Vergelijk met ext magic
    jne .not_valid                                  # Jump if not valid
    ret                                             # Return if valid


.error: 
    mov $disk_error_message, %si                    # Load the message to print
    call print_string                               # Call the print_string function
    mov %ax, %bx                                    # Move the error code to %al
    call print_hex_string                           # Call the print_hex function
    jmp halt                                        # Jump to halt if there was an error

.not_valid: 
    mov $ext_magic_error_message, %si               # Load the message to print
    call print_string                               # Call the print_string function
    jmp halt                                        # Jump to halt if not valid

determine_block_size:
    movw $EXT_SUPERBLOCK_LOG_BLOCK_SIZE_OFFSET, %di # Offset naar block size
    movw %es:(%di), %cx                             # Lees 2 bytes vanaf ES:DI in AX
    mov $0x400, ext_block_size                      # Set %bx to 1024
    shl %cl, ext_block_size                         # Shift left by %cl bits to get the block size
    ret

disk_error_message: .asciz "Disk error: "
ext_magic_error_message: .asciz "Invalid superblock.\r\n"
ext_block_size: .word 0x0000
