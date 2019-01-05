require "./spec_helper"

class UniqueRecordValidator
  getter :record, :message

  def initialize(@record : UserModel, @message : String)
  end

  def valid?
    false
  end
end

class UserModel
  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)

  validation do
    use UniqueRecordValidator
    validate email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!", unique_record: true
    validate name, size: (1..20)
    validate age, gte: 18, lte: 25, message: "Must be 24 and 30 years old"
    validate alive, eq: true
    validate childrens
    validate childrens_ages
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end
end

include Schema::Validators

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

describe Schema::Validators do
  describe "#eq?" do
    it { eq?(1, 1).should be_true }
    it { eq?("one", "one").should be_true }
    it { eq?(1, 2).should be_false }
  end

  describe "#exclude?" do
    it { exclude?(1, [2, 3, 4]).should be_true }
    it { exclude?(1, (3..5)).should be_true }
    it { exclude?(1, [0, 1, 2, 3]).should be_false }
    it { exclude?(1, (0..3)).should be_false }
  end

  describe "#gte?" do
    it { gte?(1, -1).should be_true }
    it { gte?(1, 0).should be_true }
    it { gte?(1, 1).should be_true }
    it { gte?(1, 2).should be_false }
  end

  describe "#gt?" do
    it { gt?(1, -1).should be_true }
    it { gt?(1, 0).should be_true }
    it { gt?(1, 1).should be_false }
    it { gt?(1, 2).should be_false }
  end

  describe "#lte?" do
    it { lte?(-1, 1).should be_true }
    it { lte?(0, 1).should be_true }
    it { lte?(1, 1).should be_true }
    it { lte?(2, 1).should be_false }
  end

  describe "#lt?" do
    it { lt?(-1, 1).should be_true }
    it { lt?(0, 1).should be_true }
    it { lt?(1, 1).should be_false }
    it { lt?(1, 2).should be_true }
  end

  describe "#in?" do
    it { in?(1, [1, 2, 3]).should be_true }
    it { in?(1, (-1..2)).should be_true }
    it { in?(1, (2..3)).should be_false }
    it { in?(1, [2, 3]).should be_false }
  end

  describe "#size?" do
    it { size?([1, 2, 3], 3).should be_true }
    it { size?((1..3), 3).should be_true }
    it { size?({1, 2, 3}, 3).should be_true }
    it { size?([1, 2, 3, 4], (1..6)).should be_true }
  end

  describe "#match?" do
    it { match?("test@example.com", /\w+@\w+\.\w{2,3}/).should be_true }
    it { match?("invalid", /\w+@\w+\.\w{2,3}/).should be_false }
  end
end
