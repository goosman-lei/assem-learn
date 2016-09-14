#!/bin/bash
__DIR__=$( cd `dirname ${BASH_SOURCE[0]}` && pwd )
ROOT_PATH=$__DIR__/..
SRC_PATH=$ROOT_PATH/src/006.001.record-read-and-write
OUTPUT_PATH=$ROOT_PATH/output
INCLUDE_DIR=$ROOT_PATH/include
LIB_DIR=$ROOT_PATH/lib

[ -d $OUTPUT_PATH ] || mkdir -p $OUTPUT_PATH

OUTPUT_EXEC=$OUTPUT_PATH/a.out

# 汇编每个源文件
as --32 --gstabs+ -I "$SRC_PATH" -I "$INCLUDE_DIR" "$SRC_PATH/linux.s" -o "$OUTPUT_PATH/linux.o"
as --32 --gstabs+ -I "$SRC_PATH" -I "$INCLUDE_DIR" "$SRC_PATH/record-def.s" -o "$OUTPUT_PATH/record-def.o"
as --32 --gstabs+ -I "$SRC_PATH" -I "$INCLUDE_DIR" "$SRC_PATH/record-funcs.s" -o "$OUTPUT_PATH/record-funcs.o"
as --32 --gstabs+ -I "$SRC_PATH" -I "$INCLUDE_DIR" "$SRC_PATH/read-records.s" -o "$OUTPUT_PATH/read-records.o"
as --32 --gstabs+ -I "$SRC_PATH" -I "$INCLUDE_DIR" "$SRC_PATH/write-records.s" -o "$OUTPUT_PATH/write-records.o"
as --32 --gstabs+ -I "$SRC_PATH" -I "$INCLUDE_DIR" "$SRC_PATH/modify-record.s" -o "$OUTPUT_PATH/modify-record.o"

# 编译基础函数及记录定义为共享库
ld -m elf_i386 -shared "$OUTPUT_PATH/linux.o" "$OUTPUT_PATH/record-def.o" "$OUTPUT_PATH/record-funcs.o" -o "$LIB_DIR/librecord.so"

# 链接共享库和可执行程序入口
ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -L/lib -L $LIB_DIR -lc -lrecord "$OUTPUT_PATH/read-records.o" -o "$OUTPUT_PATH/record-read"
ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -L/lib -L $LIB_DIR -lc -lrecord "$OUTPUT_PATH/write-records.o" -o "$OUTPUT_PATH/record-write"
ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -L/lib -L $LIB_DIR -lc -lrecord "$OUTPUT_PATH/modify-record.o" -o "$OUTPUT_PATH/record-modify"