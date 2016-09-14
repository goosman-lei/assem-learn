.include "linux.s"

.section .data

helloworld:
    .ascii "Hello world\n\0"

.section .text
.globl _start
_start:
    pushl $helloworld
    call printf
    addl $4, %esp

    pushl $0
    call exit
    addl $4, %esp
