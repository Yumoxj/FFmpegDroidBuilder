#!/bin/bash

#if [ "$#" -ne 1 ]; then
#    echo "Usage: $0 config_file"
#    exit 1
#fi

# 获取配置文件
#config_file=$1
config_file=ffbuild/config.mak

# 定义需要查找的变量
vars=("CPPFLAGS" "CFLAGS" "CXXFLAGS" "ASFLAGS" "LDFLAGS")

# 定义需打印的 cpu 特定参数
cpu_specific_prefixes=("-mfpu" "-march")

# 定义需要过滤的标志
filter_prefixes=("CPPFLAGS" "CFLAGS" "CXXFLAGS" "ASFLAGS" "LDFLAGS" "--sysroot" "-mfpu" "-march" "-Wl,-rpath-link")

print_flags() {
    # 将参数转换为数组
    local -a local_filter_prefixes="($(echo "$1"))"
	
    local local_should_print=$2
	
    local var_prefix=$3

    for var in "${vars[@]}"; do	
        flags=$(grep "^$var" "$config_file")

        # 分割参数
        IFS=' ' read -r -a flagarray <<< "$flags"

        # 过滤重复参数参数
        flagarray=($(printf "%s\n" "${flagarray[@]}" | sort -u))

        echo "$3_$var: {"

        for flag in "${flagarray[@]}"; do
            # 检查参数是否需要过滤
            if [ "$local_should_print" = true ] ; then
                should_print=false
            else
                should_print=true
            fi

            for prefix in "${local_filter_prefixes[@]}"; do
                if [[ "$flag" == $prefix* ]]; then
                    should_print=$local_should_print
                fi
            done

            # 如果不需要过滤，则打印
            if $should_print ; then
                echo "    \"$flag\","
            fi
        done

        echo "}"
    done
}

# 将数组转换为字符串并传递给函数
print_flags "${filter_prefixes[*]}" false common
echo -e "\n"
print_flags "${cpu_specific_prefixes[*]}" true cpu_specific