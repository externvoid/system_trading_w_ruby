📅2025/07/20Sn
- 使い方
 data folderに時系列データ、銘柄ファイルを配置して、bin/simulate.rbを実行する。
 引数には設定ファイル名、銘柄コードを与える。result folderに結果が得られる。
 1. requirement
  a. historical data in the data folder
```csv:8604.txt
date,open,high,low,close,volume,adj
2010-01-04,686.0,693.0,681.0,686.0,14995200.0,686.0
2010-01-05,699.0,710.0,692.0,694.0,52393600.0,694.0
...
```
  b. codes list
```csv:tosho_list.txt
8001,東証1部,1000
8604,東証1部,1000
...

 2. ruby command 
```bash
$ruby bin/simulate.rb setting/estrangement.rb 8604
記録フォルダ result/estrangement/0.0.0 は存在しません。新しく作りますか？ y/n
```
 3. result/{settings}/0.0.0 in the result folder.
  a. result 
```csv:8604.csv
取引種別,入日付,入値,数量,初期ストップ,出日付,出値,損益(円),R倍数,%損益,期間
short,2010-08-11,514,1000,529,2010-08-13,496,18000,1.2,3.501945525291829,3
short,2010-10-15,450,1000,467,2010-10-18,422,28000,1.6470588235294117,6.222222222222222,2
short,2010-11-15,464,1000,480,2010-11-18,479,-15000,-0.9375,-3.2327586206896552,4
long,2011-02-01,506,1000,493,2011-02-03,516,10000,0.7692307692307693,1.9762845849802373,3
```

  b. settings
```rb:_setting.rb
Simulation.setting "estrangement", "0.0.0" do
  trading_system do
    entry  EstrangementEntry, span: 20, rate: 5
    exit   StopOutExit
    exit   EstrangementExit, span: 20, rate: 3
    stop   AverageTrueRangeStop, span: 20, ratio: 1
    filter MovingAverageDirectionFilter, span: 40
  end
...
```
