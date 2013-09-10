require 'spec_helper'

describe Redis::Scripting::Module do
  let(:redis) { double('Redis') }
  let(:source_dir) { File.dirname(__FILE__) + "/scripts" }
  let(:subject) { Redis::Scripting::Module.new(redis, source_dir) }

  its(:source_dir) { should == source_dir }
  its(:redis) { should == redis }

  describe "#run" do
    it "should raise on unknown" do
      expect { subject.run(:whut, [], []) }.to raise_error(ArgumentError)
    end

    it "should use initializer redis by default" do
      expect(redis).to receive(:evalsha) { 1 }
      subject.run(:test1, [], []).should == 1
    end

    it "should use the given redis" do
      redis2 = double('Redis2')
      expect(redis2).to receive(:evalsha) { 1 }
      subject.run(:test1, [], [], redis2).should == 1
    end
  end
end

