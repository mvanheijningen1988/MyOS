# Memory Mapping for MyOS

This document outlines the memory layout for the bootloader and kernel in MyOS.

---

## Memory Layout

| **Address Range**          | **Size**       | **Description**                                      |
|----------------------------|----------------|------------------------------------------------------|
| `0x0000000` - `0x000003FF` | 1 KiB          | Real Mode IVT (Interrupt Vector Table)               |
| `0x0000400` - `0x000004FF` | 256 bytes      | BIOS Data Area (BDA)                                 |
| `0x0000500` - `0x00007BFF` | 29.75 KiB      | Conventional memory (usable memory)                  |
| `0x0007C00` - `0x00007DFF` | 512 bytes      | Bootloader (loaded by BIOS)                          |
| `0x0007E00` - `0x0007FFFF` | 480.5 KiB      | Conventional memory                                  |
| `0x0080000` - `0x0009FFFF` | 128 KiB        | EBDA (Extended BIOS Data Area)                       |
| `0x00A0000` - `0x000BFFFF` | 128 KiB        | Video display memory (hardware mapped)               |
| `0x00C0000` - `0x000C7FFF` | 32 KiB         | Video BIOS                                           |
| `0x00C8000` - `0x000EFFFF` | 160 KiB        | BIOS Expansions                                      |
| `0x00F0000` - `0x000FFFFF` | 64 KiB         | Motherboard BIOS                                     |

---