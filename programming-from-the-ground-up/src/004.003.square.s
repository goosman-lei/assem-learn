# 目的: 给定一个数字, 本程序将计算其平方值

.section .data

.section .text

.globl _start

_start:
    pushl $5
    call square
    addl $4, %esp
    movl %eax, %ebx

    movl $1, %eax
    int $0x80

.type square @function
square:
    pushl %ebp          # 保存上次的栈基址指针
    movl %esp, %ebp     # 将当前栈顶放入栈基址指针

    movl 8(%ebp), %eax  # 取第一个参数, 放入%eax
    imull %eax, %eax    # 计算平方值并放入%eax

    movl %ebp, %esp     # 恢复栈顶指针
    popl %ebp           # 恢复栈基址指针

    ret
