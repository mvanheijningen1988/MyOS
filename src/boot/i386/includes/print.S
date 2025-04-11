print_string:
    pusha                               # Save all registers
    mov $0x0E, %ah                      # BIOS teletype function
.next_char:
    lodsb                               # Load the next byte from the string into %al
    or %al, %al                         # Check if the character is null (end of string)
    jz .done                            # If null, we're done
    int $0x10                           # Print the character
    jmp .next_char                      # Repeat for the next character
.done:
    popa                                # Restore all registers
    ret                                 # Return to the caller

print_hex_string:
    pusha                               # Save all registers
    mov $0x0E, %ah                      # BIOS teletype function

    # Print the "0x" prefix
    mov $'0', %al                       # Load '0' into %al
    int $0x10                           # Print '0'
    mov $'x', %al                       # Load 'x' into %al
    int $0x10                           # Print 'x'

    # Print the hexadecimal value
    mov %bx, %dx                        # Copy the value to %dx (preserve %bx)
    mov $0x04, %cx                      # Set loop counter for 4 hex digits (16 bits)

.next_digit:
    rol $0x04, %dx                      # Rotate left to bring the next nibble to the highest position
    mov %dl, %al                        # Copy the nibble to %al
    and $0x0F, %al                      # Mask out all but the lowest 4 bits
    cmp $0x0A, %al                      # Check if the nibble is >= 10
    jl .convert_to_char                 # If less than 10, it's a digit
    add $'A' - 10, %al                  # Convert to ASCII letter (A-F)
    jmp .print_char
.convert_to_char:
    add $'0', %al                       # Convert to ASCII digit (0-9)
.print_char:
    int $0x10                           # Print the character
    loop .next_digit                    # Repeat for the next nibble

    popa                                # Restore all registers
    ret                                 # Return to the caller
