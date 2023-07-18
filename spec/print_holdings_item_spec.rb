require "spec_helper"
require "csv"
describe PrintHoldingsItem do
  before(:each) do
    @spm_item = CSV.read('spec/fixtures/spm_item.csv', headers: true, encoding: 'bom|utf-8').first 
  end
  subject do
    described_class.new(@spm_item)
  end
  context "to_s" do
    it "returns the string in the correct form" do
      expect(subject.to_s).to eq("26881499\t990026435400106381\tCH\t\t0")
    end
  end
  context "#skip?" do
    it "is false for non-skippable item" do
      expect(subject.skip?).to eq(false)
    end
    it "is true for empty BIB 008" do
      @spm_item["BIB 008 MARC"] = nil
      expect(subject.skip?).to eq(true)
    end
    context "byte 23 of Bib 008" do
      it "is true when it is 'a'" do
        @spm_item["BIB 008 MARC"][23] = 'a'
        expect(subject.skip?).to eq(true)
      end
      it "is true when it is 'b'" do
        @spm_item["BIB 008 MARC"][23] = 'b'
        expect(subject.skip?).to eq(true)
      end
      it "is true when it is 'c'" do
        @spm_item["BIB 008 MARC"][23] = 'c'
        expect(subject.skip?).to eq(true)
      end
    end
    it "is false for SDR EO item" do
      @spm_item["Library Code"] = "SDR"
      @spm_item["Location Code"] = "EO"
      @spm_item["Barcode"] = "definitely incorrect barcode but gets passed through anyway"
      expect(subject.skip?).to eq(false)
    end
    it "is true for SDR not EO item" do
      @spm_item["Library Code"] = "SDR"
      @spm_item["Location Code"] = "NOTEO"
      expect(subject.skip?).to eq(true)
    end
    it "is true for skippable library" do
      @spm_item["Library Code"] = "ELEC"
      expect(subject.skip?).to eq(true)
    end
    it "is true for skippable location" do
      @spm_item["Location Code"] = "GLMR"
      expect(subject.skip?).to eq(true)
    end
    it "is true for numeric location" do
      @spm_item["Location Code"] = "12345"
      expect(subject.skip?).to eq(true)
    end
    it "is true for 'MICRO' in beggining of callnumber" do
      @spm_item["Permanent Call Number"] = "MICRO #{@spm_item["Permanent Call Number"]}"
      expect(subject.skip?).to eq(true)
    end
    it "is true for Barcode that doesn't start with '\d9015'" do
      @spm_item["Barcode"] = "C39015"
      expect(subject.skip?).to eq(true)
    end
    it "is false for 'B' barcode" do
      @spm_item["Barcode"] = "B39015"
      expect(subject.skip?).to eq(false)
    end
    it "is false for 'A' barcode" do
      @spm_item["Barcode"] = "A39015"
      expect(subject.skip?).to eq(false)
    end
    it "is true for 'B' barcode that's in process" do
      @spm_item["Barcode"] = "B39015"
      @spm_item["Process Type"] = "In Process"
      expect(subject.skip?).to eq(true)
    end
    it "is true for 'A' barcode that's in process" do
      @spm_item["Barcode"] = "A39015"
      @spm_item["Process Type"] = "In Process"
      expect(subject.skip?).to eq(true)
    end
    it "is false for nil barcode" do
      @spm_item["Barcode"] =  nil
      expect(subject.skip?).to eq(false)
    end
  end
  context "#gov_doc" do
    it "returns true for a fed gov doc" do
      #example item: #990187209430106381
      @spm_item["BIB 008 MARC"] = "210504s2020####dcu######b###f000#0#eng#d"
      expect(subject.gov_doc).to eq(1)
    end
    it "returns false for a doc not from US" do
      #exmaple item #990007985430106381
      @spm_item["BIB 008 MARC"] = "010425s1983####cc#######b###f00010#chi##"
      expect(subject.gov_doc).to eq(0)
    end
    it "returns false for things that aren't federal" do
      #example item #990033530540106381
      @spm_item["BIB 008 MARC"] = "991115s1999####caua#####b####000#0#eng#d"
      expect(subject.gov_doc).to eq(0)
    end
    it "returns false if BIB 008 MARC is empty" do
      @spm_item["BIB 008 MARC"] =  nil
      expect(subject.gov_doc).to eq(0)
    end
  end
  context "#condition" do
    ["Brittle", "Damaged", "Deteriorating", "Fragile"].each do |cond|
      it "returns BRT for #{cond} condition" do
        @spm_item["Physical Condition"] = cond
        expect(subject.condition).to eq("BRT")
      end
    end
    it "returns empty string for 'None' condition" do
      @spm_item["Physical Condition"] = "None"
        expect(subject.condition).to eq("")
    end
  end
  context "#oclc" do
    let(:network_number) { 'OCLC Control Number (035a)'}
    it "handles nil Network Number" do
      @spm_item[network_number] = nil
      expect(subject.oclc).to eq("")
    end
    it "returns an appropriate oclc string" do
      expect(subject.oclc).to eq("26881499")
    end
    it "handles multiple values" do
      @spm_item[network_number] = "123; 12345"
      expect(subject.oclc).to eq("123,12345")
    end
    it "gets rid of redundant numbers" do
      @spm_item[network_number] = "965386288; 965386288"
      expect(subject.oclc).to eq("965386288")
    end
    it "gets rid of 0 padding" do
      @spm_item[network_number] = "0000001"
      expect(subject.oclc).to eq("1")
    end
    it "rejects 0" do
      @spm_item[network_number] = "0"
      expect(subject.oclc).to eq("")
    end
    it "accepts 9 digits" do
      @spm_item[network_number] = "1234567890"
      expect(subject.oclc).to eq("1234567890")
    end
    it "rejects more than 10 digits" do
      @spm_item[network_number] = "91234567890"
      expect(subject.oclc).to eq("")
    end
  end
  context "#mms_id" do
    it "returns appropriate string" do
      expect(subject.mms_id).to eq("990026435400106381")
    end
  end
  context "#holding_status" do
    it "returns CH for most cases" do
      expect(subject.holding_status).to eq("CH")
    end
    it "returns WD for Deleted Lifecycle" do
      @spm_item["Lifecycle"] = "Deleted"
      expect(subject.holding_status).to eq("WD")
    end
    it "returns WD for electronic only" do
      @spm_item["Library Code"] = "SDR"
      @spm_item["Location Code"] = "EO"
      expect(subject.holding_status).to eq("WD")
    end
    it "returns LM for 'Missing' Process Type" do
      @spm_item["Process Type"] = "Missing"
      expect(subject.holding_status).to eq("LM")
    end
    it "returns LM for 'Lost' Process Type" do
      @spm_item["Process Type"] = "Lost"
      expect(subject.holding_status).to eq("LM")
    end
    it "returns LM for 'Lost and paid' Process Type" do
      @spm_item["Process Type"] = "Lost and paid"
      expect(subject.holding_status).to eq("LM")
    end
    it "returns LM for 'Lost Resource Sharing Item' Process Type" do
      @spm_item["Process Type"] = "Lost and paid"
      expect(subject.holding_status).to eq("LM")
    end
  end

end
describe PrintHoldingsSerials do
  before(:each) do
    @serials_item = CSV.read('spec/fixtures/serials_item.csv', headers: true, encoding: 'bom|utf-8').first 
  end
  subject do
    described_class.new(@serials_item)
  end
  context "#issn" do
    it "returns comma separated issns" do
      expect(subject.issn).to eq("1476-5551,0887-6924")
    end
    it "handles nil issn" do
      @serials_item["ISSN"] = nil
      expect(subject.issn).to eq("")
    end
    it "handles filters out non issn values" do
      @serials_item["ISSN"] = "0022-3050; 1468-330X (online)"
      expect(subject.issn).to eq("0022-3050,1468-330X")
    end
    it "filters out invalid issns" do
      @serials_item["ISSN"] = "0022-3050; 1468-330a"
      expect(subject.issn).to eq("0022-3050")
    end
  end
end
