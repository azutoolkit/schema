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

struct SchemaWrapper
  schema("User") do
    param email : String, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
    param name : String, size: (1..20)
    param age : Int32, gte: 24, lte: 25, message: "Must be 24 and 30 years old"
    param alive : Bool, eq: true
    param childrens : Array(String)
    param childrens_ages : Array(Int32)
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
    validate age, gte: 18, lte: 25, message: "Must be 24 and 30 years old"
    validate alive, eq: true
    validate childrens
    validate childrens_ages
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end
end

class ExampleController
  getter params : Hash(String, String)

  def initialize(@params)
  end

  schema "User" do
    param email : String, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
    param name : String, size: (1..20)
    param age : Int32, gte: 24, lte: 25, message: "Must be 24 and 30 years old"
    param alive : Bool, eq: true
    param childrens : Array(String)
    param childrens_ages : Array(Int32)

    schema("Address") do
      param street : String, size: (5..15)
      param zip : String, match: /\d{5}/
      param city : String, size: 2, in: %w[NY NJ CA UT]
    end
  end
end
