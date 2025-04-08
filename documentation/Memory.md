# Memory Mapping for MyOS

This document outlines the memory layout for the bootloader and kernel in MyOS.

---

## Memory Layout

| **Address Range**    | **Size**       | **Description**                                      |
|----------------------|----------------|------------------------------------------------------|
| `0x00000` - `0x003FF` | 1 KB          | Interrupt Vector Table (IVT)                         |
| `0x00400` - `0x004FF` | 256 bytes     | BIOS Data Area (BDA)                                 |
| `0x00500` - `0x07BFF` | ~30.5 KB      | Free memory for general use                          |
| `0x07C00` - `0x07DFF` | 512 bytes     | Bootloader (loaded by BIOS)                          |
| `0x07E00` - `0x08FFF` | ~4.5 KB       | Bootloader stack and temporary variables             |
| `0x09000` - `0x09FFF` | ~4 KB         | BIOS read buffer (used to load additional sectors)   |
| `0x0A000` - `0x0FFFF` | ~24 KB        | Reserved for BIOS and video memory (VGA, etc.)       |
| `0x100000` and above  | Depends       | Kernel (final location for execution, 1MB and up)    |

---

## Key Memory Regions

### **Bootloader**
- **Address**: `0x7C00`
- **Size**: 512 bytes
- **Description**: The bootloader is loaded by the BIOS into this address. It initializes the system, reads kernel data into memory, and switches to protected mode.

### **BIOS Read Buffer**
- **Address**: `0x9000`
- **Size**: ~4 KB
- **Description**: Used by the bootloader to load additional sectors from the boot drive into memory before switching to protected mode.

### **Bootloader Stack**
- **Address**: `0x7E00` - `0x8FFF`
- **Size**: ~4.5 KB
- **Description**: Temporary stack space and buffer area for real-mode operations before switching to protected mode.

### **Kernel**
- **Address**: `0x100000` (1 MB)
- **Size**: Depends on the kernel size (e.g., `0x2000` bytes or 8 KB in this case).
- **Description**: The kernel is relocated to this address for execution. This address is aligned to a 4 KB page boundary and is compatible with protected mode and paging.

---

## Notes
1. **Alignment**:
   - The kernel is loaded at `0x100000` (1 MB), which is aligned to a 4 KB page boundary for compatibility with paging.
   - The bootloader is loaded at `0x7C00` by the BIOS, as per the x86 boot protocol.

2. **Reserved Memory**:
   - Memory below `0x1000` is reserved for the IVT and BIOS data.
   - Memory between `0xA000` and `0xFFFF` is reserved for BIOS and video memory.

3. **Kernel Relocation**:
   - The kernel is first loaded into the buffer at `0x9000` and then relocated to `0x100000` for execution.

---