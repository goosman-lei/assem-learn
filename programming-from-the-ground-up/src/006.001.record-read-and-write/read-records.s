.include "linux.s"
.include "record-def.s"
.include "record-funcs.s"

.section .data
file_name:
    .ascii "data/test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text

.globl _start

_start:
    .equ ST_INPUT_FD, -4
    .equ ST_OUTPUT_FD, -8

    movl %esp, %ebp
    subl $8, %esp

    movl $SYS_OPEN, %eax    # 只读打开文件
    movl $file_name, %ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_INPUT_FD(%ebp)        # 保存文件描述符
    movl $STDOUT, ST_OUTPUT_FD(%ebp)    # 保存输出的文件描述符

record_read_loop_begin:
    pushl ST_INPUT_FD(%ebp)     # 读一条记录
    pushl $record_buffer
    call read_record
    addl $8, %esp

    cmpl $RECORD_SIZE, %eax     # 检查是否读到了
    jne record_read_loop_end

    pushl $RECORD_FIRSTNAME + record_buffer # 计算读到的记录中, Firstame的长度
    call count_chars
    addl $4, %esp

    movl %eax, %edx                                 # 写Firstname
    movl ST_OUTPUT_FD(%ebp), %ebx
    movl $SYS_WRITE, %eax
    movl $RECORD_FIRSTNAME + record_buffer, %ecx
    int $LINUX_SYSCALL

    pushl ST_OUTPUT_FD(%ebp)                        # 写换行符
    call write_newline
    add $4, %esp

    jmp record_read_loop_begin                      # 循环

record_read_loop_end:
    movl %ebp, %esp
    
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
