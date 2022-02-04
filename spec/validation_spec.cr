require "./spec_helper"
require "../src/schema/validation"

class UserModel
  include Schema::Validation

  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)
  property last_name : String

  use EmailValidator, UniqueRecordValidator
  validate :email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
  validate :name, size: (1..20)
  validate :age, gte: 18, lte: 25, message: "Age must be 18 and 25 years old"
  validate :alive, eq: true
  validate :last_name, presence: true, message: "Last name is invalid"

  predicates do
    def some?(value : String, some) : Bool
      (!value.nil? && value != "") && !some.nil?
    end

    def if?(value : Array(Int32), bool : Bool) : Bool
      !bool
    end
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages, @last_name)
  end

  def add_custom_rule
    errors << Schema::Error.new(:fake, "fake error message")
  end
end

class EmailValidator < Schema::Validator
  getter :record, :field, :message

  def initialize(@record : UserModel)
    @field = :email
    @message = "Email must be valid!"
  end

  def valid? : Array(Schema::Error)
    [] of Schema::Error
  end
end

class UniqueRecordValidator < Schema::Validator
  getter :record, :field, :message

  def initialize(@record : UserModel)
    @field = :email
    @message = "Record must be unique!"
  end

  def valid? : Array(Schema::Error)
    [] of Schema::Error
  end
end

describe Schema::Validation do
  context "with custom validator" do
    subject = UserModel.new(
      "bad", "Fake name", 38, true, ["Child 1", "Child 2"], [9, 12], ""
    )

    it "it validates the user" do
      subject.valid?.should be_falsey
      expect_raises(Schema::Validation::ValidationError) do
        subject.validate!
      end
      subject.errors.map(&.message).should eq [
        "Email must be valid!",
        "Age must be 18 and 25 years old",
        "Last name is invalid",
      ]
    end
  end
end
