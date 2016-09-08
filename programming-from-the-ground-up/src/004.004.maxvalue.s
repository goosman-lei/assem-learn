# 目的: 找到一组数据中的最大值

# 变量:
#   临时数据项指针存储 %edx
#   最大数据项 %ebx
#   当前数据项 %eax
#   数据项当前索引 %edi
#   数据项索引上限 %esi

.section .data

# 数据项列表
data_items:
    .long 3, 8, 2, 39, 27, 223, 254, 17, 127, 33, 255
data_count:
    .long 11

.section .text

.globl _start

_start:
    pushl $data_items   # 将数据项指针作为第一个参数入栈
    pushl $data_count   # 将数据项个数作为第二个参数入栈
    call max_value      # 调用函数
    addl $8, %esp       # 恢复栈
    movl %eax, %ebx     # 将结果放入到%ebx

    movl $1, %eax       # exit()
    int $0x80

.type max_value, @function
max_value:
    pushl %ebp          # 栈指针固定处理
    movl %esp, %ebp

    movl $0, %edi       # 设置起始索引值0

    movl 8(%ebp), %edx              # 将第二个参数(数据项个数)的指针放入%edx
    movl (%edx), %esi               # 间访并将其值放入%esi

    movl 12(%ebp, %edi, 4), %edx    # 将第一个参数(数据项)的指针放入%edx
    movl (%edx), %ebx               # 将第一个数据项, 作为最大项, 直接放入%ebx

    jmp max_value_loop              # 进入循环

max_value_loop:
    incl %edi                       # 条件变更: 索引自增
    cmpl %edi, %esi                 # 边界检查: 是否到达最后一个索引
    je max_value_exit

    movl (%edx, %edi, 4), %eax      # 间访下一个数据项, 并放入%eax

    cmpl %ebx, %eax                 # 比较当前数据项和当前最大值
    jle max_value_loop              # 如果当前数据项小于等于当前最大值, 则直接继续循环

    movl %eax, %ebx                 # 将当前值设置为新的最大值
    jmp max_value_loop              # 继续循环

max_value_exit:
    movl %ebx, %eax                 # 将计算结果放入%eax

    movl %ebp, %esp                 # 恢复栈
    popl %ebp
    ret

