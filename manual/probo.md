

### --track オプション

　実行時点のタイムスタンプで、指定されたファイルにステータスを記録します。

```
 probo --track [-d DESCRIPTION] STATUS RUNFILE...
 STATUS := READY|BLOCK|PASS|FAIL|RUN
```

### --log オプション

　指定された run file のログを出力します。

```
 probo --log RUNFILE...
```

### --ls オプション

　カレントディレクトリの run file の現在のステータスを一覧します。

```
 probo --ls
```

### --report オプション

　指定された run file のログを出力します。

```
 probo --report [-c CONF_FILE]
```
