require 'pp'

pp obj
# Tips: Ruby2.5以降であればrequireなしでppが呼べる。
# stdout以外に出力したい場合は pretty_inspect を使う。
file.puts obj.pretty_inspect
