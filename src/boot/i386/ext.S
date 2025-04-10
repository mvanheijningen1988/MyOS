.file "ext.S"

.equ EXT_MAGIC_NUMBER, 0xEF53
.equ EXT_INODES_COUNT_OFFSET, 0x00
.equ EXT_BLOCKS_COUNT_OFFSET, 0x04
.equ EXT_RBLOCKS_COUNT_OFFSET, 0x08
.equ EXT_FREE_BLOCKS_COUNT_OFFSET, 0x0C
.equ EXT_FREE_INODES_COUNT_OFFSET, 0x10
.equ EXT_FIRST_DATA_BLOCK_OFFSET, 0x14
.equ EXT_LOG_BLOCK_SIZE_OFFSET, 0x18
.equ EXT_BLOCKS_PER_GROUP_OFFSET, 0x20
.equ EXT_INODES_PER_GROUP_OFFSET, 0x28
.equ EXT_MAGIC_OFFSET, 0x38

.equ EXT_SUPERBLOCK_OFFSET, 0x0400
.equ EXT_SUPERBLOCK_SIZE, 0x0400
.equ EXT_SUPERBLOCK_SECTOR_START, 0x03 # (EXT_SUPERBLOCK_OFFSET / BOOT_SECTOR_SIZE) + 1 since 1 based
.equ EXT_SUPERBLOCK_SECTOR_SIZE, 0x02 # (EXT_SUPERBLOCK_SIZE / BOOT_SECTOR_SIZE)

load_kernel:
.read_ext4_superblock:
    mov $MEMORY_IO_EXT_SUPERBLOCK_ADDRESS, %bx # Set buffer address to load the superblock
    mov $0x02, %ah                      # BIOS function: read sectors
    mov $EXT_SUPERBLOCK_SECTOR_SIZE, %al # Number of sectors to read
    mov $0x00, %ch                      # Cylinder number
    mov $EXT_SUPERBLOCK_SECTOR_START, %cl # Sector number (1-based)
    mov $0x00, %dh                      # Head number
    mov MEMORY_BOOT_DRIVE_ADDRESS, %dl  # Boot drive number

    int $0x13                           # Call BIOS interrupt
    jc .error                           # If carry flag is set, there was an error
    
    cmp $EXT_SUPERBLOCK_SECTOR_SIZE, %al # Check if the number of sectors read is 0
    jne .error                          # If so, jump to error

    pusha                               # Save all registers
    movw $EXT_MAGIC_OFFSET, %di         # Offset naar magic
    movw %es:(%bx,%di), %ax             # Lees 2 bytes vanaf ES:BX+0x38 in AX
    cmpw $EXT_MAGIC_NUMBER, %ax         # Vergelijk met ext magic
    jne .not_valid                      # Jump if not valid
    popa                                # Restore all registers
    ret

    .error:
        mov $disk_error_message, %si        # Load the message to print
        call print_string                   # Call the print_string function
        mov %ax, %bx                        # Move the error code to %al
        call print_hex_string               # Call the print_hex function
        jmp halt                            # Jump to halt if there was an error

    .not_valid:
        mov $ext_magic_error_message, %si   # Load the message to print
        call print_string                   # Call the print_string function
        jmp halt                            # Jump to halt if not valid

disk_error_message: .asciz "Disk error: "
ext_magic_error_message: .asciz "Invalid superblock.\r\n"