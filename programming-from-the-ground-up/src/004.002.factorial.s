# 目的: 给定一个数字, 本程序将计算其阶乘.
#   例如, 3的阶乘是3 * 2 * 1, 值为6
#   4的阶乘为4 * 3 * 2 * 1, 值为24

# 本程序展示了如何递归调用一个函数

.section .data

.section .text

.globl _start
.globl factorial  # 除非希望可以和其他程序共享此项, 否则不需要

_start:
    pushl $4            # 参数4入栈
    call factorial      # 调用函数
    addl $4, %esp       # 栈还原
    movl %eax, %ebx     # 计算结果放入%ebx

    movl $1, %eax       # exit()
    int $0x80

.type factorial @function
factorial:
    pushl %ebp          # 保存上次的栈基址指针
    movl %esp, %ebp     # 将当前栈顶放入栈基址指针

    movl 8(%ebp), %eax  # 取第一个参数, 放入%eax
    cmpl $1, %eax       # 如果第一个参数值为1, 则结束递归
    je end_factorial

    decl %eax           # 将%eax的值自减
    pushl %eax          # 将自减后的值入栈
    call factorial      # 递归调用
    movl 8(%ebp), %ebx  # 将递归结果放入%ebx

    imull %ebx, %eax    # factorial(N - 1) * N放入%eax

end_factorial:
    movl %ebp, %esp     # 将%ebp保存的栈顶恢复
    popl %ebp           # 恢复上次的栈基址指针

    ret
