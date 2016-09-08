.include "linux.s"
.include "record-def.s"
.include "record-funcs.s"

.section .data
# 下面是想要写入的常量数据, 每个数据项以空字节(0)填充到适当长度
#
# .rept用于填充每一项. 语法:
#   .rept 30    # 填充30次
#   .byte 0     # 使用0字节填充
#   .endr       # 结束填充

record1:
    .ascii "Fredrick\0"
    .rept 31
    .byte 0
    .endr

    .ascii "Bartlett\0"
    .rept 31
    .byte 0
    .endr

    .ascii "4242 S Prairie\nTulsa, OK 55555\0"
    .rept 209
    .byte 0
    .endr

    .long 45

record2:
    .ascii "Marilyn\0"
    .rept 32
    .byte 0
    .endr

    .ascii "Taylor\0"
    .rept 33
    .byte 0
    .endr

    .ascii "2224 S Johannan St\nChicago, IL 12345\0"
    .rept 203
    .byte 0
    .endr

    .long 29

record3:
    .ascii "Derrick\0"
    .rept 32
    .byte 0
    .endr

    .ascii "McIntire\0"
    .rept 31
    .byte 0
    .endr

    .ascii "500 W Oakland\nSan Diego, CA 54321\0"
    .rept 206
    .byte 0
    .endr

    .long 36

file_name:
    .ascii "data/test.dat\0"

.equ ST_WRITE_RECORD_FD, -4
.globl _start
_start:
    movl %esp, %ebp
    subl $4, %esp

    movl $SYS_OPEN, %eax                # 打开待写入文件
    movl $file_name, %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_WRITE_RECORD_FD(%ebp) # 保存文件描述符

    pushl ST_WRITE_RECORD_FD(%ebp)      # 写第一条记录
    pushl $record1
    call write_record
    addl $8, %esp

    pushl ST_WRITE_RECORD_FD(%ebp)      # 写第二条记录
    pushl $record2
    call write_record
    addl $8, %esp

    pushl ST_WRITE_RECORD_FD(%ebp)      # 写第三条记录
    pushl $record3
    call write_record
    addl $8, %esp

    movl $SYS_CLOSE, %eax               # 关闭文件描述符
    movl ST_WRITE_RECORD_FD(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_EXIT, %eax                # exit()
    movl $0, %ebx
    int $LINUX_SYSCALL

