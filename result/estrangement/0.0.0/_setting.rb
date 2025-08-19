Simulation.setting "estrangement", "0.0.0" do
  trading_system do
    entry  EstrangementEntry, span: 20, rate: 5
    exit   StopOutExit
    exit   EstrangementExit, span: 20, rate: 3
    stop   AverageTrueRangeStop, span: 20, ratio: 1
    filter MovingAverageDirectionFilter, span: 40
  end

  from "2000/01/04"
  to   "2012/12/28"

  data_loader TextToStock, data_dir: "data",
                           stock_list: "tosho_list.txt",
                           market_section: "東証1部"
  record_dir "result"
  record_every_stock true
end
