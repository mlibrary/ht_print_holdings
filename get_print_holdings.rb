require 'alma_rest_client'
require_relative 'print_holdings_item'
client = AlmaRestClient.client
path = '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsSinglePartMonographs'
client.get_report(path: path) do |x| 
  puts PrintHoldingsItem.new(x).to_s
end
