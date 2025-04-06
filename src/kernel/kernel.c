#include "kernel/kernel.h"

void main() {
    //initialize video memory and write hello world
    char *video_memory = (char *)0xb8000;
    char *hello = "Hello, World!";
    for (int i = 0; i < 13; i++) {
        video_memory[i * 2] = hello[i];
        video_memory[i * 2 + 1] = 0x07; // light gray on black
    }
}