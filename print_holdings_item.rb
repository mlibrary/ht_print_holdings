require 'alma_rest_client'

class PrintHoldingsItem
  def initialize(data)
    @data = data
  end
  def oclc
    #to do: what other forms to oclc numbers come in?
    @data["Network Number"].split("; ").filter_map do|x|
      x.strip if x.start_with?("(OCoLC)") 
    end.join(",")
  end
end
