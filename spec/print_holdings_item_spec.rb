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
end
