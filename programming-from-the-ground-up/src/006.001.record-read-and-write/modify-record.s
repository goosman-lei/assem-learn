.include "linux.s"
.include "record-def.s"
.include "record-funcs.s"

.section .data
input_file_name:
    .ascii "data/test.dat\0"
output_file_name:
    .ascii "data/test-mod.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.equ ST_INPUT_FD, -4
.equ ST_OUTPUT_FD, -8

.section .text
.globl _start
_start:
    movl %esp, %ebp
    subl $8, %esp

    movl $SYS_OPEN, %eax                # 打开输入文件
    movl $input_file_name, %ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_INPUT_FD(%ebp)        # 保存输入文件描述符

    movl $SYS_OPEN, %eax                # 打开输出文件
    movl $output_file_name, %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_OUTPUT_FD(%ebp)       # 保存输出文件描述符

loop_begin:
    pushl ST_INPUT_FD(%ebp)     # 读一条记录
    pushl $record_buffer
    call read_record
    addl $8, %esp

    cmpl $RECORD_SIZE, %eax     # 如果已经读完, 则结束
    jne loop_end

    incl record_buffer + RECORD_AGE     # 递增年龄

    pushl ST_OUTPUT_FD(%ebp)    # 写修改后的记录
    pushl $record_buffer
    call write_record
    addl $8, %esp

    jmp loop_begin

loop_end:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

