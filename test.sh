#!/bin/bash

# デフォルト値の設定
NAME="Unknown"
AGE="None"
VERBOSE=false

# オプション解析
# n, v は引数なし、a は引数が必要
while getopts "nva:" opt; do
  case $opt in
    n) NAME="User" ;;
    v) VERBOSE=true ;;
    a) AGE=$OPTARG ;; # 引数を取得
    *) echo "無効なオプションです" ;;
  esac
done

# 解析後、引数部分をシフト（必要に応じて）
shift $((OPTIND - 1))

echo "Name: $NAME, Age: $AGE, Verbose: $VERBOSE"
echo "残りの引数: $@"

