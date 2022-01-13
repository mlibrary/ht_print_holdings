require 'csv'
require_relative 'print_holdings_item'
require 'logger'
require 'byebug'

class PrintHoldingsReport
  def initialize(csv:,logger: Logger.new(STDOUT))
    @logger = logger
    @csv_path = csv
  end
  def dump_report
    @logger.info "start #{name} report"
    report = file(report_path)
    counter = 0
    CSV.foreach(@csv_path, headers: true, encoding: 'bom|utf-8' ) do |x|
      item = ph_item(x)
      report.puts item unless item.skip?
      counter = counter + 1
      @logger.info "processed #{counter} items" if counter % 1000 == 0
    end
    @logger.info "finished #{name} report"
  end
  def name
    #parent
  end
  def ph_item(line)
    #parent class
  end
  def report_path 
    #parent class
  end
  def csv_path
    #parent class
  end
  def report_path
    "umich_#{today}_#{name}.txt"
  end

  private
  def file(name)
    File.open(name, 'w')
  end
  def today
    Date.today.strftime("%Y%m%d")
  end
end
class SerialsReport < PrintHoldingsReport
  def ph_item(row)
    PrintHoldingsSerials.new(row)
  end
  def name
    "serial"
  end
end
class SPMReport < PrintHoldingsReport
  def ph_item(row)
    PrintHoldingsItem.new(row)
  end
  def name
    "mono_single"
  end
end
class MPMReport < PrintHoldingsReport
  def ph_item(row)
    PrintHoldingsMultiPartMonograph.new(row)
  end
  def name
    "mono_multi"
  end
end

#SerialsReport.new.dump_report
#MPMReport.new.dump_report
SPMReport.new(csv: 'spm_full.csv').dump_report
