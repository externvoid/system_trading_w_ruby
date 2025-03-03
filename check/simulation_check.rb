
require "./lib/simulation"
require "./lib/base"
require "./lib/text_to_stock"

text_to_stock =
  TextToStock.new(stock_list: "tosho_list.txt")
estrangement_system =
  TradingSystem.new(entries:  EstrangementEntry.new(span: 20, rate: 5),
                    exits:    [StopOutExit.new,
                               EstrangementExit.new(span: 20, rate: 3)],
                    stops:    AverageTrueRangeStop.new(span: 20),
                    filters:  MovingAverageDirectionFilter.new(span: 30))
recorder = Recorder.new
recorder.record_dir = "result/estrangement/test_simulation"

simulation =
  Simulation.new(trading_system: estrangement_system,
                 data_loader: text_to_stock,
                 recorder: recorder)

recorder.create_record_folder

simulation.simulate_a_stock(8604)
simulation.simulate_all_stocks
