require 'alma_rest_client'
client = AlmaRestClient.client
path = '/shared/University of Michigan 01UMICH_INST/Reports/apps/print-holdings/PrintHoldingsMultiPartMonographs'
client.get_report(path: path){|x| puts x}
