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
  def mms_id
    @data["MMS Id"].strip
  end
  def gov_doc
    #do something with this?
    @data["BIB 008 MARC"]
  end
  def holding_status
    if @data["Lifecycle"] == "Deleted"
      "WD"
    elsif ["Missing", "Lost", "Lost and paid", "Lost Resource Sharing Item"].include?(@data["Process Type"]&.strip)
      "LM"
    else
      "CH"
    end
    #CH, WD, LM 
  end
  def condition
    nil
  end
end
