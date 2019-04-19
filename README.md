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
gem whichコマンドで、requireしたときに読み込まれるファイルを見つけることができる。
```sh
$ gem which active_record
/home/ueki/.rbenv/versions/2.6.1/lib/ruby/gems/2.6.0/gems/activerecord-5.2.2/lib/active_record.rb
```

### gemのソースを書き換える
上記の場所の.rbファイルをエディタで書き換えることで、gem自体に
デバッグ出力等を入れることができる。
作業が終わったら gem pristine <gem名>で、元の状態に戻せる。

### 現在のRubyの情報を知る
システムに複数のRubyをインストールしている時、gem envコマンドで
現在の環境を確認できる。
```sh
$ gem env
RubyGems Environment:
    - RUBYGEMS VERSION: 3.0.1
    - RUBY VERSION: 2.6.1 (2019-01-30 patchlevel 33) [x86_64-linux]
    - INSTALLATION DIRECTORY: /home/ueki/.rbenv/versions/2.6.1/lib/ruby/gems/2.6.0/
```
### byebug gemでプログラムの挙動を追う
```rb
require 'byebug'
...
def foo
    byebug
    ...
end
```
byebug起動後はirbのように使える他、以下を始めとしたたくさんのコマンドがある。
* n(next):次の行に進む
* s(step):nと似ているが、呼び出しているメソッドの中に入る
* c(continue):プログラムの実行を再開する

## マスター
### 呼ばれている全てのメソッドを出力する（TracePoint）
```rb
trace = TracePoint.new(:call, :c_call){|tp|
    cls = tp.defined_class
    m = if cls.singleton_class?
            "#{cls.to_s[/#<Class:(.+)>/,1]}.#{tp.method_id}"
        else
            "#{cls}##{tp.method_id}"
        end
    puts "#{m} (#{tp.path}:#{tp.lineno})"
}
trace.enable
...
trace.disable
```

### 呼ばれている全てのメソッドを出力する（インデント付き）
```rb
indent = 0
trace = TracePoint.new(:call, :return){|tp|
    if tp.event == :return
        print ' '*indent
        puts "<= #[tp.defined_class, tp.method_id].inspect}"
        indent -= 2 if indent > 0
    else
        print ' '*indent
        p [tp.defined_class, tp.method_id]
        indent += 2
    end
}
trace.enable
```

### メモリ上にあるオブジェクトの個数を数える
```rb
# 例：メモリ上にハッシュが何個残っているか数える。
GC.start
ObjectSpace.each_object(Hash).count
# Tips: require 'objspace'すると
# ObjectSpaceクラスのメソッドが増える。
```

### グローバル変数が書き換えられている箇所を調べる
```rb
# 例：$FOOが書き換えられた箇所を調べる。
trace_var(:$FOO) do |newval|
    p caller.first
end
```
### rubyのバグを疑う
CRubyのバグトラッカーを確認し、なければ再現コードを作って現象を報告する。

https://bugs.ruby-lang.org/projects/ruby-trunk/issues


