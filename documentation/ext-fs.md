# EXT Filesystem Layout

This document outlines the structure and layout of the EXT filesystem, providing a high-level overview followed by detailed descriptions of each component.

---

## High-Level Overview

| **Offset (Bytes)**         | **Size**       | **Component**                              |
|----------------------------|----------------|--------------------------------------------|
| `0x000` - `0x1FF`          | 512 bytes      | Boot Sector (optional, not part of EXT)    |
| `0x200` - `0x3FF`          | 512 bytes      | Reserved                                   |
| `0x400` - `0x7FF`          | 1024 bytes     | Superblock                                 |
| `0x800` - `Variable`       | Variable       | Block Group Descriptor Table               |
| `Variable`                 | Variable       | Block Bitmap                               |
| `Variable`                 | Variable       | Inode Bitmap                               |
| `Variable`                 | Variable       | Inode Table                                |
| `Variable`                 | Variable       | Data Blocks                                |

---

## 1. Boot Sector (Superblock)
- **Offset**: 0x400 (1 KB from the start of the partition)
- **Size**: 1024 bytes
- **Description**: Contains metadata about the filesystem, such as block size, total blocks, free blocks, and inode information.

### Key Fields in the Superblock:
| Field Name              | Offset (Bytes) | Size (Bytes) | Description                              |
|-------------------------|----------------|--------------|------------------------------------------|
| `s_inodes_count`        | 0x00           | 4            | Total number of inodes                  |
| `s_blocks_count`        | 0x04           | 4            | Total number of blocks                  |
| `s_r_blocks_count`      | 0x08           | 4            | Reserved blocks count                   |
| `s_free_blocks_count`   | 0x0C           | 4            | Free blocks count                       |
| `s_free_inodes_count`   | 0x10           | 4            | Free inodes count                       |
| `s_first_data_block`    | 0x14           | 4            | First data block                        |
| `s_log_block_size`      | 0x18           | 4            | Block size (2^(10 + value))             |
| `s_blocks_per_group`    | 0x20           | 4            | Number of blocks per block group        |
| `s_inodes_per_group`    | 0x28           | 4            | Number of inodes per block group        |
| `s_magic`               | 0x38           | 2            | Magic number (0xEF53 for EXT)           |

---

## 2. Block Groups
- **Description**: The filesystem is divided into block groups for better management and performance. Each block group contains:
  - Block Group Descriptor Table
  - Block Bitmap
  - Inode Bitmap
  - Inode Table
  - Data Blocks

### Block Group Descriptor Table:
| Field Name              | Offset (Bytes) | Size (Bytes) | Description                              |
|-------------------------|----------------|--------------|------------------------------------------|
| `bg_block_bitmap`       | 0x00           | 4            | Block ID of the block bitmap            |
| `bg_inode_bitmap`       | 0x04           | 4            | Block ID of the inode bitmap            |
| `bg_inode_table`        | 0x08           | 4            | Block ID of the inode table             |
| `bg_free_blocks_count`  | 0x0C           | 2            | Free blocks count in the group          |
| `bg_free_inodes_count`  | 0x0E           | 2            | Free inodes count in the group          |

---

## 3. Block Bitmap
- **Description**: A bitmap indicating which blocks in the group are free (0) or used (1).
- **Size**: 1 bit per block in the group.

---

## 4. Inode Bitmap
- **Description**: A bitmap indicating which inodes in the group are free (0) or used (1).
- **Size**: 1 bit per inode in the group.

---

## 5. Inode Table
- **Description**: Contains metadata for each file or directory in the group.
- **Size**: Each inode is typically 128 bytes.

### Key Fields in an Inode:
| Field Name              | Offset (Bytes) | Size (Bytes) | Description                              |
|-------------------------|----------------|--------------|------------------------------------------|
| `i_mode`                | 0x00           | 2            | File mode (type and permissions)        |
| `i_uid`                 | 0x02           | 2            | Owner ID                                |
| `i_size`                | 0x04           | 4            | File size in bytes                      |
| `i_atime`               | 0x08           | 4            | Last access time                        |
| `i_ctime`               | 0x0C           | 4            | Creation time                           |
| `i_mtime`               | 0x10           | 4            | Last modification time                  |
| `i_dtime`               | 0x14           | 4            | Deletion time                           |
| `i_block`               | 0x28           | 60           | Pointers to data blocks                 |

---

## 6. Data Blocks
- **Description**: Contains the actual file and directory data.
- **Size**: Determined by the block size (e.g., 1 KB, 2 KB, 4 KB).

---

## 7. Directory Structure
- **Description**: Directories are stored as a list of directory entries.
- **Directory Entry Format**:
  | Field Name      | Size (Bytes) | Description                     |
  |-----------------|--------------|---------------------------------|
  | `inode`         | 4            | Inode number                   |
  | `rec_len`       | 2            | Length of this record          |
  | `name_len`      | 1            | Length of the name             |
  | `file_type`     | 1            | Type of the file               |
  | `name`          | Variable     | File or directory name         |

---

## Summary of Key Offsets
| Component                  | Offset (Bytes) | Description                              |
|----------------------------|----------------|------------------------------------------|
| Boot Sector (Superblock)   | 0x400          | Filesystem metadata                     |
| Block Group Descriptor     | 0x800          | Describes block groups                  |
| Block Bitmap               | Variable       | Tracks used/free blocks                 |
| Inode Bitmap               | Variable       | Tracks used/free inodes                 |
| Inode Table                | Variable       | Metadata for files and directories      |
| Data Blocks                | Variable       | Actual file and directory data          |

This mapping provides a comprehensive reference for understanding the EXT filesystem layout.