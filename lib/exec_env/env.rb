module ExecEnv
  # A manipulatable execution environment, that let's you inject local and
  # instance variables into a block and capture messages sent during it's
  # execution.
  class Env
    attr_writer :locals
    attr_writer :ivars
    
    def initialize
      @messages = []
      @locals = {}
      @ivars = {}
    end
    
    def scope= (scope)
      @scope = scope
    end

    # Execute a block in the manipulated environent.
    def exec (*args, &block)
      if @scope
        @scope.instance_variables.each do |name|
          instance_variable_set(name, @scope.instance_variable_get(name))
        end
      end

      if @ivars
        @ivars.each do |name, value|
          instance_variable_set(name, value)
        end
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
            
      if @locals && @locals.key?(name) && args.size == 0 && !block
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
