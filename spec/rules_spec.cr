require "./spec_helper"

describe Rule do
  describe "#valid?" do
    it "applies rule" do
      rule = Rule.new :field, "Invalid!" do |rule|
        rule.gte?(2, 1) && rule.lt?(1, 2)
      end

      rule.valid?.should be_true
    end
  end
end

describe Rules do
  subject = Rules.new

  describe "#<<" do
    it "adds a rule" do
      rule = Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1) && rule.lt?(1, 2)
      end

      subject << rule

      subject.size.should eq 1
    end
  end

  describe "#apply" do
    it "returns true all rules are valid" do
      subject = Rules.new
      rule = Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1) && rule.lt?(1, 2)
      end

      subject << rule
      subject.errors.should be_empty
    end

    it "returns false any rule is invalid" do
      subject = Rules.new
      rule1 = Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1)
      end
      rule2 = Rule.new :field, "Invalid!" do |_rule|
        _rule.lt?(2, 1)
      end

      subject << rule1
      subject << rule2

      subject.size.should eq 2
      subject.errors.size.should eq 1
      subject.errors.should contain Error.new(:field, "Invalid!")
    end
  end
end
