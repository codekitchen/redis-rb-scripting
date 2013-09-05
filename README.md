# Redis::Scripting

Utilities built on redis-rb for using Redis Lua scripting.

[![Build Status](https://travis-ci.org/codekitchen/redis-rb-scripting.png?branch=master)](https://travis-ci.org/codekitchen/redis-rb-scripting)

## Installation

Add this line to your application's Gemfile:

    gem 'redis-scripting'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis-scripting

## Usage

Given a directory of lua scripts, you can create an object to run those
scripts with:

    > redis = Redis.new()
    > scripts = Redis::Scripting::Module.new(redis, "/path/to/myscripts")

Then you can run a script "do_work.lua" with:

    > scripts.run(:do_work, [keys], [argv])

See http://redis.io/commands/eval for details on the keys and argv
params, along with more details on lua in redis. To save bandwidth this
will use evalsha to run the script, and fallback to eval if the script
is not yet loaded in redis.

If your scripts directory "myscripts" has a "myscripts/includes"
subdirectory, any .lua files in that subdirectory will be prepended to
every .lua script in "myscripts" as a primitive form of extracting
library code. For instance if your folder structure is:

    - myscripts/
      - script1.lua
      - script2.lua
      - includes/
        - common.lua
        - more.lua

Then script1 and script2 will automatically have common.lua and then
more.lua prepended to it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
