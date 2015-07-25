require 'spec_helper.rb'

# NOTE: When using $open_pointers, always use different pointer
# addresses than any other specs have used! Otherwise, a pointer from
# a previous spec might release itself during the current spec, and
# you may get wrong results.

$open_pointers = []

def do_gc
  if RUBY_PLATFORM =~ /java/
    Java::Java.lang.System.gc
  else
    GC.start
  end
end

class AutoReleaseThing
  include NiceFFI::AutoRelease

  def self.release( ptr )
    # Remove the pointer address
    $open_pointers -= [ptr.address]
  end

  def initialize( val, autorelease = true )
    @pointer = _make_autopointer( val, autorelease )
  end

  attr_reader :pointer
end

class AutoReleaseDisabled
  include NiceFFI::AutoRelease

  def self.release( ptr )
    # Remove the pointer address
    $open_pointers -= [ptr.address]
  end

  def initialize( val, autorelease = false )
    @pointer = _make_autopointer( val, autorelease )
  end

  attr_reader :pointer
end

class NoReleaseMethod
  include NiceFFI::AutoRelease

  # No self.release method. Autorelease behavior should be disabled.

  def initialize( val, options={:autorelease => true} )
    @pointer = _make_autopointer( val, options[:autorelease] )
  end

  attr_reader :pointer
end

describe NiceFFI::AutoRelease do
  before :each do
    $open_pointers = []
  end

  describe "with autorelease enabled" do
    it "should release pointers when GCed" do
      1.upto(50) do |i|
        $open_pointers << i
        AutoReleaseThing.new( FFI::Pointer.new(i) )
      end

      5.times{  do_gc;  sleep 0.05  }

      # Almost all of them should have been garbage collected by now
      expect($open_pointers.length).to be <= 3
    end

    it "should not release pointers with other references" do
      remembered_things = []
      101.upto(120) do |i|
        remembered_things << AutoReleaseThing.new( FFI::Pointer.new(i) )
      end

      101.upto(150) do |i|
        $open_pointers << i
        AutoReleaseThing.new( FFI::Pointer.new(i) )
      end

      5.times{  do_gc;  sleep 0.05  }

      remembered_things.each do |thing|
        expect($open_pointers).to include( thing.pointer[0].address )
      end

      # Almost all of the rest should have been garbage collected by now
      expect($open_pointers.length).to be <= 23
    end

    it "should wrap the pointer in an AutoPointer" do
      ptr = FFI::Pointer.new(1)
      thing = AutoReleaseThing.new( ptr )
      expect(thing.pointer).to be_a( FFI::AutoPointer )
      expect(thing.pointer[0].address).to be(ptr.address)
    end
  end

  describe "with no self.release method" do
    it "should not release pointers when GCed" do
      expect(NoReleaseMethod).to_not receive(:_release)

      1001.upto(1050) do |i|
        NoReleaseMethod.new( FFI::Pointer.new(i) )
      end

      5.times{  do_gc;  sleep 0.05  }
    end

    it "should use the pointer as given" do
      ptr = FFI::Pointer.new(1)
      thing = NoReleaseMethod.new( ptr )
      expect(thing.pointer).to be(ptr)
    end
  end

  describe "with autorelease disabled" do
    it "should not release pointers when GCed" do
      expect(AutoReleaseDisabled).to_not receive(:_release)
      expect(AutoReleaseDisabled).to_not receive(:release)

      2001.upto(2050) do |i|
        AutoReleaseDisabled.new( FFI::Pointer.new(i) )
      end

      5.times{  do_gc;  sleep 0.05  }
    end

    it "should use the pointer as given" do
      ptr = FFI::Pointer.new(1)
      thing = AutoReleaseDisabled.new( ptr )
      expect(thing.pointer).to be(ptr)
    end
  end
end
