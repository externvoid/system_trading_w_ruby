Simulation.setting "estrangement", "2.0.0" do
  trading_system do
    entry  EstrangementEntry, span: 20, rate: 5
    exit   StopOutExit
    exit   EstrangementExit, span: 20, rate: 3
    stop   AverageTrueRangeStop, span: 20, ratio: 1
    filter MovingAverageDirectionFilter, span: 40
  end

  from "2025-01-01"
  to   "2025-08-31"

  data_loader TextToStock, data_dir: "data",
                           stock_list: "stock.db",
                           market_section: ["名証"]
# market_section: ["名証", "名証MN", "名証NXT", "名証PRM"]
  record_dir "result"
  record_every_stock true
end
