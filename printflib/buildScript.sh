#!/bin/bash
nasm -felf64 -i ../src/ printflibfastcall.asm -o temp_files/printflibfastcall.o
gcc -c main.c -o temp_files/main.o
gcc temp_files/main.o temp_files/printflibfastcall.o -o main
