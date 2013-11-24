describe ExecEnv::Env do
  let(:env) { ExecEnv::Env.new }

  it "should allow setting unbound variables" do
    value = nil

    env.bindings = { it: 5 }
    env.exec do
      value = it
    end

    expect(value).to eq 5
  end

  it "should allow setting instance variables" do
    value = nil

    env.bindings = { :@bind => :test }
    env.exec do
      value = @bind
    end

    expect(value).to eq :test
  end

  it "should introduce bindings from a scope object" do
    value = nil
    scope = Object.new
    def scope.it
      "value"
    end

    env.scope = scope
    env.exec do
      value = it
    end

    expect(value).to eq "value"
  end

  it "should use instance variables from a scope object" do
    value = nil
    scope = Object.new
    scope.instance_variable_set(:@symbol, :value)

    env.scope = scope
    env.exec do
      value = @symbol
    end

    expect(value).to eq :value
  end
end
