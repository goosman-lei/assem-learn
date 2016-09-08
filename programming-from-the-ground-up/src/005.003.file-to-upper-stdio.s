# 目的: 本程序将输入文件的所有字母转化为大写字母, 然后输出到输出文件
#   5.5.2练习题, 使用标准输入输出

# 处理过程:
#   * 打开输入文件
#   * 打开输出文件
#   * 如果未达到输入文件尾部
#       * 将部分文件读入内存缓冲区
#       * 读取内存缓冲区每个字节, 如果该字节为小写字母, 将其转换为大写字母
#       * 将内存缓冲区写入输出文件

.section .data

######### 常数

# 系统调用号
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# 文件打开选项
#   不同值参考/usr/include/asm/fcntl.h
#   你可以通过将选项值相加或者进行OR操作组合使用选项
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# 标准文件描述符
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# 系统调用中断
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0 # 读操作的返回值, 表示到达文件结尾

.equ NUMBER_ARGUMENTS, 2

.section .bss

# 文件读写缓冲区. 由于种种原因, 缓冲区大小不应该超过16 000字节
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

# 栈位置
.equ ST_SIZE_RESERVER, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8

.globl _start

_start:
    # 程序初始化. 保存栈指针
    movl %esp, %ebp

    # 在栈上为文件描述符分配空间
    subl $ST_SIZE_RESERVER, %esp

open_files:

store_fd_in:    # 保存标准输入的文件描述符
    movl $0, ST_FD_IN(%ebp)

store_fd_out:   # 保存标准输出的文件描述符
    movl $1, ST_FD_OUT(%ebp)

read_loop_begin:
    movl $SYS_READ, %eax        # 读取BUFFER_SIZE的数据到BUFFER_DATA中
    movl ST_FD_IN(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    movl $BUFFER_SIZE, %edx
    int $LINUX_SYSCALL

    cmpl $END_OF_FILE, %eax     # 碰到EOF则结束循环
    jle read_loop_end

read_loop_continue:
    pushl $BUFFER_DATA          # 以缓冲区指针和缓冲区有效数据大小为参数, 调用大小写转换
    pushl %eax
    call convert_to_upper
    popl %eax
    addl $4, %esp

    movl %eax, %edx             # 将转换后的数据, 写入到输出文件
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    jmp read_loop_begin         # 进入下次循环

read_loop_end:
    movl $SYS_CLOSE, %eax       # 关闭输出文件
    movl ST_FD_OUT(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax       # 关闭输入文件
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_EXIT, %eax        # 退出程序
    movl $0, %ebx
    int $LINUX_SYSCALL

# 目的: 将字符串块内容转换为大写形式

# 输入:
#   第一个参数是要转换的内存块位置
#   第二个参数是缓冲区长度

# 输出: 缓冲区大小

# 变量:
#   %eax: 缓冲区开始地址
#   %ebx: 缓冲区长度
#   %edi: 缓冲区便宜量
#   %cl: 当前正在检测的字节(%ecx的低8位)

#### 常数
.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, 'A' - 'a'

#### 栈相关信息
.equ ST_BUFFER_LEN, 8
.equ ST_BUFFER, 12

convert_to_upper:
    pushl %ebp
    movl %esp, %ebp

    movl ST_BUFFER(%ebp), %eax      # 读取缓冲区指针参数放入%eax
    movl ST_BUFFER_LEN(%ebp), %ebx  # 读取缓冲区大小参数放入%ebx
    movl $0, %edi                   # 设置初始索引为0

    cmpl $0, %ebx                   # 检测如果缓冲区大小为0则结束循环
    je convert_loop_end

convert_loop:
    movb (%eax, %edi, 1), %cl       # 将缓冲区当前字节放入%cl

    cmpb $LOWERCASE_A, %cl          # 判定当前字节是否是小写字母
    jl convert_loop_next            # 不是则continue
    cmpb $LOWERCASE_Z, %cl
    jg convert_loop_next

    addb $UPPER_CONVERSION, %cl     # 增加大小写编码区差值, 完成转换(寄存器内)
    movb %cl, (%eax, %edi, 1)       # 将转换后的值写回内存缓冲区

convert_loop_next:
    incl %edi                       # 调整索引值
    cmpl %edi, %ebx                 # 判定是否该继续循环
    jne convert_loop

convert_loop_end:
    movl %ebp, %esp                 # 恢复栈基址指针和栈指针
    popl %ebp
    ret
