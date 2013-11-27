describe ExecEnv::Env do
  let(:env) { ExecEnv::Env.new }

  it "should allow injecting locals" do
    value = nil

    env.locals = { it: 5 }
    env.exec do
      value = it
    end

    expect(value).to eq 5
  end

  it "should allow injecting instance variables" do
    value = nil

    env.ivars = { :@bind => :test }
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

  it "should dispatch method calls to locals" do
    value = nil
    scope = Object.new
    def scope.it (value)
      value
    end

    env.scope = scope
    env.bindings = { it: :binding }
    env.exec do
      value = it(:scope)
    end

    expect(value).to eq :scope
  end

  it "should evaluate locals before scope methods" do
    value = nil
    scope = Object.new
    def scope.it
      :scope
    end

    env.scope = scope
    env.locals = { it: :binding }
    env.exec do
      value = it
    end

    expect(value).to eq :binding
  end

  it "should overshadow scope ivars with explicit ones" do
    value = nil
    scope = Object.new
    scope.instance_variable_set(:@it, :scope)

    env.scope = scope
    env.ivars = { :@it => :binding }
    env.exec do
      value = @it
    end

    expect(value).to eq :binding
  end

  it "should track captured messages" do
    block = -> { :block }
    scope = Object.new
    def scope.number
      10
    end

    env.locals = { bind: 5 }
    env.scope = scope
    env.exec do
      var = bind
      var += number

      bind 15
      name(:var, &block)
    end

    expect(env.captured_messages).to eq [[:bind, [], nil], [:number, [], nil]]
  end
  
  it "should track free messages" do
    block = -> { :block }
    scope = Object.new
    def scope.number
      10
    end

    env.locals = { bind: 5 }
    env.scope = scope
    env.exec do
      var = bind
      var += number

      bind 15
      name(:var, &block)
    end

    expect(env.free_messages).to eq [[:bind, [15], nil], [:name, [:var], block]]
  end

  it "should pass arguments to the block" do
    value = nil

    env.exec -10, 3 do |num, factor|
      value = num * factor
    end

    expect(value).to eq -30
  end
end
