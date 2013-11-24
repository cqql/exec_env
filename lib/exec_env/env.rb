module ExecEnv
  # A manipulatable execution environment, that let's you inject local and
  # instance variables into a block and capture messages sent during it's
  # execution.
  class Env
    def initialize
      @captured_messages = []
    end
    
    def bindings= (bindings)
      @instance_vars, @locals = bindings.partition { |name, _| name.to_s.chars[0] == "@" }

      @locals = Hash[@locals]
      @instance_vars = Hash[@instance_vars]
    end

    def scope= (scope)
      @scope = scope
    end

    # Execute a block in the manipulated environent.
    def exec (&block)
      if @scope
        @scope.instance_variables.each do |name|
          instance_variable_set(name, @scope.instance_variable_get(name))
        end
      end

      if @instance_vars
        @instance_vars.each do |name, value|
          instance_variable_set(name, value)
        end
      end
            
      instance_exec(&block)
    end

    def captured_messages
      @captured_messages
    end

    def method_missing (name, *args, &block)
      @captured_messages << [name, args, block]
      
      if @locals && @locals.key?(name)
        @locals[name]
      elsif @scope && @scope.respond_to?(name)
        @scope.send(name)
      else
        nil
      end
    end
  end
end
