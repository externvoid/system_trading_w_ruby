# すべての銘柄のシミュレーション
# 使い方: ruby bin/simulate.rb setting_file_name
# 1銘柄のシミュレーション
# すべての銘柄のシミュレーション
# 使い方: ruby bin/simulate.rb setting_file_name
# 1銘柄のシミュレーション
# 使い方:
# ruby bin/simulate.rb setting_file_name stock_code

require "./lib/base"
require "./lib/simulation"
require "./lib/text_to_stock"
# require "./lib/pan_database_to_stock"
require "fileutils"

class Simulation
  attr_accessor :system_name, :version
  attr_reader :recorder

  def self.setting(system_name, version, &block)
    simulation = Simulation.new
    simulation.system_name = system_name
    simulation.version = version
    simulation.instance_eval(&block)
    unless simulation.recorder
      simulation.record_dir("result")
    end
    if ARGV[1]
      simulation.simulate_a_stock(ARGV[1].to_i)
    else
      simulation.simulate_all_stocks
    end
  end

  def trading_system(&block)
    @trading_system = TradingSystem.new
    @trading_system.instance_eval(&block)
  end

  def from(date)
    @from = date
  end

  def to(date)
    @to = date
  end

  def data_loader(data_loader, params)
    @data_loader = data_loader.new(params)
  end

  def record_dir(record_dir)
    @recorder = Recorder.new([record_dir, @system_name, @version].join("/"))
    @recorder.create_record_folder
    @recorder.record_setting(ARGV[0])
  end

  def record_every_stock(true_or_false)
    @record_every_stock = if true_or_false == false
                            false
                          else
                            true
                          end
  end
end

class TradingSystem
  def entry(rule, params=nil)
    create_rule(@entries, rule, params)
  end

  def exit(rule, params=nil)
    create_rule(@exits, rule, params)
  end

  def stop(rule, params=nil)
    create_rule(@stops, rule, params)
  end

  def filter(rule, params=nil)
    create_rule(@filters, rule, params)
  end

  private
  def create_rule(rules, rule, params=nil)
    rules ||= []
    new_rule = if params
                 rule.new(params)
               else
                 rule.new
               end
    rules << new_rule
  end
end

load ARGV[0]
# 使い方:
# ruby bin/simulate.rb setting_file_name stock_code

require "./lib/base"
require "./lib/simulation"
require "./lib/text_to_stock"
# require "./lib/pan_database_to_stock"
require "fileutils"

class Simulation
  attr_accessor :system_name, :version
  attr_reader :recorder

  def self.setting(system_name, version, &block)
    simulation = Simulation.new
    simulation.system_name = system_name
    simulation.version = version
    simulation.instance_eval(&block)
    unless simulation.recorder
      simulation.record_dir("result")
    end
    if ARGV[1]
      simulation.simulate_a_stock(ARGV[1].to_i)
    else
      simulation.simulate_all_stocks
    end
  end

  def trading_system(&block)
    @trading_system = TradingSystem.new
    @trading_system.instance_eval(&block)
  end

  def from(date)
    @from = date
  end

  def to(date)
    @to = date
  end

  def data_loader(data_loader, params)
    @data_loader = data_loader.new(params)
  end

  def record_dir(record_dir)
    @recorder = Recorder.new([record_dir, @system_name, @version].join("/"))
    @recorder.create_record_folder
    @recorder.record_setting(ARGV[0])
  end

  def record_every_stock(true_or_false)
    @record_every_stock = if true_or_false == false
                            false
                          else
                            true
                          end
  end
end

class TradingSystem
  def entry(rule, params=nil)
    create_rule(@entries, rule, params)
  end

  def exit(rule, params=nil)
    create_rule(@exits, rule, params)
  end

  def stop(rule, params=nil)
    create_rule(@stops, rule, params)
  end

  def filter(rule, params=nil)
    create_rule(@filters, rule, params)
  end

  private
  def create_rule(rules, rule, params=nil)
    rules ||= []
    new_rule = if params
                 rule.new(params)
               else
                 rule.new
               end
    rules << new_rule
  end
end

load ARGV[0]
