require 'alma_rest_client'
require 'webmock'
require 'json'
include WebMock::API

WebMock.enable!
require_relative './spec/support/alma_rest_client_stubs'
file = "spm.json"

stub_alma_get_request(url: "analytics/reports", query: { path: "fake_report", limit: 1000, col_names: true}, output: File.read("./spec/fixtures/#{file}"))

client = AlmaRestClient.client
output = []
client.get_report(path: "fake_report"){|x| output.push(x)}
puts JSON.pretty_generate(output.first)
