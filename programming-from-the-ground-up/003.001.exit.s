# target: exit and send a status code to kernel of linux 

# input: none

# output: return a status code. after run this program, run command "echo $?" get it

# variables:
#   %eax: save system call code
#   %ebx: save return code

.section .data
.section .text
.globl _start
_start:
    movl $1, %eax   # call the "exit" system call

    movl $8, %ebx   # return "0" to system as status code

    int $0x80       # wakeup kernel, run exit command
