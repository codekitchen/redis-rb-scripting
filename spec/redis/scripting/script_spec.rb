require 'spec_helper'

describe Redis::Scripting::Script do
  let(:source_filename) { File.dirname(__FILE__) + "/scripts/test1.lua" }

  context "no header" do
    let(:subject) { Redis::Scripting::Script.new(source_filename) }

    its(:name) { should == "test1" }
    its(:source) { should == File.read(source_filename) }
    its(:sha) { should == OpenSSL::Digest::SHA1.hexdigest(subject.source) }
  end

  context "header" do
    let(:header) { "local x = 5" }
    let(:subject) { Redis::Scripting::Script.new(source_filename, script_header: header) }

    its(:source) { should == "#{header}\n\n#{File.read(source_filename)}" }
    its(:sha) { should == OpenSSL::Digest::SHA1.hexdigest(subject.source) }
  end

  describe "#run" do
    let(:subject) { Redis::Scripting::Script.new(source_filename) }

    it "should evalsha first" do
      redis = double('Redis')
      expect(redis).to receive(:evalsha).with(subject.sha, keys: ['a'], argv: ['b']) { 1 }
      subject.run(redis, ['a'], ['b']).should == 1
    end

    it "should eval if evalsha raises NOSCRIPT" do
      redis = double('Redis')
      expect(redis).to receive(:evalsha) { raise(Redis::CommandError, "NOSCRIPT doesn't exist") }
      expect(redis).to receive(:eval).with(subject.source, keys: ['a'], argv: ['b']) { 1 }
      subject.run(redis, ['a'], ['b']).should == 1
    end
  end
end
