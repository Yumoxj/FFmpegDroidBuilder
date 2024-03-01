#!/bin/bash

# 打印帮助提示
if [ "$#" -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 dir1 [dir2 ...]"
    echo "Example: $0 libavutil libavutil/aarch64"
    exit 0
fi

# 定义查找源文件的函数
findSrc() {
    local dir=$1
    local f=`ls $dir/*.o 2>/dev/null`

	echo "$dir: {"
    
	for d in $f
    do
        local s=${d//.o/.c}
        if [ -f "$s" ]; then
            echo "    \"${d//.o/.c}\","
        else
            echo "    \"${d//.o/.S}\","
        fi
    done
	
	echo "}"
}

# 遍历每个参数并查找源文件
for dir in "$@"; do
    echo "Source files in $dir:"
    findSrc $dir
done
