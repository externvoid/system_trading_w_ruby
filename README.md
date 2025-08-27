このプログラムは、坂本タクマ著『Rubyではじめるシステムトレード』(2014)に記載のコードのforkである。

1. 株価データを使って日本株式の模擬売買ができる
2. 株価のヒストリカルデータを取得するコード、銘柄リストを取得するコードは省かれている
3. 株価データを格納したSQLite3データベースファイルが実行するには必要である
4. 株価に関する2.のデータを取得するコードは別途準備できる方向けのプログラムである
 

[坂本タクマになる方法](https://sakamototakuma.blogspot.com/)

補足: dataフォルダ内の8604.csv, tosho_list.txtファイルはGitHub Repo管理者が作成したファイルである。坂本氏の著作にはファイル名の記載のみで中身への言及は無い。

株価リストファイルの仕様, pp. 170

ファイル名はtosho_list.txt
```csv
1301,東証PRM,100
```

株価データファイルの仕様, pp. 263

値は整数, 調整後終値は使用せず, ファイル名は1301.txt
日付は2010-01-04の形式でもOK
```csv
2010/01/04,185,187,184,187,86000,187
```

出版時点2014-06-02からの市場の変化(2025-03-03時点)

1. codeは非整数
2. 呼値は小数点以下、単位株は100株に統一
3. 東証1部, 2部は廃止
ref: [呼値の単位 | 内国株の売買制度 | 日本取引所グループ](https://www.jpx.co.jp/equities/trading/domestic/07.html)

[株式売買の注文、細かい金額でも新たに400銘柄を対象、投資家の利便性向上 ｜ 日本経済新聞 電子版特集](https://ps.nikkei.com/jpx2306/index.html)

次の環境で動かすためにやったこと
```bash
$sw_vers
ProductName:            macOS
ProductVersion:         15.3
BuildVersion:           24D60
$ruby -v
ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin22]
```
Work Around:
1. coding: Windows-31J, removed
2. win32ole @pan_database_to_stock.rb▶️require @simlate.rb, Comment out

動かした結果(result/8604.csv)
```bash
$ruby bin/simulate.rb setting/estrangement.rb 8604
```

```csv
取引種別,入日付,入値,数量,初期ストップ,出日付,出値,損益(円),R倍数,%損益,期間
short,2010-08-11,514,1000,529,2010-08-13,496,18000,1.2,3.501945525291829,3
short,2010-10-15,450,1000,467,2010-10-18,422,28000,1.6470588235294117,6.222222222222222,2
short,2010-11-15,464,1000,480,2010-11-18,479,-15000,-0.9375,-3.2327586206896552,4
long,2011-02-01,506,1000,493,2011-02-03,516,10000,0.7692307692307693,1.9762845849802373,3
```

動作確認はpp. 519, 18-3動作チェックに記載のコードを動かしpp. 523に記載の結果が得られる事の可否で行うことができる。
see result/estrangement/test_simulation/
```bash
$ ruby check/trading_system_check.rb
```
動作チェックコードの売買ルール, pp. 474とコードの記載
1. 20日移動平均からの乖離率が5%を超えると買い
2. 買い持ちの状態で20日移動平均からの乖離率が3%以内に戻るとポジション解消
3. 20日単純ATRに倍率1を掛けてストップロスとする
4. 30日移動平均が上向きの時のみ買いに入る

ATRについて
1. Rangeは高安の幅
2. True Rangeは前日終値を高安に混じえて算出するRange
3. Average True RangeはTrue Rangeの移動平均
e.g.
前前日の終値500, 前日高安が520, 510ならTRは20(520 - 500)
ATRを使ったストップロスとは当日480を下回ったら乖離率の如何によらずポジション解消

SQLite3対応版作成に先立ち気付いた事
1. def market(index), text_to_stock.rb, シンボルを返す必要は無い
2. to_i -> to_f, text_to_stock.rb
3. 売買ルール(e.g. estrangement.rb)にデータソース(Text or Pan)を記載
4. Simulationクラスはlib/simulation.rb, bin/simulation.rbの2箇所で定義されてる
