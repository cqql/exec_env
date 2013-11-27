# ExecEnv

Execute blocks in a manipulatable environment and capture messages
that did not get a response and would normally produce a `NameError`
or `NoMethodError`. For example use cases of this have a look at
[anaphoric](https://github.com/CQQL/anaphoric) or
[hash_builder](https://github.com/CQQL/hash_builder).

If you have another use case for this, please send me an email. I am
really interested if there are other use cases for this quite exotic
library.

## Installation

Add this line to your application's Gemfile:

    gem 'exec_env'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exec_env

## Usage

```ruby
scope = [1, 2, 3, 4]

env = ExecEnv::Env.new(locals: { foo: 2 })
env.locals[:bar] = 3
env.scope = scope

result = env.exec do
  exotic :dragon, :banana
  action do
    :nested
  end

  size * foo * bar
end

# Because the block was executed in the scope of the array.
result # => 24 == 2 * 3 * 4

env.messages
# => [
# =>  [:exotic, [:dragon, :banana], nil],
# =>  [:action, [], <Proc ...>]
# => ]
```

## Contributing

1. Fork it ( http://github.com/CQQL/exec_env/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
