require "./spec_helper"

describe Schema::Rule do
  describe "#valid?" do
    it "applies rule" do
      rule = Schema::Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1) && _rule.lt?(1, 2)
      end

      rule.valid?.should be_true
    end
  end
end

describe Schema::Rules do
  subject = Schema::Rules(Schema::Rule, Symbol).new

  describe "#<<" do
    it "adds a rule" do
      rule = Schema::Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1) && _rule.lt?(1, 2)
      end

      subject << rule

      subject.size.should eq 1
    end
  end

  describe "#apply" do
    it "returns true all rules are valid" do
      subject = Schema::Rules(Schema::Rule, Symbol).new
      rule = Schema::Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1) && _rule.lt?(1, 2)
      end

      subject << rule
      subject.errors.should be_empty
    end

    it "returns false any rule is invalid" do
      subject = Schema::Rules(Schema::Rule, Symbol).new
      rule1 = Schema::Rule.new :field, "Invalid!" do |_rule|
        _rule.gte?(2, 1)
      end
      rule2 = Schema::Rule.new :field, "Invalid!" do |_rule|
        _rule.lt?(2, 1)
      end

      subject << rule1
      subject << rule2

      subject.size.should eq 2
      subject.errors.size.should eq 1
      subject.errors.should contain Schema::Error(Schema::Rule, Symbol).new(:field, "Invalid!")
    end
  end
end
