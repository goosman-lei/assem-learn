# 目的: 本程序寻找一组数据项中的最大值

# 变量: 寄存器有以下用途
#
#   %edi: 保存正在检测的数据项索引
#   %ebx: 当前已经找到的最大的数据项
#   %eax: 当前数据项

# 使用以下内存位置:
#
# data_items: 包含数据项
#             0 表示数据结束

.section .data

data_items: # 指代其后位置的标签
    # .long使得汇编程序为.之后的数字列表保留内存
    # data_items指向第一个数字的位置
    # movl data_items, %eax会将第一个数字3放入到%eax中
    # 其他类型:
        # .byte     1字节
        # .int      2字节
        # .long     4字节
        # .ascii    字符串, 不定字节, 每个字符占用一个字节
    .long 3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66, 0

.section .text

# data_items并没有被声明为.globl, 因为它只在程序内部被使用
.globl _start

_start:
    movl $0, %edi                       # 将0放入索引寄存器
    movl data_items(, %edi, 4), %eax    # 加载数据的第一个4字节, 放到%eax中
                                        # 内存地址读取指令: 内存起始地址(, %索引寄存器, 字长)
    movl %eax, %ebx                     # 由于这是第一项, 因此直接就是最大的, 放入%ebx

start_loop:
    cmpl $0, %eax       # 比较0和%eax中的值
    je loop_exit        # 如果%eax的值等于0, 则跳转到loop_exit, 执行退出

    incl %edi                           # 增加%edi的值
    movl data_items(, %edi, 4), %eax    # 读取下一个data_items的值, 放入%eax

    cmpl %ebx, %eax                     # 比较%ebx和%eax的值
    jle start_loop                      # 如果%eax的值小于等于%ebx的值, 则跳到start_loop循环执行

    movl %eax, %ebx                     # 将新的最大值从%eax放入%ebx
    jmp start_loop                      # 跳转到start_loop执行循环

loop_exit:
    movl $1, %eax
    int $0x80
