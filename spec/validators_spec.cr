require "./spec_helper"

describe "Contract" do
  describe "#build" do
    Contract::VALIDATOR.each do |key, validator|
      it "builds a #{validator} validator" do
        Contract.validator_for(key, :field, 1, 1, "").class.to_s.should eq(validator.to_s)
      end
    end
  end
end
