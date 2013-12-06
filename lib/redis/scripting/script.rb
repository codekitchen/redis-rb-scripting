require 'openssl'

class Redis
module Scripting

class Script
  attr_reader :source_filename, :source, :name

  def initialize(source_filename, opts = {})
    @source_filename = source_filename
    @source = File.read(source_filename)
    if opts[:script_header]
      @source = "#{opts[:script_header]}\n\n#{@source}"
    end
    @name = File.basename(source_filename, ".lua")
  end

  def run(redis, keys, argv)
    begin
      redis.evalsha(self.sha, keys: keys, argv: argv)
    rescue Redis::CommandError => err
      raise unless err.message.start_with?("NOSCRIPT")
      redis.eval(self.source, keys: keys, argv: argv)
    end
  end

  def sha
    @sha ||= OpenSSL::Digest::SHA1.hexdigest(source)
  end

  def load(redis)
    redis.script(:load, source)
  end
end

end
end
