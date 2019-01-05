require "./spec_helper"

describe Schema::Validation do
  context "when Custom Validator" do
    it "defines validation for the given object" do
      subject = UserModel.new(
        "fake@example.com",
        "Fake name",
        25,
        true,
        ["Child 1", "Child 2"],
        [9, 12]
      )

      subject.valid?.should be_falsey
    end
  end
end
