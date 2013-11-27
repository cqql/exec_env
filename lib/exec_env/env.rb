module ExecEnv
  # A manipulatable execution environment, that let's you inject local and
  # instance variables into a block and capture messages sent during it's
  # execution.
  class Env
    # A hash of local variables, that will be injected into the block
    #
    # Examples
    #
    #   env.locals = { foo: 3, bar: :symbol }
    attr_accessor :locals

    # A hash of instance variables, that will be injected into the block
    #
    # Examples
    #
    #   env.ivars = { :@foo => 3, :@bar => :symbol }
    attr_accessor :ivars

    # An object, that will serve as the scope of execution of the block
    #
    # Examples
    #
    #   # Unresolved method calls in the block will be forwarded to
    #   # the String object "An object"
    #   env.scope = "An object"
    attr_accessor :scope

    # An array of all messages that were not captured by locals or
    # the scope object.
    #
    # Examples
    #
    #   env.exec do
    #     test :foo, "bar"
    #     each do
    #       # ...
    #     end
    #   end
    #
    #   env.messages
    #   # => [[:test, [:foo, "bar], nil], [:each, [], <the block>]]
    attr_reader :messages
    
    def initialize (locals: {}, ivars: {}, scope: nil)
      @messages = []
      @locals = locals
      @ivars = ivars
      @scope = scope
    end

    # Execute a block in the manipulated environment.
    #
    # Additional arguments will be passed to the block.
    #
    # Returns the return value of the block
    def exec (*args, &block)
      if @scope
        @scope.instance_variables.each do |name|
          instance_variable_set(name, @scope.instance_variable_get(name))
        end
      end

      @ivars.each do |name, value|
        instance_variable_set(name, value)
      end
      
      instance_exec(*args, &block)
    end

    # Send a message, that completely bypasses the locals
    # and the scope and is added directly to #messages.
    def xsend (name, *args, &block)
      @messages << [name, args, block]
    end

    def method_missing (name, *args, &block)
      if @locals.key?(name) && args.size == 0 && !block
        @locals[name]
      elsif @scope && @scope.respond_to?(name)
        @scope.send(name, *args, &block)
      else
        @messages << [name, args, block]

        nil
      end
    end
  end
end
