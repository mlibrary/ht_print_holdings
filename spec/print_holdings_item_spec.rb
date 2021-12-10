require "spec_helper"
describe PrintHoldingsItem do
  before(:each) do
    @spm_item = JSON.parse(fixture("spm_item.json"))
  end
  subject do
    described_class.new(@spm_item)
  end
  context "#oclc" do
    it "returns an appropriate oclc string" do
      expect(subject.oclc).to eq("(OCoLC)ocm26881499")
    end
    it "handles multiple oclc strings" do
      @spm_item["Network Number"] = "(OCoLC)ocn965386288; (OCoLC)965386288; (MiU)014980159MIU01"
      expect(subject.oclc).to eq("(OCoLC)ocn965386288,(OCoLC)965386288")
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
