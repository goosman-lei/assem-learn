# 目的: 向指定文件写入"Hello World!\n"

.equ LINUX_SYSCALL, 0x80

.equ SYSCALL_OPEN, 5
.equ SYSCALL_WRITE, 4
.equ SYSCALL_CLOSE, 6

.equ O_CREAT_WRONLY_TRUNC, 03101

.section .data

# 定义程序运行需要的数据
STRING_LITERAL:
    .string "Hello World!\n"
STRING_LEN:
    .long 13
FNAME_LITERAL:
    .string "data/helloworld.txt"

.section .text

.globl _start

_start:
    pushl %ebp      # 参数栈处理, 预留局部变量文件句柄的存储
    movl %esp, %ebp
    subl $4, %esp

    movl $SYSCALL_OPEN, %eax            # 读写方式打开目标文件
    movl $FNAME_LITERAL, %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL
    movl %eax, -4(%ebp)

    movl -4(%ebp), %ebx                 # 将数据写入目标文件
    movl $STRING_LEN, %eax
    movl (%eax), %edx
    movl $SYSCALL_WRITE, %eax
    movl $STRING_LITERAL, %ecx
    int $LINUX_SYSCALL

    movl $SYSCALL_CLOSE, %eax           # 关闭目标文件
    movl -4(%ebp), %ebx
    int $LINUX_SYSCALL

    movl %ebp, %esp                     # 恢复参数栈
    popl %ebp

    movl $1, %eax                       # exit()
    int $LINUX_SYSCALL
