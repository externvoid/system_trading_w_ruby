# `Simulation`インスタンスにおける`@trading_system`の役割解説

このドキュメントは、`Simulation`インスタンス内の`@trading_system`インスタンス変数が、シミュレーション実行時にどのように利用されるかについての質疑応答をまとめたものです。

---

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
