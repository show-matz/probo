<!-- title:probo readme -->
<!-- style:./default.css -->

<!-- config:embed-stylesheet -->
<!-- config:header-numbering 2 4 -->

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

　**probo** は、bash スクリプトで動作する軽量なテキスト主義のテスト管理ツールです。
基本的に bash と gnuplot があれば動作します
{{fn:これを書いている時点でざっと調べた限り、probo スクリプトが内部で使用しているコマンドは \
次の通りです。一般的な Linux 環境であれば、 `gnuplot` 以外は大体最初から使えるはず。  \
`cat cut date echo find gnuplot grep head ls mv perl pwd rm sort tail touch wc which` }}。


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



* `.case.template`
* `probo.conf`

　test-run ファイルは、テストに実施履歴を記録するためのファイルです。基本的
には markdown 形式で自由に記述可能ですが、ひとつだけルールがあります。以下
の形式の見出し行が、後述するレポート生成のスクリプトにより参照されます。

```
 ## YYYY-MM-DD-hh-mm.STATUS[.DESCRIPTION]
```

　ここで、上記における `YYYY-MM-DD-hh-mm` はタイムスタンプ（年月日時分）、
`STATUS` は基本的に `READY|BLOCK|RUN|FAIL|PASS` のいずれか、 `[.DESCRIPTION]` は
任意で追加情報を記述できます。 `STATUS` の使い方は以下の通り。

* `READY :` 実施可能
* `BLOCK :` なんらかの理由で実施（再開）できない
* `RUN   :` 実施中
* `FAIL  :` 実施し、Fail
* `PASS  :` 実施し、Pass

　後述するレポートの生成では、スクリプトが各 test-run ファイルにおける上記
形式の行を全て抽出し、最後の行をそのテストケースの「現在のステータス」とし
て認識します。また、 `FAIL` に関しては古い情報もカウントの対象となります。
詳細はこのディレクトリにあるスクリプトファイルを参照してください。

## 使い方


## 機能

### レポート生成
#### 

#### burndown-chart 生成

　以下の設定変数が関与しています。

| 設定変数             | 説明                            |
|:---------------------|:--------------------------------|
| BDCHART_FILENAME     | 出力ファイル名を指定します。    |
| BDCHART_WIDTH        | 生成画像の幅を指定します。      |
| BDCHART_HEIGHT       | 生成画像の高さ指定します。      |
| BDCHART_CLR_GUIDE    | 基準線の色を指定します。        |
| BDCHART_CLR_PASSLINE | Pass 線の色を指定します。       |
| BDCHART_CLR_FAILBOX  | Fail 棒グラフの色を指定します。 |


#### summary-graph 生成

　以下の設定変数が関与しています。

| 設定変数           | 説明 |
| SUMGRAPH_FILENAME  | xxx  |
| SUMGRAPH_WIDTH     | xxx  |
| SUMGRAPH_HEIGHT    | xxx  |
| SUMGRAPH_CLR_READY | xxx  |
| SUMGRAPH_CLR_BLOCK | xxx  |
| SUMGRAPH_CLR_RUN   | xxx  |
| SUMGRAPH_CLR_PASS  | xxx  |
| SUMGRAPH_CLR_FAIL  | xxx  |
| SUMGRAPH_CLR_OTHER | xxx  |

## 起動オプション
<!-- autolink: [$$](#起動オプション) -->

### --addcase オプション
<!-- autolink: [--addcase](#--addcase オプション) -->

　カレントディレクトリにテストケースを追加します。個数を指定することも可能です。

```
 probo --addcase [COUNT]
```

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

```
 probo --ls
```

### --report オプション
<!-- autolink: [--report](#--report オプション) -->

　指定された run file のログを出力します。

```
 probo --report [-c CONF_FILE]
```

### --track オプション
<!-- autolink: [--track](#--track オプション) -->

　実行時点のタイムスタンプで、指定されたファイルにステータスを記録します。

```
 probo --track [-d DESCRIPTION] STATUS RUNFILE...
 STATUS := READY|BLOCK|PASS|FAIL|RUN
```

${BLANK_PARAGRAPH}

## 設定
### conf ファイルの設定項目
#### BDCHART_CLR_FAILBOX
<!-- autolink: [BDCHART_CLR_FAILBOX](#BDCHART_CLR_FAILBOX) -->

　gnuplot を使用して burn-down chart を生成する場合に、Fail 棒グラフの描画に
使用する色を指定します。省略した場合のデフォルトは `"red"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
BDCHART_CLR_FAILBOX="brown"
```

#### BDCHART_CLR_GUIDE
<!-- autolink: [BDCHART_CLR_GUIDE](#BDCHART_CLR_GUIDE) -->

　gnuplot を使用して burn-down chart を生成する場合に、基準線の描画に使用する
色を指定します。省略した場合のデフォルトは `"gray"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
BDCHART_CLR_GUIDE="light-gray"
```

#### BDCHART_CLR_PASSLINE
<!-- autolink: [BDCHART_CLR_PASSLINE](#BDCHART_CLR_PASSLINE) -->

　gnuplot を使用して burn-down chart を生成する場合に、Pass 折線グラフの描画に
使用する色を指定します。省略した場合のデフォルトは `"blue"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
BDCHART_CLR_PASSLINE="navy"
```

#### BDCHART_FILENAME
<!-- autolink: [BDCHART_FILENAME](#BDCHART_FILENAME) -->

　gnuplot を使用して burn-down chart を生成する場合に、その出力ファイル名を
以下の要領で指定します。生成を行なわない場合は設定自体を省略するか、空文字列
を設定してください。

```
BDCHART_FILENAME="burndown.png"
```

　出力する画像形式はファイル名の拡張子から判断します。probo が認識するのは 
`gif jpeg jpg png svg` のいずれかです。

#### BDCHART_HEIGHT
<!-- autolink: [BDCHART_HEIGHT](#BDCHART_HEIGHT) -->

　gnuplot を使用して butn-down chart を生成する場合に、生成画像の高さをピクセル
単位で指定します。省略した場合のデフォルト値は 400 です。

```
BDCHART_HEIGHT=500
```

#### BDCHART_WIDTH
<!-- autolink: [BDCHART_WIDTH](#BDCHART_WIDTH) -->

　gnuplot を使用して butn-down chart を生成する場合に、生成画像の幅をピクセル
単位で指定します。省略した場合のデフォルト値は 800 です。

```
BDCHART_WIDTH=700
```

#### BDDATA_FILENAME
<!-- autolink: [BDDATA_FILENAME](#BDDATA_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_ENDDAY
<!-- autolink: [PROBO_ENDDAY](#PROBO_ENDDAY) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_EXEC_PER_DAY
<!-- autolink: [PROBO_EXEC_PER_DAY](#PROBO_EXEC_PER_DAY) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_GROUPS
<!-- autolink: [PROBO_GROUPS](#PROBO_GROUPS) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_SCHEDULE
<!-- autolink: [PROBO_SCHEDULE](#PROBO_SCHEDULE) -->

* ${{TODO}{まだ記述されていません。}}

#### PROBO_STARTDAY
<!-- autolink: [PROBO_STARTDAY](#PROBO_STARTDAY) -->

* ${{TODO}{まだ記述されていません。}}

#### REPORT_TARGET
<!-- autolink: [REPORT_TARGET](#REPORT_TARGET) -->

* ${{TODO}{まだ記述されていません。}}

#### STATUS_FULL_FILENAME
<!-- autolink: [STATUS_FULL_FILENAME](#STATUS_FULL_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### STATUS_FULL_INSERTION
<!-- autolink: [STATUS_FULL_INSERTION](#STATUS_FULL_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### STATUS_PICKUP_FILENAME
<!-- autolink: [STATUS_PICKUP_FILENAME](#STATUS_PICKUP_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### STATUS_PICKUP_INSERTION
<!-- autolink: [STATUS_PICKUP_INSERTION](#STATUS_PICKUP_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

#### SUMGRAPH_CLR_BLOCK
<!-- autolink: [SUMGRAPH_CLR_BLOCK](#SUMGRAPH_CLR_BLOCK) -->

　gnuplot を使用して summary graph を生成する場合に、BLOCK 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"purple"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
SUMGRAPH_CLR_BLOCK="#D2B48C"
```

#### SUMGRAPH_CLR_FAIL
<!-- autolink: [SUMGRAPH_CLR_FAIL](#SUMGRAPH_CLR_FAIL) -->

　gnuplot を使用して summary graph を生成する場合に、FAIL 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"pink"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
SUMGRAPH_CLR_FAIL="#FFC1C1"
```

#### SUMGRAPH_CLR_OTHER
<!-- autolink: [SUMGRAPH_CLR_OTHER](#SUMGRAPH_CLR_OTHER) -->

　gnuplot を使用して summary graph を生成する場合に、OTHER 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"#98FB98"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
SUMGRAPH_CLR_OTHER="#EEEED1"
```

#### SUMGRAPH_CLR_PASS
<!-- autolink: [SUMGRAPH_CLR_PASS](#SUMGRAPH_CLR_PASS) -->

　gnuplot を使用して summary graph を生成する場合に、PASS 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"cyan"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
SUMGRAPH_CLR_PASS="#B0E0E6"
```

#### SUMGRAPH_CLR_READY
<!-- autolink: [SUMGRAPH_CLR_READY](#SUMGRAPH_CLR_READY) -->

　gnuplot を使用して summary graph を生成する場合に、READY 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"gray"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
SUMGRAPH_CLR_READY="#F5F5F5"
```

#### SUMGRAPH_CLR_RUN
<!-- autolink: [SUMGRAPH_CLR_RUN](#SUMGRAPH_CLR_RUN) -->

　gnuplot を使用して summary graph を生成する場合に、RUN 部分の描画に使用
する色を指定します。省略した場合のデフォルトは `"blue"` です。

　この設定を変更する場合、以下の要領で色名を指定してください。ここで指定する
値は gnuplot が認識する色名または `#RRGGBB` 形式の色コードでなければなりませ
ん。詳細は gnuplot のマニュアルを参照してください。

```
SUMGRAPH_CLR_RUN="#B0C4DE"
```

#### SUMGRAPH_FILENAME
<!-- autolink: [SUMGRAPH_FILENAME](#SUMGRAPH_FILENAME) -->

　gnuplot を使用して summary graph を生成する場合に、その出力ファイル名を
以下の要領で指定します。生成を行なわない場合は設定自体を省略するか、空文字列
を設定してください。

```
SUMGRAPH_FILENAME="summary.png"
```

　出力する画像形式はファイル名の拡張子から判断します。probo が認識するのは 
`gif jpeg jpg png svg` のいずれかです。

#### SUMGRAPH_HEIGHT
<!-- autolink: [SUMGRAPH_HEIGHT](#SUMGRAPH_HEIGHT) -->

　gnuplot を使用して summary graph を生成する場合に、生成画像の高さをピクセル
単位で指定します。省略した場合のデフォルト値は 400 です。

```
SUMGRAPH_HEIGHT=500
```

#### SUMGRAPH_WIDTH
<!-- autolink: [SUMGRAPH_WIDTH](#SUMGRAPH_WIDTH) -->

　gnuplot を使用して summary graph を生成する場合に、生成画像の幅をピクセル
単位で指定します。省略した場合のデフォルト値は 500 です。

```
SUMGRAPH_WIDTH=700
```

#### SUMMARY_FILENAME
<!-- autolink: [SUMMARY_FILENAME](#SUMMARY_FILENAME) -->

* ${{TODO}{まだ記述されていません。}}

#### SUMMARY_INSERTION
<!-- autolink: [SUMMARY_INSERTION](#SUMMARY_INSERTION) -->

* ${{TODO}{まだ記述されていません。}}

${BLANK_PARAGRAPH}

### .case.template ファイル

* ${{TODO}{--addcase オプションで使用されるテストケースのテンプレートファイル}}
* ${{TODO}{以下のプレースホルダが展開される}}
    * `%CASEID%` : `0014` などのテストケース ID に展開される
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

