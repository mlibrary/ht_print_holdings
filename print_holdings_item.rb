require 'alma_rest_client'

class PrintHoldingsItem
  def initialize(data)
    @data = data
  end
  def to_s
    [oclc,mms_id,holding_status,condition,gov_doc].join("\t")
  end
  def oclc
    #to do: what other forms to oclc numbers come in? Handle all. dedup.
    @data["Network Number"].split("; ").filter_map do |x|
      prefixes = ["ocl7","ocm","ocn","on","(OCoLC)"]
      if x.start_with?(*prefixes) 
        #strip prefixes
        prefixes.each do |prefix|
          x.gsub!(prefix,"")
        end
        #return integer to get rid of 0 padding
        x.to_i
      end
    end.uniq.join(",")
  end
  def mms_id
    @data["MMS Id"].strip
  end
  def gov_doc
    #do something with this?
    bib08 = @data["BIB 008 MARC"]
    (bib08[17] == 'u' && bib08[28] == 'f') ? 1 : 0
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
    if ["Brittle","Damaged","Deteriorating","Fragile"].include?(@data["Physical Condition"]) 
      "BRT"
    else
      ""
    end
  end
end
