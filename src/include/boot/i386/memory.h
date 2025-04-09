#ifndef OFFSET_HEADERS
#define OFFSET_HEADERS

// Real mode address space (the first MiB)

// Interrupt Vector Table (IVT)
#define IVT_START               0x00000000
#define IVT_END                 0x000003FF
#define IVT_SIZE                0x0400  // 1 KiB

// BIOS Data Area (BDA)
#define BDA_START               0x00000400
#define BDA_END                 0x000004FF
#define BDA_SIZE                0x0100  // 256 bytes

// Usable Conventional Memory
#define CONVENTIONAL_MEM_START  0x00000500
#define CONVENTIONAL_MEM_END    0x00007BFF
#define CONVENTIONAL_MEM_SIZE   0x76FF // 29 KiB

// Boot Sector
#define BOOT_SECTOR_START       0x00007C00
#define BOOT_SECTOR_END         0x00007DFF
#define BOOT_SECTOR_SIZE        0x200  // 512 bytes

// Conventional Memory
#define CONVENTIONAL_MEM2_START 0x00007E00
#define CONVENTIONAL_MEM2_END   0x0007FFFF
#define CONVENTIONAL_MEM2_SIZE  0x781FF // 480 Kib

// Extended BIOS Data Area (EBDA)
#define EBDA_START              0x00080000
#define EBDA_END                0x0009FFFF
#define EBDA_SIZE               0x20000  // 128 KiB

// Video Display Memory
#define VIDEO_MEM_START         0x000A0000
#define VIDEO_MEM_END           0x000BFFFF
#define VIDEO_MEM_SIZE          0x20000  // 128 KiB

// System / Reserved Memory ("Upper Memory")
#define UPPER_MEM_START         0x000C0000
#define UPPER_MEM_END           0x000FFFFF
#define UPPER_MEM_SIZE          (UPPER_MEM_END - UPPER_MEM_START + 1)

// Video BIOS
#define VIDEO_BIOS_START        0x000C0000
#define VIDEO_BIOS_END          0x000C7FFF
#define VIDEO_BIOS_SIZE         0x8000  // 32 KiB

// BIOS Expansions
#define BIOS_EXPANSION_START    0x000C8000
#define BIOS_EXPANSION_END      0x000EFFFF
#define BIOS_EXPANSION_SIZE     0x28000  // 160 KiB

// Motherboard BIOS
#define MOTHERBOARD_BIOS_START  0x000F0000
#define MOTHERBOARD_BIOS_END    0x000FFFFF
#define MOTHERBOARD_BIOS_SIZE   0x10000  // 64 KiB

#endif // OFFSET_H