require "spec_helper"
describe PrintHoldingsItem do
  before(:each) do
    @spm_item = JSON.parse(fixture("spm_item.json"))
  end
  subject do
    described_class.new(@spm_item)
  end
  context "#gov_doc" do
    it "returns true for a fed gov doc" do
      @spm_item["BIB 008 MARC"] = "210504s2020####dcu######b###f000#0#eng#d"
      expect(subject.gov_doc).to eq(true)
    end
    it "returns false for a doc not from US" do
      #exmaple item #990007985430106381
      @spm_item["BIB 008 MARC"] = "010425s1983####cc#######b###f00010#chi##"
      expect(subject.gov_doc).to eq(false)
    end
    it "returns false for things that aren't federal" do
      #example item #990033530540106381
      @spm_item["BIB 008 MARC"] = "991115s1999####caua#####b####000#0#eng#d"
      expect(subject.gov_doc).to eq(false)
    end
  end
  context "#oclc" do
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
    it "handles ocm" do
      @spm_item["Network Number"] = "ocm12345678"
      expect(subject.oclc).to eq("12345678")
    end
    it "handles on" do
      @spm_item["Network Number"] = "on1234567890"
      expect(subject.oclc).to eq("1234567890")
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
