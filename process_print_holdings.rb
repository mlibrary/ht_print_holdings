require 'csv'
require_relative 'print_holdings_item'
require 'logger'
require 'progress_bar'
require 'byebug'

class PrintHoldingsReport
  def initialize(csv:,logger: Logger.new(STDOUT))
    @logger = logger
    @csv_path = csv
  end
  def dump_report
    @logger.info "start #{name} report"
    main_process
    @logger.info "finished #{name} report"
  end
  def main_process
    puts "\n"
    line_count = %x{wc -l < "#{@csv_path}"}.to_i - 1
    report = file(report_path)
    report.puts header
    bar = ProgressBar.new(line_count) 
    CSV.foreach(@csv_path, headers: true, encoding: 'bom|utf-8' ) do |x|
      item = ph_item(x)
      report.puts item unless item.skip?
      bar.increment!
    end
  end
  def name
    self.class.name
  end
  def header
    #parent class
  end
  def ph_item(line)
    #parent class
  end
  def self.report_path
    "umich_#{name}_full_#{today}.tsv"
  end
  def report_path
    self.class.report_path
  end

  def self.today
    Date.today.strftime("%Y%m%d")
  end
  private
  def file(name)
    File.open(name, 'w')
  end

end
class SerialsReport < PrintHoldingsReport
  def self.name
    "ser"
  end
  def ph_item(row)
    PrintHoldingsSerials.new(row)
  end
  def main_process
    super
    unique_lines = File.readlines(report_path, chomp: true).uniq
    report = file("tmp_#{report_path}")
    report.puts unique_lines.join("\n")
    system("mv","tmp_#{report_path}",report_path)
    @logger.info ("deduplicated serial report")
  end
  def header
    ["oclc","local_id","issn","govdoc"].join("\t")
  end
end
class SPMReport < PrintHoldingsReport
  def self.name
    "spm"
  end
  def ph_item(row)
    PrintHoldingsItem.new(row)
  end
  def header
    ["oclc","local_id","status","condition","govdoc"].join("\t")
  end
end
class MPMReport < PrintHoldingsReport
  def self.name
    "mpm"
  end
  def ph_item(row)
    PrintHoldingsMultiPartMonograph.new(row)
  end
  def header
    ["oclc","local_id","status","condition","enum_chron","govdoc"].join("\t")
  end
end

#Note to self. Maybe check if there are updates to this process before I send
#another one.
SerialsReport.new(csv: 'PrintHoldingsSerials_20230825.csv').dump_report
#MPMReport.new(csv: 'PrintHoldingsMultiPartMonograph_20230825.csv').dump_report
#SPMReport.new(csv: 'PrintHoldingsSinglePartMonographs_20230825.csv').dump_report
