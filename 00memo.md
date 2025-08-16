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
```

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
- ❌️データソースの選択
  1. simulator.rb
  requireするモジュールでデータソースを選択
  text_to_stock, pan_database_to_stock, sqlite3_to_stock
  2. text_to_stock -> require stock_list_loader
  tosho_list.txtからStockListLoaderクラスが銘柄リストを作成する。
  更に銘柄.txtからStcokクラスのインスタンス(Historical Data)を生成する。
  3. sqlite3_to_stock -> require stock_list_via_sqlite3

- プログラムの構造

  1. エントリーポイントはbin/simulate.rb、だが実質的にはload ARGV[0]の部分

  2. bin/simulate.rbの次の部分が実質的なエントリーポイント。Simulationクラスのextension部分

     ```ruby
     class Simulation
     ...  
       def self.setting(system_name, version, &block)
         ...
         simulation = Simulation.new
         ...
         if ARGV[1]
           simulation.simulate_a_stock(ARGV[1].to_i)
         else
           simulation.simulate_all_stocks
         end
       end
     end
     ```

  3. サンプルの売買で条件を解説(load ARGV[0], settingestrangement.rb)

     ```ruby
     Simulation.setting "estrangement", "0.0.0" do
       trading_system do
         entry  EstrangementEntry, span: 20, rate: 5
         exit   StopOutExit
         exit   EstrangementExit, span: 20, rate: 3
         stop   AverageTrueRangeStop, span: 20, ratio: 1
         filter MovingAverageDirectionFilter, span: 40
       end
       ...
     end   
     ```

     - 前日の20日移動平均から5%乖離した際にその日(当日)の寄り付きでEntry
     - Exit条件は2つで1つ目はストップロス、もう一つは前日の20日移動平均から3%乖離に戻った時
     - ストップロスは買値から20日ATR平均の1倍マイナスに設定
     - Entryは40日移動平均が上向きの時に限る

  4. bin/simulate.rb解説
     `bin/simulate.rb`は、システムトレードのシミュレーションを実行するための中心的なスクリプトです。

     ### 概要

     このスクリプトは、コマンドライン引数で与えられた**設定ファイル**を読み込み、その内容に基づいてシミュレーションを実行します。個別銘柄のテストと、リストにある全銘柄のテストの両方に対応しています。

     ### 実行方法

     -   **全銘柄のシミュレーション:**
         ```bash
         ruby bin/simulate.rb <設定ファイル名>
         ```
     -   **1銘柄のみのシミュレーション:**
         ```bash
         ruby bin/simulate.rb <設定ファイル名> <銘柄コード>
         ```

     ### 主な処理の流れ

     1.  **ライブラリ読み込み:**
         -   シミュレーションに必要な基本的なクラス（`Simulation`, `TradingSystem`など）や、株価データをファイルから読み込むための`TextToStock`クラスなどを `require` します。

     2.  **クラスの拡張（DSLの定義）:**
         -   `Simulation`クラスと`TradingSystem`クラスに、設定ファイルで使うためのメソッド（`setting`, `trading_system`, `entry`, `exit`など）を定義しています。これにより、設定ファイルを簡潔で読みやすい形式（DSL: ドメイン固有言語）で記述できます。

     3.  **設定ファイルの読み込みと実行:**
         -   スクリプトの最後の行 `load ARGV[0]` がこのスクリプトの心臓部です。
         -   コマンドラインで指定された設定ファイル（例: `setting/estrangement.rb`）をRubyコードとして読み込み、実行します。

     4.  **シミュレーションの開始:**
         -   設定ファイルが実行されると、その中にある `Simulation.setting do ... end` ブロックが呼び出されます。
         -   この `setting` メソッドが、ブロック内の設定（売買ルール、対象期間、データソースなど）を読み取って `Simulation` オブジェクトを準備します。
         -   最後に、コマンドライン引数 `ARGV[1]` (銘柄コード) があれば個別銘柄のシミュレーションを、なければ全銘柄のシミュレーションを開始します。

     ### 設定ファイルで使われる主要メソッド

     -   `Simulation.setting(システム名, バージョン) do ... end`:
         シミュレーション全体の設定を定義します。
     -   `trading_system do ... end`:
         売買戦略（トレーディングシステム）を定義します。
     -   `entry`, `exit`, `stop`, `filter`:
         `trading_system`ブロック内で使用し、それぞれ仕掛け、手仕舞い、損切り、フィルターのルールとパラメータを指定します。
     -   `data_loader`:
         株価データの読み込み方法（どのクラスを使うか）と、データがある場所などを指定します。
     -   `from`, `to`:
         シミュレーションの対象期間を指定します。
     -   `record_dir`:
         結果を出力するフォルダを指定します。

     要約すると、このスクリプトは**設定ファイル駆動型**のシミュレータであり、本体のロジックを変更することなく、設定ファイル（`ARGV[0]`）を切り替えるだけで様々な売買戦略のテストができるように設計されています。

  5. `Simulation`インスタンスにおける`@trading_system`の役割解説

     ### Q1: `simulation.simulate_a_stock`メソッドが呼ばれた時、`@trading_system`はどのように利用されますか？
  
     `bin/simulate.rb`のコードだけを見ると `simulate_a_stock` メソッドの呼び出ししかありませんが、このメソッドの本体は `lib/simulation.rb` に定義されています。

     `lib/simulation.rb` の内容と合わせて、`@trading_system` がどのように利用されるかを解説します。

     #### `@trading_system` の役割
  
     `@trading_system` インスタンス変数は、設定ファイルで定義された**売買戦略のルール一式（仕掛け、手仕舞い、損切りなど）を保持するオブジェクト**です。
  
     `simulation.simulate_a_stock(code)` メソッドが呼ばれると、内部で `simulate(stock)` メソッドが実行され、この `@trading_system` が以下のように利用されます。
  
     1.  **売買戦略に銘柄を渡す**
         -   `simulate`メソッドの最初で `@trading_system.set_stock(stock)` が呼ばれます。
         -   これにより、これからシミュレーションする銘柄のデータ（日々の株価など）が売買戦略オブジェクトに渡されます。
     
     2.  **テクニカル指標を計算させる**
         -   次に `@trading_system.calculate_indicators` が呼ばれます。
         -   `@trading_system` は、自身が保持している各ルール（例: `EstrangementEntry`）が必要とするテクニカル指標（例: 移動平均乖離率）を、株価データを使って事前にすべて計算します。
     
     3.  **日々のループで売買判断を行う**
         -   その後、1日ずつループ処理が始まります。ループの各日で `@trading_system` は以下のような問い合わせを受けます。
         -   `@trading_system.check_entry(index)`: 「今日、仕掛けるべきか？」を判断します。フィルター条件を考慮し、仕掛けルールに合致すれば、取引情報を持つ `Trade` オブジェクトを返します。
         -   `@trading_system.set_stop(position, index)`: ポジションを保有している場合、「今日のストップロス価格はいくらにすべきか？」を計算・設定します。
         -   `@trading_system.check_exit(position, index)`: ポジションを保有している場合、「今日、手仕舞いすべきか？」を判断します。
     
     ---
  
     ### Q2: 「1日ずつのループ処理」とは`stock.prices.size.times do...end`のことですか?
  
     はい、その通りです。
  
     `stock.prices` は、シミュレーション対象となる銘柄の株価データ（日々の始値、高値、安値、終値など）が1日分ずつ配列に格納されたものです。
  
     したがって、`stock.prices.size.times do |index| ... end` は、株価データの最初の日から最後の日までを1日ずつ順番に処理するためのループということになります。ループ内の `index` が、特定の日付を指し示すために使われます。
  
     ---
  
     ### まとめ
  
     `simulation`インスタンス内の`@trading_system`は、**シミュレーションの頭脳**の役割を果たします。
  
     `simulate_a_stock`メソッドは、この頭脳（`@trading_system`）に銘柄データを与え、`stock.prices.size.times`ループを使って日々の株価の動きを再現しながら、「仕掛け」「手仕舞い」「損切り」の判断を都度問い合わせ、その結果を記録していく、という流れで処理を進めます。
  
  
  
  
  7. 

