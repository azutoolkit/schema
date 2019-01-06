require "./spec_helper"

class EmailValidator
  getter :record, :message

  def initialize(@record : UserModel, @message : String)
  end

  def valid?
    true
  end
end

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
    use UniqueRecordValidator, UserModel
    use EmailValidator
    validate email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!", unique_record: true, email: true
    validate name, size: (1..20)
    validate age, gte: 18, lte: 25, message: "Must be 24 and 30 years old", some: "hello"
    validate alive, eq: true
    validate childrens
    validate childrens_ages, if: something?

    predicates do
      def some?(value, compare) : Bool
        false
      end

      def if?(value : Array(Int32), bool : Bool) : Bool
        !bool
      end
    end
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end

  def something?
    false
  end

  def add_custom_rule
    errors << {:fake, "fake error message"}
  end
end

describe Schema::Validation do
  subject = UserModel.new(
    "fake@example.com",
    "Fake name",
    25,
    true,
    ["Child 1", "Child 2"],
    [9, 12]
  )

  context "with custom validator" do
    it "it validates the user" do
      subject.errors.clear
      subject.valid?.should be_falsey
      subject.errors.map(&.message).should eq ["Email must be valid!", "Must be 24 and 30 years old"]
    end
  end

  context "with custom predicate" do
    it "validates the user" do
      subject.errors.clear
      subject.valid?.should be_falsey
      subject.errors.map(&.message).should eq ["Email must be valid!", "Must be 24 and 30 years old"]
    end
  end

  context "when adding your own errors" do
    subject = UserModel.new(
      "fake@example.com",
      "Fake name",
      25,
      true,
      ["Child 1", "Child 2"],
      [9, 12]
    )

    it "adds custom rules" do
      subject.errors.clear
      subject.add_custom_rule

      error = subject.errors.first

      subject.errors.size.should eq 1
      error.field.should eq :fake
      error.message.should eq "fake error message"
    end
  end
end
