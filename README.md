# RubyDebugCheatSheet

#RubyKaigi2019 で配布された（らしい）チートシートのコード起こしです。
[RubyKaigi2019にスポンサーとして参加します \| ネットワーク応用通信研究所](https://www.netlab.jp/news/2019/04/11/rubykaigi2019/)
https://twitter.com/igaiga555/status/1119073495348965376

## 初級

### 巨大なオブジェクトを整形して表示する（Kernel#pp）

```rb
require 'pp'
...
pp obj
...
# Tips: Ruby2.5以降であればrequireなしでppが呼べる。
# stdout以外に出力したい場合は pretty_inspect を使う。
file.puts obj.pretty_inspect
```

### エラーの発生箇所を確認する
```sh
Traceback (most rescue call last):
    2: from app.rb:3:in '<main>'
    1: from /tmp/a.rb:11:in 'bar'
/tmp/b.rb:3:in 'baz': undefined method 'foo' for nil:NilClass (NoMethodError)
--------- -     ---   ---------------------------------------  -------------
このファイルの
        ３行目の
            このメソッドで
                        このようなエラーが発生した                  （エラーの種類）
```

### オブジェクトを表示する（Kernel#p）
```rb
# objの値を出力する。
p obj
# Tips: このように何を表示したのかわかるのでよりよい。
p obj: obj
```

### 好きなところでirbを起動する（Binding#irb）

```rb
def foo(x, y)
  # ここにきた瞬間にirbを起動する。xやyの値を確認したりできる。
  binding.irb
  ...
```

## 中級

### ログに記録する（Logger）
pメソッドと違い、時刻が自動で出る。logger.levelで出力レベルを
切り替えられる等のメリットがある。
```rb
require 'logger'
logger = Logger.new(STDOUT)
logger.debug("デバッグ情報")
logger.info("一般的な情報")
logger.warn("警告")
logger.error("エラー")
# Tips: 出力をカスタマイズすることもできる。
# logger.formatter = proc{|severity, time, progname, msg|
# "#{time}: #{msg}\n"
# }
```

### ログに例外を記録する（Logger）
backtraceも一緒に記録しておくとよい。
```rb
begin
  ...
rescue Exception => ex
  logger.error("#{ex.message} (#{ex.class})")
  ex.backtrace.each{|l| logger.error(l)}
  raise ex
  # Tips: ex.causeも記録するとよりよい。
end
```

### メソッドがどこから呼ばれているのか調べる（Kernel#caller）
```rb
def foo(x, y)
  p caller
  ...
end
```

### メソッドの定義箇所を調べる（Method#source_location）
```rb
# 例：obj.fooが定義されている箇所を調べたいとき
p obj.method(:foo).source_location
```

### オブジェクトの素性を調べる
```rb
# クラス
p obj.class
# 継承しているクラス・includeしているモジュール
p obj.class.ancestors
# 呼び出せるメソッド
p obj.public_methods
# 呼び出せるメソッド（継承したメソッドは除く）
p obj.public_method(false)
```


## 上級
### gemのソースを読む
### gemのソースを書き換える
### 現在のRubyの情報を知る
### byebug gemでプログラムの挙動を追う



## マスター
### 呼ばれている全てのメソッドを出力する（TracePoint）
### 呼ばれている全てのメソッドを出力する（インデント付き）
### メモリ上にあるオブジェクトの個数を数える

### グローバル変数が書き換えられている箇所を調べる
### rubyのバグを疑う


