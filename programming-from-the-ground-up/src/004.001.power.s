# 目的: 展示函数如何工作的程序
#   本程序将计算
#   2^3 + 5^2

# 主程序中所有的内容都存储在寄存器中
# 因此数据段不包含内容
.section .data

.section .text

.globl _start

_start:
    pushl $3            # 压入第二个参数
    pushl $2            # 压入第一个参数
    call power          # 调用函数
    addl $8, %esp       # 栈指针向后移动8字节(2个字)
    pushl %eax          # 将%eax中的第一步结果, 入栈

    pushl $2            # 压入第二个参数
    pushl $5            # 压入第一个参数
    call power          # 调用函数
    addl $8, %esp       # 栈指针向后移动8字节(2个字)

    popl %ebx           # 将第一步的结果, pop到%ebx

    addl %eax, %ebx     # 将%eax和%ebx数据相加, 放入%ebx

    movl $1, %eax       # 系统调用exit()
    int $0x80

# 目的: 本函数用于计算一个数的幂
#
# 输入:
#   Arg1: 底数
#   Arg2: 指数
#
# 输出: 以返回值形式给出结果
#
# 注意: 指数必须大于等于1
#
# 变量:
#   %ebx: 保存底数
#   %ecx: 保存指数
#
#   -4(%ebp): 保存当前结果
#   %eax: 暂时存储

# 这条指令, 告诉链接器, 要将power这个符号, 当作函数处理
.type power, @function

power:
    pushl %ebp              # 将当前的栈基址指针入栈保存
    movl %esp, %ebp         # 设定当前栈顶为新的栈基址指针
    subl $4, %esp           # 栈顶前移4字节, 用于存放临时结果

    movl 8(%ebp), %ebx      # 将第一个参数(底数)放入%ebx
    movl 12(%ebp), %ecx     # 将第二个参数(指数)放入%ecx

    movl %ebx, -4(%ebp)     # 将第一个参数(底数)作为当前结果, 放入临时结果存储-4(%ebp)中

power_loop_start:
    cmpl $0, %ecx           # 如果指数为0, 则处理指数为0的特殊情况
    je end_power_with_0

    cmpl $1, %ecx           # 如果指数为1, 则结束
    je end_power

    movl -4(%ebp), %eax     # 将临时结果放入%eax
    imull %ebx, %eax        # 将%ebx和%eax相乘, 并讲解过放入%eax
    movl %eax, -4(%ebp)     # 将%eax中的计算结果, 放入临时结果存储-4(%ebp)中

    decl %ecx               # 指数递减
    jmp power_loop_start    # 递归处理

end_power_with_0:
    movl $1, %eax
    jmp end_power

end_power:
    movl -4(%ebp), %eax     # 将计算结果放入%eax作为最终结果
    movl %ebp, %esp         # 使用%ebp保存的栈基址指针, 恢复%esp的值
    popl %ebp               # 弹出上次的栈基址指针, 恢复%ebp的值
    ret
