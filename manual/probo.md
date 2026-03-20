<!-- title:probo readme -->
<!-- style:./default.css -->

<!-- config:embed-stylesheet -->
<!-- config:header-numbering 2 4 -->

<!-- filter:attach   = bash ./turnup-filters.sh attach    %in %out dat -->
<!-- filter:embed    = bash ./turnup-filters.sh embed_img %in %out dat -->
<!-- filter:gnuplot  = bash ./turnup-filters.sh gnuplot   %in %out svg -->
<!-- filter:kaavio   = bash ./turnup-filters.sh kaavio    %in %out svg -->
<!-- filter:plantuml = bash ./turnup-filters.sh plantuml  %in %out svg -->

<!-- define: DOLLER = $ -->
<!-- define: BLANK_PARAGRAPH = '　　' -->
<!-- define: TODO = '@((background:red; color:white;)(%1))' -->


<!-- stack:push pre style="font-size: 13;" -->
<!-- stack:push tr style="font-size: 14;" -->

# README - probo

　この文書は、 **probo** のマニュアル文書です。

<!-- anchor: toc-link-target -->
```raw
<h2>Table of contents</h2>
```
<!-- embed:toc-x 2 4 -->
<!-- toc-link: top 'A#toc-link-target' -->

${BLANK_PARAGRAPH}

## probo とは

　**probo** （ぷろーぼ）は、 `bash` シェル上で動作する簡素なテキスト主義のテスト
管理ツールです。基本的に `bash` と `gnuplot` があれば動作します
{{fn:これを書いている時点でざっと調べた限り、probo スクリプトが内部で使用しているコマンドは \
次の通りです。一般的な Linux 環境であれば、 `gnuplot` 以外は大体最初から使えるはず。  \
`cat cut date echo find gnuplot grep head ls mv perl pwd rm sort tail touch wc which` }}。
`gnuplot` がない場合はレポート生成機能で Burndown chart やサマリのグラフイメージの
出力ができませんが、生成されるレポートデータを使用して表計算ソフトでグラフを作成する
ことができます。

## ウォークスルー

　ここでは、一般的な使い方を説明します。

### インストールと設定

　probo を動かすのに必要なのは、パッケージに含まれる `probo` という名前の
シェルスクリプトひとつだけです。これをパスの通ったディレクトリに配置するか、
あるいは適当な場所に置いて `.bashrc` でエイリアス設定をしてください。ここ
ではより面倒の少ないエイリアスで済ませてしまいましょう
{{fn:エイリアスの場合、シェルスクリプトから利用できないなどの問題があります。完全にコマンドとして \
利用したい場合、パスの通ったディレクトリに置く方が良いでしょう。}}。

```
alias probo='/PATH/TO/probo'
```

${BLANK_PARAGRAPH}

　そしてこれは必須ではありませんが、probo からエディタを起動してファイルを
編集する機能を利用したい場合、 `EDITOR` 環境変数が設定されていることを確認
しておいてください。probo は `EDITOR` 環境変数が空の場合、 `vi` を使用します。
また、環境によってはエディタを非同期で実行したい
{{fn:作者は Emacs 上の shell mode から probo を使用し、ファイル編集も Emacs で行なうため非同期編集が \
好都合です。}}
かもしれません。そのような場合は `PROBO_EDIT_ASYNC` に 1 を設定しましょう。

```
export EDITOR="emacsclient"
export PROBO_EDIT_ASYNC=1
```

　これらは後述する設定ファイルではなく、 `.bashrc` などに記述することになります。

### --init でテストディレクトリを初期化

　probo でのテスト管理を始めるには、ディレクトリを作成してその中で `probo --init` を
実行します。

```
$ mkdir sample-test
$ cd sample-test
$ 
$ probo --init gitlab
$ 
```

　上記では、 `probo --init` のパラメータとして `gitlab` を指定しています。これは
初期化の方法を指定するもので、ここでは GitLab 向けの設定で初期化することを指示して
います。詳細は [--init オプションの説明](#--init オプション)を参照してください。

　`probo --init` の実行によって、実行ディレクトリ配下には以下のようなファイルが
生成されます。これらのファイルは必要に応じて修正することになりますが、今は気に
する必要はありません（たぶん後で説明します）。

```
$ ls -la
合計 24
drwxrwxr-x 2 user42 user42 4096  2月  2 17:29 .
drwxrwxr-x 6 user42 user42 4096  2月  2 17:29 ..
-rw-rw-r-- 1 user42 user42   69  2月  2 17:29 .case.template
-rw-rw-r-- 1 user42 user42  260  2月  2 17:29 .group.README.md.template
-rw-rw-r-- 1 user42 user42  348  2月  2 17:29 README.md
-rw-rw-r-- 1 user42 user42 1071  2月  2 17:29 probo.conf
$ 
```

### --addgrp でグループを作成

　続いて、グループを作成しましょう。probo ではテストケースを複数のグループに
わけて管理します
{{fn:グループ分けが不要な場合でも、現状ではグループをひとつは作成する必要があります。}}。
これには、以下のように `probo --addgrp` に続けてグループ名を並べます。

```
$ probo --addgrp  group1 group2
$ 
```

　これによって、以下のようにグループのためのディレクトリ作成されます。

```
$ ls -l
合計 20
-rw-rw-r-- 1 user42 user42  348  2月  2 17:29 README.md
drwxrwxr-x 2 user42 user42 4096  2月  2 17:37 group1
drwxrwxr-x 2 user42 user42 4096  2月  2 17:37 group2
-rw-rw-r-- 1 user42 user42 1071  2月  2 17:29 probo.conf
$ 
```

　`mkdir` でいいじゃんと思われるかもしれませんが、設定によってはグループ
ディレクトリの配下に必要なファイルが作成される場合があります。なので、グループ
は [--addgrp オプション](#--addgrp オプション)を使って作成するようにしましょう
{{fn:もちろん、わかった上で `mkdir` を使う分にはご自由に。}}。

### --addcase でテストケースを作成

　では、作成したグループにテストケースを追加しましょう。以下のように、
グループのディレクトリに移動し、 `probo --addcase` と言います。パラメータ
として追加するテストケースの数を指定します。

```
$ cd group1
$ probo --addcase 10
Adding test case 0001...
Adding test case 0002...
   :
   :
Adding test case 0009...
Adding test case 0010...
$ 
$ cd ../group2
$ probo --addcase 10
Adding test case 0001...
Adding test case 0002...
   :
   :
Adding test case 0009...
Adding test case 0010...
$ 
$ cd .. 
$
```

　これによって、指定した数のテストケースに対応するファイル（の雛型）が作成
されます。ここでは、 `group1` の最初のテストケースだけを見てみましょう。

```
$ cd group1
$ ls -l 0001*
-rw-rw-r-- 1 user42 user42 59  2月  2 17:40 0001.testcase.md
-rw-rw-r-- 1 user42 user42 26  2月  2 17:40 0001.testrun.md
$ 
```

　４桁の番号が **テスト ID** で、それに `.testcase.md` が続くのが
**ケースファイル** 、 `.testrun.md` が続くのが **ランファイル** です。
ケースファイルはテストの仕様を記述するもので、ランファイルはテストの
実施結果を記録するものです。

　一度にテストケースを作成するのでなく、複数回にわけて `probo --addcase` する
ことももちろん可能です。その場合、既存のテストケースの数などを考慮して新しく
テスト ID を付与してくれます。詳細は [--addcase オプション](#--addcase オプション)の
説明を参照してください。

### --edit で編集

　前のステップで作成したテストケースは（当然ですが）実質的に空っぽです。テストを
するためには、テストの仕様を記述しなければなりません。probo では、テストの仕様は
ケースファイルに記述します。これは markdown 形式のテキストファイルなので好きな
方法で編集することができますが、[最初のステップ](#インストールと設定)で `EDITOR` 
環境変数などを適切に設定していれば `probo --edit` コマンドで編集を開始することが
できます。以下では、 `group1` でテスト ID が 1 のテストケースの編集を開始して
います。

```
$ cd group1
$ probo --edit -c 1
```

　--edit でパラメータにテスト ID を指定した場合、デフォルトではランファイルの編集
を行ないます。ここでは `-c` オプションを指定することでケースファイルの編集を指示
しています。開いたファイルの内容は以下のようなものでした。これは
[初期化時](#--init でテストディレクトリを初期化)に生成された .case.template ファイル
を元に作成されています。

```
## group1/0001

* GROUP: group1
* ID: 0001
* DESCRIPTION: 

```

　このファイルの内容は （今は）あまり重要ではないので、テスト仕様を記述したことに
してファイルを閉じてしまいましょう（もちろん何か適当な編集をしてもかまいません）。

### --track でステータスを変更

　前のステップで `group1` の最初のテストの仕様を記述したので、テストケースとして
実行可能になりました。そこで、 `probo --track` コマンドでステータスを「テスト実施
可能」に変更しましょう。以下のように、ステータスとして `ready` を、テストID として 
1 を指定して実行します。

```
$ probo --track ready 1
1 file(s) updated.
$ 
```

　これでランファイルが変更され、このテストのステータスが `RUN` から `READY` に
なりました。この時点で、 `group1/0001.testrun.md` の内容は以下のようになります。
ステータスの変更がタイムスタンプと共に記録されているのがわかると思います。

```
## 2026-02-04-15-19.NEW

## 2026-02-04-15-59.READY

```

　今後、このテストを実際に実施する時には `RUN` に、テストが正常終了すれば `PASS` に、
といった具合で記録がつけられていくことになります。以下に、テストの基本的なステータス
遷移を示します。

```kaavio
(diagram (620 260)
; (grid)
  (with-theme (:uml-statemachine-default)
    (with-options (:font '(:width-spice 0.8))
      (uml-state-begin (xy+ canvas.tl 20 40) :id :start)
      (uml-state (x+ $1.cc  140) "new"    :id :new   :width 80)
      (uml-state (x+ $1.cc  170) "ready"  :id :ready :width 80)
      (uml-state (y+ $1.cc   90) "run"    :id :run   :width 80)
      (uml-state (y+ $1.cc   90) "pass"   :id :pass  :width 80)
      (uml-state (x+ $2.cc  170) "fail"   :id :fail  :width 80)
      (uml-state (y+ $1.cc  -90) "block"  :id :block :width 80)
      (uml-state-end   (x+ $3.cc 160)    :id :end)
      (uml-transition :start :new   :spec "新規作成")
      (uml-transition :new   :ready :spec "仕様記述")
      (uml-transition :ready :run   :spec '(:trigger "テスト開始" :offset (15 0)))
      (uml-transition :run   :pass  :spec '(:trigger "成功" :offset (10 0)))
      (uml-transition :run   :fail  :spec "失敗")
      (uml-transition :fail  :block :spec '(:trigger "調査・修正開始" :offset (80 0)))
      (uml-transition :block :ready :spec '(:trigger "作業完了"      :offset (5 -24)))
      (uml-transition :pass  :end))))
```
Figure. テストの基本的なステータス遷移

${BLANK_PARAGRAPH}

　この --track はテストのステータス変更で頻繁に使用することになるコマンドです。
ステータス変更と同時にエディタで開くなど指定も可能です。詳細は 
[--track オプションの説明](#--track オプション)を参照してください。

　続いて、テストのステータスを確認する方法を見ていきましょう。

### --ls で一覧表示

　テストのステータスを確認する方法のひとつとして `probo --ls` があります。
これは、現在のグループにあるすべてのテストの「現在のステータス」を一覧表示
するものです。

```
$ probo --ls
CASE	TIMESTAMP	STATUS	DESCRIPTION
0001	2026/02/04 15:59	READY	
0002	2026/02/04 15:19	NEW	
0003	2026/02/04 15:19	NEW	
0004	2026/02/04 15:19	NEW	
0005	2026/02/04 15:19	NEW	
0006	2026/02/04 15:19	NEW	
0007	2026/02/04 15:19	NEW	
0008	2026/02/04 15:19	NEW	
0009	2026/02/04 15:19	NEW	
0010	2026/02/04 15:19	NEW	
$ 
```

　グループの上位ディレクトリ（ --init を実行した場所）で `probo --ls` を実行した
場合、すべてのグループ配下のテストを一覧します。これはテスト全体の規模によっては
少し時間がかかるかもしれません。

```
$ cd ..
$ probo --ls
GROUP	CASE	TIMESTAMP	STATUS	DESCRIPTION
group1	0001	2026/02/04 15:59	READY	
group1	0002	2026/02/04 15:19	NEW	
         :
         :
group1	0009	2026/02/04 15:19	NEW	
group1	0010	2026/02/04 15:19	NEW	
group2	0001	2026/02/04 15:20	NEW	
group2	0002	2026/02/04 15:20	NEW	
         :
         :
group2	0009	2026/02/04 15:20	NEW	
group2	0010	2026/02/04 15:20	NEW	
$ 
```

### --log でステータス変更履歴を表示

　テストのステータスを参照する別の方法として `probo --log` があります。
これは、指定したテストのステータス変化の履歴を見るものです。以下では、 
`group1` のテスト ID 1 の履歴を参照しています。

```
$ cd group1
$ probo --log 1
0001	2026/02/04 15:19	NEW	
0001	2026/02/04 15:59	READY	
$
```

### --report でレポートを作成

　ここまでで、テスト環境を初期化し、グループやテストを追加し、ステータスを変更
できるようになりました。これでテストを進めていくことができると思います。

　テストの進み具合に関するレポートを生成するには、 `probo --report` を実行します。
これは --init を実行したのと同じディレクトリで行なってください。

```
$ probo --report
preparing status list...
preparing burndown data...
generating status data...
generating group status data...
generating summary data...
generating burndown image...
generating summary image...
generating group summary image...
$ 
```

　実行が完了すると、SVG 形式の画像ファイルが作成（更新）され、 `README.md` も
更新されます。各グループのディレクトリ配下も同様です。

```
$ ls -l
合計 72
-rw-rw-r-- 1 user42 user42  6270  2月  5 11:04 README.md
-rw-rw-r-- 1 user42 user42 26074  2月  5 11:04 burndown.svg
drwxrwxr-x 2 user42 user42  4096  2月  5 11:04 group1
drwxrwxr-x 2 user42 user42  4096  2月  5 11:04 group2
-rw-rw-r-- 1 user42 user42  1070  2月  5 11:04 probo.conf
-rw-rw-r-- 1 user42 user42 15471  2月  5 11:04 summary.svg
$ 
```


　生成されるレポート情報の種類は設定によって異なりますが、--init gitlab で
初期化した今回の場合は以下が生成されます。このテストディレクトリ全体を GitLab の
リポジトリにコミットすれば、GitLab 上でレポートを参照できます。

* Burndown チャート（burndown.svg）
* サマリ円グラフ（summary.svg）
* テスト別のステータス一覧（README.md 内に埋め込み）

${BLANK_PARAGRAPH}


　Burndown チャートの例を以下に示します。

```raw
<!-- include: sample-burndown.svg -->
```
Figure. Burndown チャートの例

${BLANK_PARAGRAPH}


　サマリ円グラフの例を以下に示します。


```raw
<!-- include: sample-summary.svg -->
```
Figure. サマリ円グラフの例


### --run でテストの自動実行

　最後に、--run オプションを紹介しておきます。これはケースファイル内に
テストスクリプトを埋め込んでおき、テストを自動実行できるようにするという
ものです。ケースファイルへの埋め込みは、以下のようにします。

~~~
<!-- probo test script : begin -->
```sh
# ここにテストを実行するスクリプトを記述する
```
<!-- probo test script : end -->
~~~

　このテストの ID が 42 だったとすると、 `probo --run 42` と言うことでテストを
自動実行することができます。具体的には、以下が実行されます。

* `probo --track RUN` を実行
* 上記のテストスクリプトを一時ファイルに抽出し、bash で実行
* 上記スクリプト実行の出力をランファイルに保存
* スクリプトの終了コードが 0 ならば `probo --track PASS` を実行
    * 非ゼロなら `PASS` でなく `FAIL` にします

　ただし、テストが実行されるのはステータスが READY の場合のみです。詳細は 
[--run オプションの説明](#--run オプション)を参照してください。

## 環境や目的別の初期化
### GitHub や GitLab を使う場合

　GitHub や GitLab を使う場合、markdown 形式でレポートを生成して描画は Web 
サービスに任せることになります。probo --init でパラメータとして `github` 
または `gitlab` を指定してください（現在、両者の区別はありません）。

　現在、以下のような構成になっています。

* レポート本体は `README.md` として生成（web サービス上で閲覧）
    * サマリ情報やステータス一覧は `README.md` に埋め込み
* Burndown chart およびステータス円グラフは gnuplot で SVG 形式ファイルを生成
* グループ別のレポートも生成
    * 各グループのディレクトリ配下にも `README.md` 上記とステータス円グラフを生成

### markdown を利用する場合

　GitHub などの Web サービスを利用しない場合、markdown でレポートを生成して
なんらかのソフトウェア環境で閲覧するか、あるいは HTML に変換してブラウザで
閲覧するのが良いでしょう。選択肢はたくさんありますが、そのすべてに最適な 
--init パラメータを用意することはできません。ひとまず probo --init markdown と
言うことで一般的な初期化を行なうことができます。

　現在、以下のような構成になっています。

* レポート本体は `report.md` として生成
    * サマリ情報やステータス一覧は `report.md` に埋め込み
* Burndown chart およびステータス円グラフは gnuplot で SVG 形式ファイルを生成
* グループ別のレポート生成はしない

#### turnup を使用する場合

　markdownから HTML 文書を生成する turnup を利用する場合、probo --init turnup と
言えば適切な初期化を行なうことができます。

　現在、以下のような構成になっています。

* レポート本体は `report.md` として生成
    * サマリ情報やステータス一覧は `report.md` に埋め込み
* Burndown chart およびステータス円グラフは gnuplot で SVG 形式ファイルを生成
    * markdown 形式から HTML を生成する際に SVG 画像を埋め込むように設定
* グループ別のレポート生成はしない

### gnuplot が使えない環境の場合

　gnuplot が使えない環境では、レポート機能が生成するいくつかのグラフ画像が利用
できません。この場合、probo --init でパラメータとして `raw` を指定してください。
この構成では gnuplot を利用せず、グラフ描画のためのデータをテキストファイルと
して生成します
{{fn:gnuplot が使える環境で `probo --init raw` と言った場合、gnuplot を使用する設定が出力されます。 \
gnuplot による画像生成が不要な場合、出力画像ファイル名を指定する設定を削除してください。}}。
また、ステータス一覧もテキストファイルとして生成されるため、これらのデータを表計算
ソフトに貼り付け、グラフや一覧を作成することになります。

　現在、以下のような構成になっています。

* 全テストを含むステータス一覧は `status.txt` として生成
* Burndown chart のためのデータファイルは `burndown.data.txt` として生成
* サマリ円グラフのためのデータは `summary.data.txt` として生成
* グループ別のレポート生成はしない

## 起動オプション
<!-- autolink: [$$](#起動オプション) -->

### --addcase オプション
<!-- autolink: [--addcase](#--addcase オプション) -->

　カレントディレクトリにテストを追加します。個数を指定することも可能です。

```
 probo --addcase [-q] [-t TIMESTAMP] [COUNT]
```

* `-q` で標準出力への出力を抑止します
* `-t` オプションでタイムスタンプを明示的に指定できます
    * `TIMESTAMP` には `date` が解釈できる文字列が指定できます
    * 省略した場合はシステムの現在日時が使用されます
* `COUNT` で作成するテストケースの個数を指定します
    * 省略した場合は 1 になります

　--addcase では、カレントディレクトリ内の既存テストから適切なテスト ID を
判断し、新規テストとしてケースファイルとランファイルを生成します。ケースファイル
はデフォルトで空ファイルですが、.case.template ファイルが存在する場合はそれを元
にファイルを作成します。ランファイルは `-t` で指定されたタイムスタンプ（または
現在日時）でステータス `NEW` が記録されます。

### --addgrp オプション
<!-- autolink: [--addgrp](#--addgrp オプション) -->

　指定した名前でグループを作成します。複数のグループを一度に指定できますが、
グループ名はディレクトリとして有効な名前である必要があります。

```
 probo --addgrp GROUP...
```

　--addgrp は、基本的にはディレクトリを作成するだけです。しかし、 `.group.*.template` に
マッチするファイルが存在すると、それをテンプレートとしてグループディレクトリ
の配下にファイルを作成します。ファイル名は `.group.` と `.template` に挟まれた
部分文字列が使用されます。また、ファイルの内容のうち、字列 `%GROUP%` はグループ
名に置き換えられます。

### --edit オプション
<!-- autolink: [--edit](#--edit オプション) -->

　カレントディレクトリにある指定テスト ID のランファイルまたはケースファイルを
エディタで開きます。エディタの指定は EDITOR 環境変数に従います（ PROBO_EDIT_ASYNC 
設定も参照してください ）。

```
 probo --edit [-c] TESTID
```

　`TESTID` が４桁以下の数字列だった場合、 `-c` の有無に従ってケースファイル名
またはランファイル名に補完されます。つまり、 `--edit 12` は `--edit ./0012.testrun.md` 
と同じであり、 `--edit -c 8` は `--edit ./0008.testcase.md` と同じです。

　なお、 `TESTID` が上記の条件を満たさない場合、ファイル名を直接指定したものとして
そのまま使用されます。つまり、ケースファイルでもランファイルでもないファイルの編集
に使用することも可能です。

### --help オプション
<!-- autolink: [--help](#--help オプション) -->

　標準出力に command usage を出力します。

```
 probo --help
```

### --init オプション
<!-- autolink: [--init](#--init オプション) -->

　カレントディレクトリを probo のテスト環境として初期化します。

```
 probo --init [-c CONF_FILE] REPORT_TYPE [START_DATE [END_DATE [CASE_PER_DAY]]]
```

　probo --init は、以下のことを行ないます。

* `REPORT_TYPE` の指定に応じた conf ファイルを作成します。 `REPORT_TYPE` には 
  `raw markdown gitlab github turnup` のいずれかを指定できます。詳細は
  「[](#環境や目的別の初期化)」を参照してください。
* 作成される conf ファイル名はデフォルトで `probo.conf` ですが、 `-c` オプション
  で変更できます。
* conf ファイルに記載される Burndown chart の開始日／終了日は `START_DATE` と 
  `END_DATE` で指定します。また、「１日あたりのテストケース消化想定数」を 
  `CASE_PER_DAY` で与えることができます。
    * `START_DATE` を省略した場合のデフォルト値は現在日付です
    * `END_DATE` を省略した場合のデフォルト値は開始日の１ヶ月後です
    * `CASE_PER_DAY` を省略した場合のデフォルト値は 10 です
* .case.template ファイルを生成します。これは probo --addcase でテスト
  ケースファイルを作成する時のテンプレートとなるファイルです。
* `REPORT_TYPE` が `gitlab` または `github` の場合に限り、 .group.README.md.template 
  ファイルを生成します。これは probo --addgrp でグループを作成する際、グループ
  ディレクトリ配下の README.md 作成のテンプレートとなるファイルです。

### --log オプション
<!-- autolink: [--log](#--log オプション) -->

　指定されたランファイルのステータス遷移の履歴を出力します。

```
 probo --log TESTID...
```

　`TESTID` にはテスト ID（４桁以下の数字列）を指定してください。--log はこれに対応
するランファイルを読み取ります。

### --ls オプション
<!-- autolink: [--ls](#--ls オプション) -->

　カレントディレクトリ配下の各テストの現在のステータスを一覧します。
カレントディレクトリにテストが存在しない場合、グループディレクトリ
群のひとつ上のディレクトリにいるものとして、配下グループ全体のテスト
のステータスを一覧します。

```
 probo --ls
```

### --report オプション
<!-- autolink: [--report](#--report オプション) -->

　conf ファイルの設定に従ってレポートを生成します。

```
 probo --report [-q] [-c CONF_FILE]
```

* `-q` で標準出力への出力を抑止します
* 参照する conf ファイル名はデフォルトで `probo.conf` ですが、 `-c` オプション
  で変更できます。


　生成されるレポートの内容は conf ファイルの記述によって変化します。詳細は
「[](#レポート生成)」を参照してください。

### --run オプション
<!-- autolink: [--run](#--run オプション) -->

　テストケースを実行します。

```
 probo --run [NUMBER...]
```

　特定のテストケースを実行したい場合、 `probo --run 4 5 8 9 10` のようにテスト 
ID を明示的にパラメータとして指定してください。この場合、カレントディレクトリに
ある指定されたテスト ID のテストケースを順に実行します。

　`probo --run` のようにパラメータ指定なしの場合、カレントディレクトリにある
すべてのテストケースが対象となります。カレントディレクトリにテストケースが存在
しない場合、配下ディレクトリがグループであるとみなしてすべてのグループを処理
します。

　いずれの場合でも、この機能で実行されるのは READY 状態のテストケースだけです。
また、この機能での実行には case file に実行スクリプトの埋め込みをしておく必要が
あります。以下に例を示します。

~~~
<!-- probo test script : begin -->
```sh
# test script here...
```
<!-- probo test script : end -->
~~~

　`# test script here...` の部分にテストを実行するスクリプトを記述してください。
このスクリプトは成功すれば exit 0 で、失敗の場合は exit 1 で終了するようにして
ください。 `probo` はその値で成否を判定して --track 相当の処理を実行して run file に
記録します。また、スクリプトが標準出力に書き出した内容も run file に転記されます。

### --track オプション
<!-- autolink: [--track](#--track オプション) -->

　指定されたテストのステータスを更新します。

```
 probo --track [-f] [-e] [-d DESCRIPTION] [-t TIMESTAMP] STATUS TESTID...
```

* `STATUS` には原則として `READY BLOCK PASS FAIL RUN REJECT` のいずれかを指定します
* `-f` オプションを使用すると、 `STATUS` パラメータのチェックをバイパスします
    * 任意のステータスを指定する場合に使用します
    * 任意のステータス名は、レポートでは `OTHER` として扱われます
* `-e` オプションを使用すると、ステータス記録後にランファイルをエディタで開きます
    * ただし、--track の対象が１ファイルだった場合に限ります
* `-t` オプションでタイムスタンプを明示的に指定できます
    * 省略した場合はシステム日時が使用されます
* `-d` オプションで `DESCRIPTION` を指定すると、補助的な情報を付加できます。
    * これは --ls や --log で参照できます

### --version オプション
<!-- autolink: [--version](#--version オプション) -->

　標準出力にバージョン情報を出力します。

```
 probo --version
```

${BLANK_PARAGRAPH}

## レポート生成
<!-- autolink: [$$](#レポート生成) -->

　レポートの生成は probo の中心的な機能です。ここでは、生成されるレポートの種類に
ついて説明します。

### Burndown チャート

　レポート生成機能では Burndown チャートを作成できます。グラフ出力の実際のサンプル
は [$@ 節](#--report でレポートを作成)を参照してください。グラフ画像の生成には 
gnuplot が必要になります。

　gnuplot が使用できない場合などに備えて、Burndown チャートのためのデータをテキスト
形式で出力することもできます。これは、表計算ソフトなどで別途グラフ化することを想定
しています。

　以下の設定変数が関与しています。

Table. Burndown チャート生成に関する設定項目 
| 設定変数                 | 説明                                         |
|:-------------------------|:---------------------------------------------|
| PROBO_BDIMG_FILENAME     | 生成画像のファイル名を指定します。           |
| PROBO_BDIMG_BGCLR        | 生成画像の背景色を指定します。               |
| PROBO_BDIMG_WIDTH        | 生成画像の幅を指定します。                   |
| PROBO_BDIMG_HEIGHT       | 生成画像の高さ指定します。                   |
| PROBO_BDIMG_CLR_GUIDE    | 基準線の色を指定します。                     |
| PROBO_BDIMG_CLR_PASSLINE | Pass 線の色を指定します。                    |
| PROBO_BDIMG_CLR_FAILBOX  | Fail 棒グラフの色を指定します。              |
| PROBO_BDDAT_FILENAME     | テキスト形式のデータファイル名を指定します。 |
| PROBO_BD_STARTDAY        | Burndown チャートの開始日を指定します。      |
| PROBO_BD_ENDDAY          | Burndown チャートの終了日を指定します。      |
| PROBO_BD_EXEC_PER_DAY    | 一日あたりのテスト消化予定数を指定します。   |
| PROBO_BD_SCHEDULE       | 日別の消化予定を細かく指定する際に使用します。|

### ステータス別サマリ

　レポート生成機能ではステータス別サマリを作成できます。これは、PASS, FAIL, READY 
などの各ステータスが全体に占める比率を円グラフで表したものです。グラフ出力の実際
のサンプルは [$@ 節](#--report でレポートを作成)を参照してください。グラフ画像の
生成には gnuplot が必要になります。

　gnuplot が使用できない場合などに備えて、ステータス別サマリのためのデータをテキスト
形式で出力することもできます。これは、表計算ソフトなどで別途グラフ化することを想定
しています。

　以下の設定変数が関与しています。

Table. ステータス別サマリ生成に関する設定項目 
| 設定変数                 | 説明                                         |
|:-------------------------|:---------------------------------------------|
| PROBO_SUMIMG_FILENAME    | 生成画像のファイル名を指定します。           |
| PROBO_SUMIMG_BGCLR       | 生成画像の背景色を指定します。               |
| PROBO_SUMIMG_WIDTH       | 生成画像の幅を指定します。                   |
| PROBO_SUMIMG_HEIGHT      | 生成画像の高さ指定します。                   |
| PROBO_SUMIMG_CLR_READY   | `READY` の色を指定します。                   |
| PROBO_SUMIMG_CLR_BLOCK   | `BLOCK` の色を指定します。                   |
| PROBO_SUMIMG_CLR_RUN     | `RUN` の色を指定します。                     |
| PROBO_SUMIMG_CLR_PASS    | `PASS` の色を指定します。                    |
| PROBO_SUMIMG_CLR_FAIL    | `FAIL` の色を指定します。                    |
| PROBO_SUMIMG_CLR_REJECT  | `REJECT` の色を指定します。                  |
| PROBO_SUMIMG_CLR_OTHER   | 上記以外のステータスの色を指定します。       |
| PROBO_SUMDAT_FILENAME    | ${{TODO}{まだ記述されていません}}            |
| PROBO_SUMDAT_INSERTION   | ${{TODO}{まだ記述されていません}}            |


<!-- PROBO_SUMDAT_FILENAME は PROBO_REPORT_TYPE で markdown table かどうか変わるよ -->

<!-- 6.1.19 PROBO_GRP_SUMIMG_FILENAME -->


### テスト一覧

　レポート生成機能ではテスト一覧を作成できます。これは、実質的に probo --ls に
よる出力と同等のものです。テスト一覧は「全体」と「グループ別」に分かれ、それぞれ
が「全件一覧」と「抜粋一覧」に分かれます。抜粋一覧とは、 `READY` と `PASS` を除い
た一覧を意味しています。

　グループ別のテスト一覧は、各グループのディレクトリ配下に出力されます。

　それぞれのファイルの出力において「ファイル作成（上書き）」か「差し込み」かを
選択できます。差し込みについては「[](#データの差し込みについて)」を参照してくだ
さい。

* ${{TODO}{まだ記述されていません。}}

　以下の設定変数が関与しています。

Table. テスト一覧生成に関する設定項目 
| 設定変数                     | 説明                                                           |
|:-----------------------------|:---------------------------------------------------------------|
| PROBO_FULLSTAT_FILENAME      | 全体の全件一覧を出力するファイル名を指定します。               |
| PROBO_FULLSTAT_INSERTION     | 全体の全件一覧出力を差し込みで行なうか否かを指定します。       |
| PROBO_PARTSTAT_FILENAME      | 全体の抜粋一覧を出力するファイル名を指定します。               |
| PROBO_PARTSTAT_INSERTION     | 全体の抜粋一覧出力を差し込みで行なうか否かを指定します。       |
| PROBO_GRP_FULLSTAT_FILENAME  | グループ別の全件一覧を出力するファイル名を指定します。         |
| PROBO_GRP_FULLSTAT_INSERTION | グループ別の全件一覧出力を差し込みで行なうか否かを指定します。 |
| PROBO_GRP_PARTSTAT_FILENAME  | グループ別の抜粋一覧を出力するファイル名を指定します。         |
| PROBO_GRP_PARTSTAT_INSERTION | グループ別の抜粋一覧出力を差し込みで行なうか否かを指定します。 |


<!-- PROBO(_GRP)?_.+STAT_FILENAME は PROBO_REPORT_TYPE で markdown table かどうか変わるよ -->


## 設定
### conf ファイルの設定項目
#### PROBO_BDDAT_FILENAME
<!-- autolink: [PROBO_BDDAT_FILENAME](#PROBO_BDDAT_FILENAME) -->

　Burndown chart のデータを生成する場合に、その出力ファイル名を以下の要領で指定
します。生成を行なわない場合は設定自体を省略するか、空文字列を設定してください。

```
PROBO_BDDAT_FILENAME="burndown.txt"
```

　これは通常、gnuplot が使用できない環境において、表計算ソフトなどを使用して 
Burndown chart を作成する場合に使用します。出力形式は PROBO_REPORT_TYPE の
値に関わらず、常にタブ区切りテキストになります。

#### PROBO_BDIMG_BGCLR
<!-- autolink: [PROBO_BDIMG_BGCLR](#PROBO_BDIMG_BGCLR) -->

　gnuplot を使用して Burndown chart を生成する場合に、背景色として使用する
色を指定します。省略した場合のデフォルトは `"white"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_BDIMG_BGCLR="#F0F8FF"
```

#### PROBO_BDIMG_CLR_FAILBOX
<!-- autolink: [PROBO_BDIMG_CLR_FAILBOX](#PROBO_BDIMG_CLR_FAILBOX) -->

　gnuplot を使用して Burndown chart を生成する場合に、Fail 棒グラフの描画に
使用する色を指定します。省略した場合のデフォルトは `"red"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_BDIMG_CLR_FAILBOX="brown"
```

#### PROBO_BDIMG_CLR_GUIDE
<!-- autolink: [PROBO_BDIMG_CLR_GUIDE](#PROBO_BDIMG_CLR_GUIDE) -->

　gnuplot を使用して Burndown chart を生成する場合に、基準線の描画に使用する
色を指定します。省略した場合のデフォルトは `"gray"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_BDIMG_CLR_GUIDE="light-gray"
```

#### PROBO_BDIMG_CLR_PASSLINE
<!-- autolink: [PROBO_BDIMG_CLR_PASSLINE](#PROBO_BDIMG_CLR_PASSLINE) -->

　gnuplot を使用して Burndown chart を生成する場合に、Pass 折線グラフの描画に
使用する色を指定します。省略した場合のデフォルトは `"blue"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_BDIMG_CLR_PASSLINE="navy"
```

#### PROBO_BDIMG_FILENAME
<!-- autolink: [PROBO_BDIMG_FILENAME](#PROBO_BDIMG_FILENAME) -->

　gnuplot を使用して Burndown chart を生成する場合に、その出力ファイル名を
以下の要領で指定します。生成を行なわない場合は設定自体を省略するか、空文字列
を設定してください。

```
PROBO_BDIMG_FILENAME="burndown.png"
```

　出力する画像形式はファイル名の拡張子から判断します。probo が認識するのは 
`gif jpeg jpg png svg` のいずれかです。

#### PROBO_BDIMG_HEIGHT
<!-- autolink: [PROBO_BDIMG_HEIGHT](#PROBO_BDIMG_HEIGHT) -->

　gnuplot を使用して butn-down chart を生成する場合に、生成画像の高さをピクセル
単位で指定します。省略した場合のデフォルト値は 400 です。

```
PROBO_BDIMG_HEIGHT=500
```

#### PROBO_BDIMG_WIDTH
<!-- autolink: [PROBO_BDIMG_WIDTH](#PROBO_BDIMG_WIDTH) -->

　gnuplot を使用して butn-down chart を生成する場合に、生成画像の幅をピクセル
単位で指定します。省略した場合のデフォルト値は 800 です。

```
PROBO_BDIMG_WIDTH=700
```

#### PROBO_BD_ENDDAY
<!-- autolink: [PROBO_BD_ENDDAY](#PROBO_BD_ENDDAY) -->

　Burndown chart を生成する場合に、X 軸の終了日付を `YYYY-MM-DD` 形式で指定します。

```
PROBO_BD_ENDDAY="2026-07-31"
```

　PROBO_BD_SCHEDULE が指定されている場合にはそちらが優先されるため、この設定値は
使用されません。PROBO_BD_SCHEDULE が省略された場合、この設定は必ず指定する必要が
あり、これを省略した場合はエラーになります。

#### PROBO_BD_EXEC_PER_DAY
<!-- autolink: [PROBO_BD_EXEC_PER_DAY](#PROBO_BD_EXEC_PER_DAY) -->

　Burndown chart を生成する場合に、一日あたりのテスト消化予定数を数値で指定します。

```
PROBO_BD_EXEC_PER_DAY=10
```

　PROBO_BD_SCHEDULE が指定されている場合にはそちらが優先されるため、この設定値は
使用されません。PROBO_BD_SCHEDULE が省略された場合、この設定は必ず指定する必要が
あり、これを省略した場合はエラーになります。

#### PROBO_BD_SCHEDULE
<!-- autolink: [PROBO_BD_SCHEDULE](#PROBO_BD_SCHEDULE) -->

　Burndown chart を生成する場合に、テスト開始日から終了日までの日毎のテスト消化
予定数を以下の要領で指定します。

```
PROBO_BD_SCHEDULE="
2026-07-01,5
2026-07-02,5
2026-07-03,5
2026-07-04,5
2026-07-05,5
2026-07-06,0
2026-07-07,0
    :
    :
"
```

　PROBO_BD_SCHEDULE の指定は Burndown chart の予定線を引くのに使用されますが、
記述が面倒な上にテストケース数の増減に手作業で対応する必要があります。休日などの
非稼働日にも細かく対応する必要がない場合、PROBO_BD_SCHEDULE の指定は省略して以下
の設定を代わりに使う方が楽かもしれません。

* PROBO_BD_STARTDAY
* PROBO_BD_ENDDAY
* PROBO_BD_EXEC_PER_DAY

#### PROBO_BD_STARTDAY
<!-- autolink: [PROBO_BD_STARTDAY](#PROBO_BD_STARTDAY) -->

　Burndown chart を生成する場合に、X 軸の開始日付を `YYYY-MM-DD` 形式で指定します。

```
PROBO_BD_STARTDAY="2026-07-01"
```

　PROBO_BD_SCHEDULE が指定されている場合にはそちらが優先されるため、この設定値は
使用されません。PROBO_BD_SCHEDULE が省略された場合、この設定は必ず指定する必要が
あり、これを省略した場合はエラーになります。

#### PROBO_FULLSTAT_FILENAME
<!-- autolink: [PROBO_FULLSTAT_FILENAME](#PROBO_FULLSTAT_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_FULLSTAT_INSERTION
<!-- autolink: [PROBO_FULLSTAT_INSERTION](#PROBO_FULLSTAT_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_GRP_FULLSTAT_FILENAME
<!-- autolink: [PROBO_GRP_FULLSTAT_FILENAME](#PROBO_GRP_FULLSTAT_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_GRP_FULLSTAT_INSERTION
<!-- autolink: [PROBO_GRP_FULLSTAT_INSERTION](#PROBO_GRP_FULLSTAT_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_GRP_PARTSTAT_FILENAME
<!-- autolink: [PROBO_GRP_PARTSTAT_FILENAME](#PROBO_GRP_PARTSTAT_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_GRP_PARTSTAT_INSERTION
<!-- autolink: [PROBO_GRP_PARTSTAT_INSERTION](#PROBO_GRP_PARTSTAT_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_GRP_SUMIMG_FILENAME
<!-- autolink: [PROBO_GRP_SUMIMG_FILENAME](#PROBO_GRP_SUMIMG_FILENAME) -->

　gnuplot を使用してグループ別の summary graph を生成する場合に、その出力
ファイル名を以下の要領で指定します。生成を行なわない場合は設定自体を省略
するか、空文字列を設定してください。

```
PROBO_GRU_SUMIMG_FILENAME="summary.png"
```

　グループ別の summary graph は、各グループのディレクトリ直下に作成されます。
出力する画像形式はファイル名の拡張子から判断します。probo が認識するのは 
`gif jpeg jpg png svg` のいずれかです。

#### PROBO_PARTSTAT_FILENAME
<!-- autolink: [PROBO_PARTSTAT_FILENAME](#PROBO_PARTSTAT_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_PARTSTAT_INSERTION
<!-- autolink: [PROBO_PARTSTAT_INSERTION](#PROBO_PARTSTAT_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_REPORT_TYPE
<!-- autolink: [PROBO_REPORT_TYPE](#PROBO_REPORT_TYPE) -->

　--report で生成するレポートの種類を以下の要領で指定します。

```
PROBO_REPORT_TYPE="markdown"
```

　現在サポートされているレポートの種類は以下になります。

* `markdown` : マークダウン形式での出力を行ないます
    * 多くの出力ファイルがマークダウンにおける表形式で出力されます
    * GitHub や GitLab などの環境で表示させたり、HTML に変換することを想定しています
* `raw` : テキスト形式での出力を行ないます。
    * 多くの出力ファイルがタブ区切りのテキスト形式で出力されます
    * 表計算ソフトに貼り付けたり、その他の方法で使用することを想定しています

#### PROBO_SUMDAT_FILENAME
<!-- autolink: [PROBO_SUMDAT_FILENAME](#PROBO_SUMDAT_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_SUMDAT_INSERTION
<!-- autolink: [PROBO_SUMDAT_INSERTION](#PROBO_SUMDAT_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_SUMIMG_BGCLR
<!-- autolink: [PROBO_SUMIMG_BGCLR](#PROBO_SUMIMG_BGCLR) -->

　gnuplot を使用して summary graph を生成する場合に、背景色として使用する
色を指定します。省略した場合のデフォルトは `"white"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_BGCLR="#F0F8FF"
```

#### PROBO_SUMIMG_CLR_BLOCK
<!-- autolink: [PROBO_SUMIMG_CLR_BLOCK](#PROBO_SUMIMG_CLR_BLOCK) -->

　gnuplot を使用して summary graph を生成する場合に、BLOCK 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"purple"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_BLOCK="#D2B48C"
```

#### PROBO_SUMIMG_CLR_FAIL
<!-- autolink: [PROBO_SUMIMG_CLR_FAIL](#PROBO_SUMIMG_CLR_FAIL) -->

　gnuplot を使用して summary graph を生成する場合に、FAIL 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"pink"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_FAIL="#FFC1C1"
```

#### PROBO_SUMIMG_CLR_OTHER
<!-- autolink: [PROBO_SUMIMG_CLR_OTHER](#PROBO_SUMIMG_CLR_OTHER) -->

　gnuplot を使用して summary graph を生成する場合に、OTHER 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"#98FB98"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_OTHER="#EEEED1"
```

#### PROBO_SUMIMG_CLR_PASS
<!-- autolink: [PROBO_SUMIMG_CLR_PASS](#PROBO_SUMIMG_CLR_PASS) -->

　gnuplot を使用して summary graph を生成する場合に、PASS 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"cyan"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_PASS="#B0E0E6"
```

#### PROBO_SUMIMG_CLR_READY
<!-- autolink: [PROBO_SUMIMG_CLR_READY](#PROBO_SUMIMG_CLR_READY) -->

　gnuplot を使用して summary graph を生成する場合に、READY 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"gray"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_READY="#F5F5F5"
```

#### PROBO_SUMIMG_CLR_REJECT
<!-- autolink: [PROBO_SUMIMG_CLR_REJECT](#PROBO_SUMIMG_CLR_REJECT) -->

　gnuplot を使用して summary graph を生成する場合に、REJECT 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"#CD9B9B"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_REJECT="#CD9B9B"
```

#### PROBO_SUMIMG_CLR_RUN
<!-- autolink: [PROBO_SUMIMG_CLR_RUN](#PROBO_SUMIMG_CLR_RUN) -->

　gnuplot を使用して summary graph を生成する場合に、RUN 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"blue"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
PROBO_SUMIMG_CLR_RUN="#B0C4DE"
```

#### PROBO_SUMIMG_FILENAME
<!-- autolink: [PROBO_SUMIMG_FILENAME](#PROBO_SUMIMG_FILENAME) -->

　gnuplot を使用して summary graph を生成する場合に、その出力ファイル名を
以下の要領で指定します。生成を行なわない場合は設定自体を省略するか、空文字列
を設定してください。

```
PROBO_SUMIMG_FILENAME="summary.png"
```

　出力する画像形式はファイル名の拡張子から判断します。probo が認識するのは 
`gif jpeg jpg png svg` のいずれかです。

#### PROBO_SUMIMG_HEIGHT
<!-- autolink: [PROBO_SUMIMG_HEIGHT](#PROBO_SUMIMG_HEIGHT) -->

　gnuplot を使用して summary graph を生成する場合に、生成画像の高さをピクセル
単位で指定します。省略した場合のデフォルト値は 400 です。

```
PROBO_SUMIMG_HEIGHT=500
```

#### PROBO_SUMIMG_WIDTH
<!-- autolink: [PROBO_SUMIMG_WIDTH](#PROBO_SUMIMG_WIDTH) -->

　gnuplot を使用して summary graph を生成する場合に、生成画像の幅をピクセル
単位で指定します。省略した場合のデフォルト値は 500 です。

```
PROBO_SUMIMG_WIDTH=700
```

${BLANK_PARAGRAPH}

### その他の設定変数
#### PROBO_EDIT_ASYNC
<!-- autolink: [PROBO_EDIT_ASYNC](#PROBO_EDIT_ASYNC) -->

　probo からエディタを起動する時に非同期実行とするか否かを制御する変数です。
--edit および --track -e から使用されます。これらは conf ファイルに依存しない
仕様のため、 `.bashrc` などで環境変数として設定することが想定されています。
非同期編集をする場合、以下のように 1 を設定してください。

```
export PROBO_EDIT_ASYNC=1
```

### .case.template ファイル
<!-- autolink: [.case.template](#.case.template ファイル) -->

* ${{TODO}{--addcase オプションで使用されるテストケースのテンプレートファイル}}
* ${{TODO}{以下のプレースホルダが展開される}}
    * `%CASEID%` : `0014` などのテストケース ID に展開される
    * `%GROUP%` : グループ名に展開される

### .group.README.md.template ファイル
<!-- autolink: [.group.README.md.template](#.group.README.md.template ファイル) -->

* ${{TODO}{--addgrp オプションで使用されるグループ README.md のテンプレートファイル}}
* ${{TODO}{以下のプレースホルダが展開される}}
    * `%GROUP%` : グループ名に展開される

## 細かい話

### TODO xxx

　probo では、ひとつ以上の **グループ** を作成してそれぞれの配下で複数の **テスト** 
を管理します。テストはグループ内で **テスト ID** で識別され、 **テストケース** と 
**テストラン** がそれぞれ別のファイルに保存されます。

* **テスト ID** : テストを識別するための４桁の数字列です。
* **テストケース** : テストの仕様や実施方法の記述です
* **テストラン** : テストの実施履歴や結果の記録です

　テスト ID は通常は番号として扱うため、 `0001` からの連番になります。

　テストケースとテストランは、テスト ID の後ろにそれぞれ `.testcase.md` および 
`.testrun.md` をつけた名前のマークダウン形式のテキストファイルで管理されます。
つまり、以下のような名前の２ファイルがセットになります。

* `0001.testcase.md`
* `0001.testrun.md`

　続いて **グループ** について。グループはテストを分類するためのもので、その名前で
ディレクトリを作成し、配下にケースファイルやランファイルを配置します。以下のように。

* `group1/`
    * `0001.testcase.md`
    * `0001.testrun.md`
    * `0002.testcase.md`
    * `0002.testrun.md`
    * 　:
    * 　:
* `group2/`
    * `0001.testcase.md`
    * `0001.testrun.md`
    * `0002.testcase.md`
    * `0002.testrun.md`
    * 　:
    * 　:

　グループには自由に名前をつけられますが、 `.git` のようにドットで始まる名前だけは
対象外になります。また、配下に `*.testcase.md` ファイルが存在しないディレクトリも
グループとはみなされません。

* `.case.template`
* `probo.conf`

　test-run ファイルは、テストに実施履歴を記録するためのファイルです。基本的
には markdown 形式で自由に記述可能ですが、ひとつだけルールがあります。以下
の形式の見出し行が、後述するレポート生成のスクリプトにより参照されます。

```
 ## YYYY-MM-DD-hh-mm.STATUS[.DESCRIPTION]
```

　ここで、上記における `YYYY-MM-DD-hh-mm` はタイムスタンプ（年月日時分）、
`STATUS` は基本的に `READY|BLOCK|RUN|FAIL|PASS|REJECT` のいずれか、 `[.DESCRIPTION]` は
任意で追加情報を記述できます。 `STATUS` の使い方は以下の通り。

* `READY  :` 実施可能
* `BLOCK  :` なんらかの理由で実施（再開）できない
* `RUN    :` 実施中
* `FAIL   :` 実施し、Fail
* `PASS   :` 実施し、Pass
* `REJECT :` 実施対象外に変更

${BLANK_PARAGRAPH}

　後述するレポートの生成では、スクリプトが各 test-run ファイルにおける上記
形式の行を全て抽出し、最後の行をそのテストケースの「現在のステータス」とし
て認識します。また、 `FAIL` に関しては古い情報もカウントの対象となります。
詳細はこのディレクトリにあるスクリプトファイルを参照してください。

### データの差し込みについて

* ${{TODO}{まだ記述されていません。}}

## 既知の問題点
<!-- autolink: [$$](#既知の問題点) -->


${BLANK_PARAGRAPH}

## 更新履歴

　更新履歴です。2026/??/?? 以降バージョン番号の付与を開始しました。

* __2026/01/12__
    * とりあえず動作する状態に。


${BLANK_PARAGRAPH}

## 図表一覧
<!-- embed:figure-list -->

　　

<!-- embed:table-list -->

　　

## 索引

<!-- embed:index-x -->


${BLANK_PARAGRAPH}

--------------------------------------------------------------------------------

<!-- embed:footnotes -->

