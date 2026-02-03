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

# README - probo

　この文書は、 **probo** のマニュアル文書です。

## Table of contents

<!-- embed:toc-x 2 4 -->
<!-- toc-link: top 'Table of contents' -->

${BLANK_PARAGRAPH}

## probo とは

　**probo** （ぷろーぼ）は、bash シェル上で動作する簡素なテキスト主義のテスト
管理ツールです。基本的に bash と gnuplot があれば動作します
{{fn:これを書いている時点でざっと調べた限り、probo スクリプトが内部で使用しているコマンドは \
次の通りです。一般的な Linux 環境であれば、 `gnuplot` 以外は大体最初から使えるはず。  \
`cat cut date echo find gnuplot grep head ls mv perl pwd rm sort tail touch wc which` }}。


## ウォークスルー

### インストールと設定

　probo を動かすのに必要なのは、パッケージに含まれる `probo` という名前の
シェルスクリプトひとつだけです。これをパスの通ったディレクトリに配置するか、
あるいは適当な場所に置いて `.bashrc` でエイリアス設定をしてください。ここ
ではより面倒の少ないエイリアスで済ませてしまいましょう。

```
alias probo='/PATH/TO/probo'
```

　そしてこれは必須ではありませんが、probo からエディタを起動してファイルを
編集する場合、シェル変数 `PROBO_EDITOR` を設定しておくと良いでしょう。以下の
要領で指定してください（ `~1` という部分が編集ファイル名で置き換えられます）。

```
export PROBO_EDITOR="vim ~1"
```

### --init でテストディレクトリを初期化

```
$ mkdir sample-test
$ cd sample-test
$ probo --init gitlab
$ 
$ ls -la
合計 24
drwxrwxr-x 2 user42 user42 4096  2月  2 17:29 .
drwxrwxr-x 6 user42 user42 4096  2月  2 17:29 ..
-rw-rw-r-- 1 user42 user42   69  2月  2 17:29 .case.template
-rw-rw-r-- 1 user42 user42  260  2月  2 17:29 .group.readme.template
-rw-rw-r-- 1 user42 user42  348  2月  2 17:29 README.md
-rw-rw-r-- 1 user42 user42 1071  2月  2 17:29 probo.conf
$ 
```

### --addgrp でグループを作成

```
$ probo --addgrp  group1 group2
$ 
$ ls -l
合計 20
-rw-rw-r-- 1 user42 user42  348  2月  2 17:29 README.md
drwxrwxr-x 2 user42 user42 4096  2月  2 17:37 group1
drwxrwxr-x 2 user42 user42 4096  2月  2 17:37 group2
-rw-rw-r-- 1 user42 user42 1071  2月  2 17:29 probo.conf
$ 
```

### --addcase でテストケースを作成

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

```
$ cd group1
$ ls -l 0001*
-rw-rw-r-- 1 user42 user42 59  2月  2 17:40 0001.testcase.md
-rw-rw-r-- 1 user42 user42 26  2月  2 17:40 0001.testrun.md
$ 
```

　４桁の番号が **テスト ID** で、それに `.testcase.md` が続くファイルが
**ケースファイル** 、 `.testrun.md` が続くファイルが **ランファイル** です。
ケースファイルはテストの仕様を記述するもので、ランファイルはテストの実施結果
を記録するものです。

### --edit で編集
### --track でステータスを変更
### --ls で一覧表示
### --log でステータス変更履歴を表示
### --report でレポートを作成
### --run でテストの自動実行

## 構成

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

　後述するレポートの生成では、スクリプトが各 test-run ファイルにおける上記
形式の行を全て抽出し、最後の行をそのテストケースの「現在のステータス」とし
て認識します。また、 `FAIL` に関しては古い情報もカウントの対象となります。
詳細はこのディレクトリにあるスクリプトファイルを参照してください。

## 機能

<!-- ToDo : この章はまるごと 「起動オプション」と統合して良い気がする -->

### レポート生成
<!-- autolink: [$$](#レポート生成) -->

#### burndown-chart 生成

　以下の設定変数が関与しています。

| 設定変数             | 説明                            |
|:---------------------|:--------------------------------|
| PROBO_BDIMG_FILENAME     | 出力ファイル名を指定します。    |
| PROBO_BDIMG_WIDTH        | 生成画像の幅を指定します。      |
| PROBO_BDIMG_HEIGHT       | 生成画像の高さ指定します。      |
| PROBO_BDIMG_CLR_GUIDE    | 基準線の色を指定します。        |
| PROBO_BDIMG_CLR_PASSLINE | Pass 線の色を指定します。       |
| PROBO_BDIMG_CLR_FAILBOX  | Fail 棒グラフの色を指定します。 |


#### summary-graph 生成

　以下の設定変数が関与しています。

| 設定変数           | 説明 |
| PROBO_SUMIMG_FILENAME   | xxx  |
| PROBO_SUMIMG_WIDTH      | xxx  |
| PROBO_SUMIMG_HEIGHT     | xxx  |
| PROBO_SUMIMG_CLR_READY  | xxx  |
| PROBO_SUMIMG_CLR_BLOCK  | xxx  |
| PROBO_SUMIMG_CLR_RUN    | xxx  |
| PROBO_SUMIMG_CLR_PASS   | xxx  |
| PROBO_SUMIMG_CLR_FAIL   | xxx  |
| PROBO_SUMIMG_CLR_REJECT | xxx  |
| PROBO_SUMIMG_CLR_OTHER  | xxx  |

## 起動オプション
<!-- autolink: [$$](#起動オプション) -->

### --addcase オプション
<!-- autolink: [--addcase](#--addcase オプション) -->

　カレントディレクトリにテストケースを追加します。個数を指定することも可能です。

```
 probo --addcase [COUNT]
```

### --addgrp オプション
<!-- autolink: [--addgrp](#--addgrp オプション) -->

　指定した名前でグループを作成します。複数のグループを一度に指定できます。

```
 probo --addgrp GROUP...
```

　`.group.readme.template` ファイルが存在すると、その内容を使ってグループディレ
クトリの配下に `README.md` ファイルを作成します。このとき、 `.group.readme.template` 
内部の文字列 `%GROUP%` はグループ名に置き換えられます。

### --edit オプション
<!-- autolink: [--edit](#--edit オプション) -->

　カレントディレクトリにある指定した run file または case file をエディタで
開きます。

```
 probo --edit [-c] TEST
```

　`TEST` が４桁以下の数字列だった場合、 `-c` の有無に従って run file 名または 
case file 名に補完されます。つまり、 `--edit 12` は `--edit ./0012.testrun.md` と
同じであり、 `--edit -c 8` は `--edit ./0008.testcase.md` と同じです。

　エディタの指定は PROBO_EDITOR 変数に従います。

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
  `raw markdown gitlab github turnup` のいずれかを指定できます。
* conf ファイル名はデフォルトで `probo.conf` ですが、 `-c` オプションで変更
  できます。
* conf ファイルに記載される Burndown chart の開始日／終了日は `START_DATE` と 
  `END_DATE` で指定します。省略した場合、開始日は現在日付に、終了日は開始日の
  １ヶ月後になります。また、Burndown chart が想定する「１日あたりのテストケース
  消化想定数」を `CASE_PER_DAY` で与えることができます。デフォルト値は 10 です。
* `.case.template` ファイルを生成します。これは probo --addcase でテスト
  ケースファイルを作成する時のテンプレートとなるファイルです。
* `REPORT_TYPE` が `gitlab` または `github` の場合に限り、 `group.readme.template` 
  ファイルを生成します。これは probo --addgrp でグループを作成する際、
  配下の README.md 作成のテンプレートとなるファイルです。

### --log オプション
<!-- autolink: [--log](#--log オプション) -->

　指定された run file のログを出力します。

```
 probo --log RUNFILE...
```

* ${{TODO}{RUNFILE の説明を書く}}
* ${{TODO}{カレントディレクトリであれば、テスト ID を数値で指定することも可能}}

### --ls オプション
<!-- autolink: [--ls](#--ls オプション) -->

　カレントディレクトリの run file の現在のステータスを一覧します。
カレントディレクトリに run file が存在しない場合、グループディレクトリ
群のひとつ上のディレクトリにいるものとして、配下グループ全体の run file 
のステータスを一覧します。

```
 probo --ls
```

### --report オプション
<!-- autolink: [--report](#--report オプション) -->

　レポートを生成します。

```
 probo --report [-q] [-c CONF_FILE]
```

### --run オプション
<!-- autolink: [--run](#--run オプション) -->

　テストケースを実行します。

```
 probo --run [NUMBER...]
```

　特定のテストケースを実行したい場合、 `probo --run 4 5 8 9 10` のようにテスト 
ID を明示的にパラメータとして指定してください。この場合、カレントディレクトリに
ある指定されたテスト ID のテストケースを実行します。

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

　実行時点のタイムスタンプで、指定されたファイルにステータスを記録します。

```
 probo --track [-f] [-e] [-d DESCRIPTION] [-t TIMESTAMP] STATUS RUNFILE...
 STATUS := READY|BLOCK|PASS|FAIL|RUN|REJECT
```

* `-f` オプションを使用すると、 `STATUS` パラメータのチェックをバイパスする
* `-e` オプションを使用すると、ステータスを記録した後に該当ファイルをエディタで開く
  （ただし編集したのが１ファイルだった場合のみ）
* `-t` オプションでタイムスタンプを明示的に指定可能（省略した場合はシステム日時）

${BLANK_PARAGRAPH}

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
#### PROBO_EDITOR
<!-- autolink: [PROBO_EDITOR](#PROBO_EDITOR) -->

　probo からエディタを起動する時のコマンドを格納する変数です。--edit および 
--track -e から使用されます。これらは conf ファイルに依存しない仕様のため、 
`.bashrc` などで環境変数として設定することが想定されています。

　例を示します。エディタとして `nano` を使用する場合は以下のようになります。
`~1` という部分がファイルで置き換えられます。

```
export PROBO_EDITOR="nano ~1"
```

　Emacs 内部の shell-mode からシェルをブロックせずに使いたい場合は以下のよう
になるでしょう。

```
export PROBO_EDITOR="emacsclient ~1 &"
```

　この変数が設定されていない場合、probo はデフォルト値として `"vi ~1"` を使用します。

### .case.template ファイル

* ${{TODO}{--addcase オプションで使用されるテストケースのテンプレートファイル}}
* ${{TODO}{以下のプレースホルダが展開される}}
    * `%CASEID%` : `0014` などのテストケース ID に展開される
    * `%GROUP%` : グループ名に展開される

### .group.readme.template ファイル

* ${{TODO}{--addgrp オプションで使用されるグループ README.md のテンプレートファイル}}
* ${{TODO}{以下のプレースホルダが展開される}}
    * `%GROUP%` : グループ名に展開される

## 既知の問題点
<!-- autolink: [$$](#既知の問題点) -->


${BLANK_PARAGRAPH}

## 更新履歴

　更新履歴です。2026/??/?? 以降バージョン番号の付与を開始しました。

* __2026/01/12__
    * とりあえず動作する状態に。


${BLANK_PARAGRAPH}

## 索引

<!-- embed:index-x -->


${BLANK_PARAGRAPH}

--------------------------------------------------------------------------------

<!-- embed:footnotes -->

