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
    response = client.get_report(path: report_path) do |x| 
      if first_line
        csv.puts x.keys.to_csv
        first_line = false
      end
      csv.puts x.values.to_csv
#      ph.puts ph_item(x)
    end
    @logger.info "response code: #{response.code}"
    @logger.error "response message: #{response&.message}" if response.code != 200
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
  def ph_item(row)
    PrintHoldingsSerials.new(row)
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
class SPMReport < PrintHoldingsReport
  def name
    "Single Part Monographs"
  end
  def ph_item(row)
    PrintHoldingsItem.new(row)
  end
  def report_path
    '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsSinglePartMonographs'
  end
  def csv_path
    'spm.csv'
  end
  def ph_path
    'spm_ph.tsv' 
  end
end
class MPMReport < PrintHoldingsReport
  def name
    "Multi Part Monographs"
  end
  def ph_item(row)
    PrintHoldingsMultiPartMonograph.new(row)
  end
  def report_path
    '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsMultiPartMonographs'
  end
  def csv_path
    'mpm.csv'
  end
  def ph_path
    'mpm_ph.tsv' 
  end
end

#SerialsReport.new.dump_report
#MPMReport.new.dump_report
SPMReport.new.dump_report
