# 目的: 用于管理内存使用的程序 -- 按需分配和释放内存

# 注意: 使用这些例程的程序将要求一定大小的内存. 在实际操作中, 我们使用
#   的内存更大, 但在回传指针前将之放在开始处.
#   我们增加一个大小字段, 以及一个AVAILABLE/UNAVAILABLE标记
#   因此, 内存看起来如下所示:
#   #######################################################
#   #AVAILABLE标记#内存大小#实际内存位置#
#   #######################################################
#                                        ^--返回指针指向此处
# 为了方便调用程序, 返回的指针仅仅指向所请求的实际内存位置.
# 这也让我们无需改调用程序即可更改结构

.section .data

#########全局变量#############

# 我们管理的内存的起始处
heap_begin:
    .long 0

# 我们管理的内存之后的一个内存位置
current_break:
    .long 0

#####结构信息####
# 内存区头空间大小
.equ HEADER_SIZE, 8
# 头中AVAILABLE标志的位置
.equ HDR_AVAIL_OFFSET, 0
# 头中大小字段的位置
.equ HDR_SIZE_OFFSET, 4

#####常量#####
.equ UNAVAILABLE, 0     # 标记已分配空间的数字
.equ AVAILABLE, 1       # 标记已回收空间的数字
.equ SYS_BRK, 45        # 终端系统调用的系统调用号

.equ LINUX_SYSCALL, 0x80

.section .text

##alloc_init##
# 目的: 调用此函数来初始化. 无参数和返回值
.globl alloc_init
.type alloc_init, @function
alloc_init:
    pushl %ebp
    movl %esp, %ebp

    # 如果发起brk系统调用时, %ebx内容为0, 该调用将返回最后一个有效的可用地址
    movl $SYS_BRK, %eax     # 确定中断点
    movl $0, %ebx
    int $LINUX_SYSCALL

    incl %eax           # %eax现为最后有效的可用地址, 我们需要此地址之后的下一个内存地址

    movl %eax, current_break    # 保存当前中断

    movl %eax, heap_begin       # 将当前中断设置为首地址. 这使得alloc函数在首次运行时获取更多内存

    movl %ebp, %esp
    popl %ebp
    ret

##alloc##
# 目的: 获取一段内存, 查看是否存在自由内存块, 否则向linux申请
#
# 参数: 申请的内存大小
#
# 返回值: 分配的内存地址返回到%eax中, 如果没有可用内存, 返回0
#
# 变量:
#   %ecx: 保存请求的内存大小(第一个也是唯一的参数)
#   %eax: 检测当前内存区
#   %ebx: 当前中断位置
#   %edx: 当前内存区大小
#
# 我们检测每个以heap_begin开始的内存区, 查看每个的大小以及是否已经分配
# 如果某个内存区大小大于或等于所请求的大小, 且可用, 该函数获得此内存
# 如果无法找到足够大的内存区, 就像linux请求更多内存, 这种情况下, 此函数向前移动current_break

.globl alloc
.type alloc, @function
.equ ST_MEM_SIZE, 8     # 分配内存大小的栈位置
alloc:
    pushl %ebp
    movl %esp, %ebp

    movl ST_MEM_SIZE(%ebp), %ecx        # 保存要申请的内存大小

    movl heap_begin, %eax               # %eax保持当前搜索位置

    movl current_break, %ebx            # %ebx保存当前中断

alloc_loop_begin:
    cmpl %ebx, %eax                     # 两者相等, 代表需要申请更多内存
    je alloc_break

    movl HDR_SIZE_OFFSET(%eax), %edx            # 保存当前内存大小到%edx
    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)   # 检查当前内存块是否可用
    je alloc_next_location                      # 如果不可用, 则寻找下一块内存

    cmpl %edx, %ecx         # 比较当前内存块和申请大小. 如果够用, 则在当前位置分配
    jle alloc_here

alloc_next_location:
    addl $HEADER_SIZE, %eax # 跳过当前内存块
    addl %edx, %eax
    jmp alloc_loop_begin

alloc_here:
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)   # 标记当前内存块不可用
    addl $HEADER_SIZE, %eax                     # 跳过当前内存块的HEADER位置, 将可用内存放到%eax返回

    movl %ebp, %esp
    popl %ebp
    ret

alloc_break:
    addl $HEADER_SIZE, %ebx # ebx将作为新申请的中断地址, 因此在原中断地址基础上, 增加HEADER_SIZE + %ecx(申请的内存大小)
    addl %ecx, %ebx

    pushl %eax      # 保存当前寄存器数据
    pushl %ecx
    pushl %ebx

    movl $SYS_BRK, %eax     # 系统调用brk
    int $LINUX_SYSCALL

    cmpl $0, %eax           # 如果brk失败, 则错误处理
    je alloc_error

    popl %ebx               # 恢复寄存器数据
    popl %ecx
    popl %eax

    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)   # 给新分配的内存区写入HEADER数据(Available + Size)
    movl %ecx, HDR_SIZE_OFFSET(%eax)

    addl $HEADER_SIZE, %eax                     # 将要返回的%eax中的内存地址切换为实际可用地址(把HEADER部分跳过)

    movl %ebx, current_break                    # 保存新的中断

    movl %ebp, %esp                             # 完成内存分配, 函数返回
    popl %ebp
    ret

alloc_error:
    movl $0, %eax       # 出错返回0
    movl %ebp, %esp
    popl %ebp
    ret

##dealloc##
# 目的: 此函数的目的是使用内存区域后将之返回到内存池中
#
# 参数: 要释放的内存地址
#
# 返回: 无

.globl dealloc
.type dealloc, @function
# 要释放的内存区域栈位置
.equ ST_MEMORY_SEG, 4
dealloc:
    movl ST_MEMORY_SEG(%esp), %eax  # 直接取到第一个参数(要释放的内存地址)

    subl $HEADER_SIZE, %eax     # 将地址前移到其HEADER起始位置

    movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax) # 设置Available

    ret
