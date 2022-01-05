require 'alma_rest_client'

class PrintHoldingsItem
  def initialize(data)
    @data = data
  end
  def oclc
    #to do: what other forms to oclc numbers come in? Handle all. dedup.
    @data["Network Number"].split("; ").filter_map do |x|
      prefixes = ["ocl7","ocm","ocn","on","(OCoLC)"]
      if x.start_with?(*prefixes) 
        #strip prefixes. return integer.
        prefixes.each do |prefix|
          x.gsub!(prefix,"")
        end
        x.to_i
      end
    end.uniq.join(",")
  end
  def mms_id
    @data["MMS Id"].strip
  end
  def gov_doc
    #do something with this?
    @data["BIB 008 MARC"]
  end
  # to do: Electronic Only??????
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
