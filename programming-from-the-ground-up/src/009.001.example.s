.include "009.001.memory-alloc.s"

.section .data

buffer_ptr:
    .long 0

.equ BUFFER_SIZE, 8192

.section .text
.globl _start
_start:
    call alloc_init

    pushl $BUFFER_SIZE
    call alloc
    addl $4, %esp

    movl %eax, buffer_ptr

    pushl buffer_ptr
    call dealloc
    addl $4, %esp

    movl $1, %eax
    movl $0, %ebx
    int $0x80

