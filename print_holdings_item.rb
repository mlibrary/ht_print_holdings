class PrintHoldingsItem
  def initialize(data)
    @data = data
  end
  def skippable_locations
    reserves = ['CAR','OPEN','RESI','RESP','RESC','ERES']
    games = ["GAME"]
    micro = ["GLMR"]
    [reserves,games,micro].flatten
  end
  def skip?
    skippable_locations.include?(@data["Location Code"]) ||
      @data["Permanent Call Number"].match?("MICRO") ||
      !(@data["Barcode"].match?(/^\d9015/))
  end
  def to_s
    [oclc,mms_id,holding_status,condition,gov_doc].join("\t")
  end
  def oclc
    #to do: what other forms to oclc numbers come in? Handle all. dedup.
    network_number = @data["Network Number"] || ""
    network_number.split("; ").filter_map do |x|
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
    @data["MMS Id"]&.strip
  end
  def gov_doc
    #do something with this?
    bib08 = @data["BIB 008 MARC"]
    (bib08[17] == 'u' && bib08[28] == 'f') ? 1 : 0
  end
  def electronic_only?
    @data["Library Code"] == "SDR" && @data["Location Code"] == "EO"
  end
  def deleted?
    @data["Lifecycle"] == "Deleted"
  end
  # to do: Electronic Only??????
  
  def holding_status
    if electronic_only? || deleted?
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
class PrintHoldingsMultiPartMonograph < PrintHoldingsItem
  def to_s
    [oclc,mms_id,holding_status,condition,enum_chron,gov_doc].join("\t")
  end
  def enum_chron
    @data["Description"].strip
  end
end
class PrintHoldingsSerials < PrintHoldingsItem
  def to_s
    [oclc,mms_id,issn,gov_doc].join("\t")
  end
  def issn
    @data["ISSN"]&.strip
  end
end
