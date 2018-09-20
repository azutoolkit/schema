macro contract(klass, key = "")
  def {{klass.id.downcase}}
    {{klass.id}}.instance(@params, {{key.id.stringify}})
  end

  struct {{klass.id}}
    include Contract::Validation
    @params : Hash(Contract::Key, Value)

    def self.instance(params : Hash(Contract::Key, Contract::Validation::Value), key)
      @@instance ||= new(params, key)
    end

    {{yield}}
  end
end
