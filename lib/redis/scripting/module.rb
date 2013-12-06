require "redis"
require "redis/scripting/script"

class Redis
module Scripting

class Module
  attr_reader :source_dir
  attr_accessor :redis

  def initialize(redis, source_dir, opts = {})
    @redis = redis
    @source_dir = source_dir
    @scripts = {}
    load_scripts()
  end

  def run(script_name, keys, argv, redis = self.redis)
    script = @scripts[script_name.to_s]
    raise(ArgumentError, "unknown script: #{script_name}") unless script

    script.run(redis, keys, argv)
  end

  def inspect
    %{<%s: 0x%x @source_dir="%s" @redis=%s>} % [self.class, object_id, source_dir, redis]
  end

  private

  def load_scripts
    headers = Dir.glob(File.join(source_dir, "includes", "*.lua")).map { |include_name|
      File.read(include_name)
    }

    if !headers.empty?
      header_source = headers.join("\n\n") + "\n\n"
    end

    Dir.glob(File.join(source_dir, "*.lua")).each do |filename|
      script = Redis::Scripting::Script.new(filename, script_header: header_source)
      script.load(redis)
      @scripts[script.name] = script
    end
  end
end

end
end
