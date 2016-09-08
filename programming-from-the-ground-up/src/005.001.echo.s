# 目的: 读取标准输入的100个字节, 输出到标准输出

.section .bss

.lcomm buffer, 100

.section .text

.globl _start

_start:
    movl $3, %eax       # read(0, buff, 100)
    movl $0, %ebx
    movl $buffer, %ecx
    movl $100, %edx
    int $0x80

    movl $4, %eax       # write(1, buff, 100)
    movl $1, %ebx
    movl $buffer, %ecx
    movl $100, %edx
    int $0x80

    movl $1, %eax
    int $0x80
