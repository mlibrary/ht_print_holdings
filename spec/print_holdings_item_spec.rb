require "spec_helper"
require "csv"
describe PrintHoldingsItem do
  before(:each) do
#    @spm_item = JSON.parse(fixture("spm_item.json"))
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
    it "is true for SDR not EO item" do
      @spm_item["Library Code"] = "SDR"
      @spm_item["Location Code"] = "NOTEO"
      expect(subject.skip?).to eq(true)
    end
    it "is true for skippable location" do
      @spm_item["Location Code"] = "GLMR"
      expect(subject.skip?).to eq(true)
    end
    it "is true for 'MICRO' in beggining of callnumber" do
      @spm_item["Permanent Call Number"] = "MICRO #{@spm_item["Permanent Call Number"]}"
      expect(subject.skip?).to eq(true)
    end
    it "is true for Barcode that doesn't start with '\d9015'" do
      @spm_item["Barcode"] = "B39015"
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
    it "handles nil Network Number" do
      @spm_item["Network Number"] = nil
      expect(subject.oclc).to eq("")
    end
    it "returns an appropriate oclc string" do
      expect(subject.oclc).to eq("26881499")
    end
    it "handles multiple oclc strings" do
      @spm_item["Network Number"] = "(OCoLC)ocn965386288; (OCoLC)965386289; (MiU)014980159MIU01"
      expect(subject.oclc).to eq("965386288,965386289")
    end
    it "gets rid of redundant numbers" do
      @spm_item["Network Number"] = "(OCoLC)ocn965386288; (OCoLC)965386288; (MiU)014980159MIU01"
      expect(subject.oclc).to eq("965386288")
    end
    it "gets rid of 0 padding" do
      @spm_item["Network Number"] = "(OCoLC)ocl70000001"
      expect(subject.oclc).to eq("1")
    end
    it "handles (OCLC)" do
      @spm_item["Network Number"] = "(OCLC)12345678"
      expect(subject.oclc).to eq("12345678")
    end
    it "handles ocm" do
      @spm_item["Network Number"] = "ocm12345678"
      expect(subject.oclc).to eq("12345678")
    end
    it "handles on" do
      @spm_item["Network Number"] = "on1234567890"
      expect(subject.oclc).to eq("1234567890")
    end
    it "is case insenstive" do
      @spm_item["Network Number"] = "ON1234567890; OCM12345678; (ocOlc)ocn919191"
      expect(subject.oclc).to eq("1234567890,12345678,919191")
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
