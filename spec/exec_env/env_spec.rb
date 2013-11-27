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

  it "should dispatch method calls to the scope object" do
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

  it "should inject instance variables from the scope object" do
    value = nil
    scope = Object.new
    scope.instance_variable_set(:@symbol, :value)

    env.scope = scope
    env.exec do
      value = @symbol
    end

    expect(value).to eq :value
  end

  it "should dispatch method calls to the scope" do
    value = nil
    scope = Object.new
    def scope.it (value)
      value
    end

    env.scope = scope
    env.locals = { it: :binding }
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

  it "should track unresolved messages" do
    block = -> { :block }
    scope = Object.new
    def scope.number
      10
    end

    env.locals = { foo: 5 }
    env.scope = scope
    env.exec do
      var = foo
      var += number

      foo 15
      name(:var, 33, &block)
    end

    expect(env.messages).to eq [[:foo, [15], nil], [:name, [:var, 33], block]]
  end

  it "should allow bypassing locals and the scope with xsend" do
    scope = Object.new
    def scope.foo (arg)
      :in_scope
    end

    env.scope = scope
    env.locals = { foo: 12 }
    env.exec do
      xsend :foo, 37
    end

    expect(env.messages).to eq [[:foo, [37], nil]]
  end

  it "should pass arguments to the block" do
    value = nil

    env.exec -10, 3 do |num, factor|
      value = num * factor
    end

    expect(value).to eq -30
  end

  it "should return the return value of the block" do
    value = env.exec do
      1337
    end

    expect(value).to eq 1337
  end
end
