Simulation.setting "breakout", "0.0.0" do
  trading_system do
    entry  BreakoutEntry, span: 10
    exit   MinHoldExit, min_hold_days: 1
    exit   StopOutExit
    exit   BreakoutExit, span: 5
    stop   AverageTrueRangeStop, span: 20, ratio: 2
    filter MovingAverageDirectionFilter, span: 30
  end

  data_loader TextToStock, data_dir: "data",
                           stock_list: "tosho_list.txt",
                           market_section: "東証1部"
  record_dir "result"
end
