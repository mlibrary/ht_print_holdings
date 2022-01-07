require 'alma_rest_client'
require_relative 'print_holdings_item'
require 'csv'
require 'logger'
require 'byebug'

class PrintHoldingsReport
  def initialize(logger: Logger.new(STDOUT))
    @logger = logger
  end
  def dump_report(client=AlmaRestClient.client)
    @logger.info "start #{name} report"
    csv = file(csv_path)
    ph = file(ph_path)
    first_line = true
    client.get_report(path: report_path) do |x| 
      if first_line
        csv.puts x.keys.to_csv
        first_line = false
      end
      csv.puts x.values.to_csv
      ph.puts ph_item(x)
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
  def ph_path
    #parent class
  end
  private
  def file(name)
    File.open(name, 'a')
  end
end
class SerialsReport < PrintHoldingsReport
  def name
    "serials"
  end
  def ph_item(line)
    PrintHoldingsSerials.new(line)
  end
  def report_path
    '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsSerials'
  end
  def csv_path
    'serials.csv'
  end
  def ph_path
    'serials_ph.tsv' 
  end
end

SerialsReport.new.dump_report
#def dump_report(report_path:, csv:, ph:, kind:,client: AlmaRestClient.client, logger: Logger.new(STDOUT) )
  #first_line = true
  #client.get_report(path: report_path) do |x| 
    #if first_line
      #csv.puts x.keys.to_csv
      #flag = false
    #end
    #csv.puts x.values.to_csv
    #case kind
    #when :spm
    #when :mpm
    #when :serials
    #end
  #end
  #logger.info("done")
#end
#def file(name)
  #File.open(name, 'a')
#end
#spm = '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsSinglePartMonographs'
#mpm = '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsMultiPartMonographs'
#serials = '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsSerials'

