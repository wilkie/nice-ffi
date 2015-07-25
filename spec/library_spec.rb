require 'spec_helper.rb'


describe NiceFFI::Library do

  before :each do
    @module = Module.new do
      extend NiceFFI::Library
    end
  end

  describe "#optional" do

    before :each do
      # Discard puts calls for these specs, for neatness
      def @module.puts(s=""); end;
    end

    it "should take a block" do
      expect {
        @module.module_eval{ optional{} }
      }.to_not raise_error
    end

    it "should complain if there's no block" do
      expect {
        @module.module_eval{ optional }
      }.to raise_error(LocalJumpError)
    end

    it "should rescue NotFoundErrors raised by the block" do
      expect {
        @module.module_eval{
          optional{ raise FFI::NotFoundError, "foo" }
        }
      }.to_not raise_error
    end

    it "should accept a custom message" do
      expect {
        @module.module_eval{ optional("my message"){} }
      }.to_not raise_error
    end

    it "should print the error message upon NotFoundError" do
      expect(@module).to receive(:puts).with(/foo/)
      @module.module_eval{
        optional{ raise FFI::NotFoundError, "foo" }
      }
    end

    it "should print the custom message upon NotFoundError" do
      expect(@module).to receive(:puts).with("my message")
      @module.module_eval{
        optional("my message"){ raise FFI::NotFoundError, "foo" }
      }
    end

  end

end
