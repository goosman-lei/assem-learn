.include "record-def.s"
.include "linux.s"

.section .data
NEWLINE:
    .ascii "\n"

.section .text

.globl read_record
.globl write_record
.globl count_chars
.globl write_newline

# 目的: 此函数从文件描述符读取一条记录
# 输入: 文件描述符和缓冲区
# 输出: 本函数将数据写入缓冲区, 并返回状态码
.equ ST_READ_BUFFER, 8
.equ ST_READ_FD, 12
.type read_record, @function
read_record:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx      # 保护%ebx

    movl ST_READ_FD(%ebp), %ebx
    movl ST_READ_BUFFER(%ebp), %ecx
    movl $RECORD_SIZE, %edx
    movl $SYS_READ, %eax
    int $LINUX_SYSCALL

    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret


# 目的: 此函数写一条记录到文件描述符
# 输入: 文件描述符和缓冲区
# 输出: 返回状态码
.equ ST_WRITE_BUFFER, 8
.equ ST_WRITE_FD, 12
.type write_record, @function
write_record:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx

    movl ST_WRITE_FD(%ebp), %ebx
    movl ST_WRITE_BUFFER(%ebp), %ecx
    movl $RECORD_SIZE, %edx
    movl $SYS_WRITE, %eax
    int $LINUX_SYSCALL

    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret

# 目的: 对字符进行计数, 直到遇到空字符

# 输入: 字符串地址

# 输出: 将计数器返回到%eax

# 过程: 用到的寄存器:
#   %ecx: 字符计数
#   %al: 当前字符
#   %edx: 当前字符地址

.equ ST_STRING_START_ADDRESS, 8
.type count_chars, @function
count_chars:
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx                               # 初始化计数
    movl ST_STRING_START_ADDRESS(%ebp), %edx    # 初始化地址

count_loop_begin:
    movb (%edx), %al                            # 读取一个字节, 检查是否空字节
    cmpb $0, %al
    je count_loop_end

    incl %ecx                                   # 索引和内存自增
    incl %edx
    jmp count_loop_begin

count_loop_end:
    movl %ecx, %eax                             # %eax返回长度计数

    movl %ebp, %esp
    popl %ebp
    ret

# 目的: 写一个换行符到STDOUT
.equ ST_WRITE_NEWLINE_FD, 8
.type write_newline, @function
write_newline:
    pushl %ebp
    movl %esp, %ebp

    movl $SYS_WRITE, %eax
    movl ST_WRITE_NEWLINE_FD(%ebp), %ebx
    movl $NEWLINE, %ecx
    movl $1, %edx
    int $LINUX_SYSCALL

    movl %ebp, %esp
    popl %ebp
    ret
