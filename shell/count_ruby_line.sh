
# 统计 Ruby 代码的行数

find . -type f -iname "*.rb" -exec cat {} \; | grep -v '^$' | wc -l
