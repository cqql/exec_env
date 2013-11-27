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

    # The messages that were sent "in" the block and were "captured" by the
    # scope or locals. They are in call-order.
    #
    # Returns an array of arrays structured as
    # [<name>, <array of parameters>, <block or nil>]
    def captured_messages
      @messages.select { |m| m.first }.map { |m| m[1] }
    end

    # The messages that were sent "in" the block and were not captured by
    # the scope or locals. The are in call-order.
    def free_messages
      @messages.select { |m| !m.first }.map { |m| m[1] }
    end

    def method_missing (name, *args, &block)
      result = nil
      captured = false
      
      if @locals.key?(name) && args.size == 0 && !block
        captured = true
        result = @locals[name]
      elsif @scope && @scope.respond_to?(name)
        captured = true
        result = @scope.send(name, *args, &block)
      end

      @messages << [captured, [name, args, block]]

      result
    end
  end
end
