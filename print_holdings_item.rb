class PrintHoldingsItem
  def initialize(data)
    @data = data
  end
  def skip?
    return false if sdr_eo?
    skippable_location? || skippable_callnumber? || skippable_library? || invalid_barcode? || invalid_bib008?
  end
  def to_s
    [oclc,mms_id,holding_status,condition,gov_doc].join("\t")
  end
  def oclc
    #to do: what other forms to oclc numbers come in? Handle all. dedup.
    network_number = @data['OCLC Control Number (035a)'] || ""
    network_number.split("; ").filter_map do |x|
      x = x.to_i
      x if x > 0 && x < 9999999999
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
  private
  def skippable_location?
    reserves = ['CAR','OPEN','RESI','RESP','RESC','ERES']
    games = ["GAME"]
    micro = ["GLMR"]
    [reserves,games,micro].flatten.include?(@data["Location Code"]) || @data["Location Code"].match?(/^\d/)
  end
  def sdr_eo?
    @data["Library Code"] == 'SDR' && @data["Location Code"] == 'EO'
  end
  def skippable_library?
    ["SDR","ELEC"].include?(@data["Library Code"])
  end
  def valid_barcode?
    @data["Barcode"].nil? || 
      @data["Barcode"]&.match?(/^\d9015/) || 
      (@data["Barcode"]&.match?(/^[AB]/i) && not_in_process?)
  end
  def not_in_process?
    @data["Process Type"] != "In Process"
  end
  def invalid_barcode?
    !valid_barcode? 
  end
  def skippable_callnumber?
    @data["Permanent Call Number"].match?(/(film|micro|cdrom|cd-rom|classed)/i)
  end
  def invalid_bib008?
    @data["BIB 008 MARC"].nil? || ['a','b','c'].include?(@data["BIB 008 MARC"][23])
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
  def skip?
    return false if sdr_eo?
    skippable_library? || skippable_location? || skippable_callnumber?
  end
  def to_s
    [oclc,mms_id,issn,gov_doc].join("\t")
  end
  def issn
    @data["ISSN"]&.split("; ")&.map do |x|
      #Regex for issns from https://en.wikipedia.org/wiki/International_Standard_Serial_Number#Code_format
      valid_issn = x.match(/[0-9]{4}-[0-9]{3}[0-9xX]/)
      valid_issn.to_s unless valid_issn.nil?
    end&.compact&.join(",") || ""
  end
end
