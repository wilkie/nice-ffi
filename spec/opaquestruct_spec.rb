require 'spec_helper.rb'

class OpaqueThing < NiceFFI::OpaqueStruct
  def self.release( ptr )
  end
end

describe NiceFFI::OpaqueStruct do
  it "should include AutoRelease module" do
    mods = NiceFFI::OpaqueStruct.included_modules
    expect(mods).to include(NiceFFI::AutoRelease)
  end

  it "should accept an AutoPointer" do
    ptr = FFI::AutoPointer.new( FFI::Pointer.new(1), proc{} )
    expect { OpaqueThing.new( ptr ) }.to_not raise_error
  end

  it "should use the given AutoPointer" do
    ptr = FFI::AutoPointer.new( FFI::Pointer.new(1), proc{} )
    op = OpaqueThing.new( ptr )
    expect(op.pointer).to be( ptr )
  end

  it "should accept a null pointer" do
    ptr = FFI::Pointer.new(0)
    expect { OpaqueThing.new( ptr ) }.to_not raise_error
  end

  it "should use the given null pointer" do
    ptr = FFI::Pointer.new(0)
    op = OpaqueThing.new( ptr )
    expect(op.pointer).to be( ptr )
  end

  it "should accept a Pointer" do
    ptr = FFI::Pointer.new(1)
    expect { OpaqueThing.new( ptr ) }.to_not raise_error
  end

  it "should wrap the given Pointer in an AutoPointer" do
    ptr = FFI::Pointer.new(1)
    op = OpaqueThing.new( ptr )
    expect(op.pointer).to be_an_instance_of( FFI::AutoPointer )
  end

  it "should accept another OpaqueStruct" do
    op = OpaqueThing.new( FFI::Pointer.new(1) )
    expect { OpaqueThing.new( op ) }.to_not raise_error
  end

  it "should use the given OpaqueStruct's pointer" do
    op1 = OpaqueThing.new( FFI::Pointer.new(1) )
    op2 = OpaqueThing.new( op1 )
    expect(op2.pointer).to be( op1.pointer )
  end

  it "should not accept a MemoryPointer" do
    ptr = FFI::MemoryPointer.new( :int )
    expect { OpaqueThing.new( ptr ) }.to raise_error(TypeError)
  end

  it "should not accept a Buffer" do
    ptr = FFI::Buffer.new( :int )
    expect { OpaqueThing.new( ptr ) }.to raise_error(TypeError)
  end

  it "should have a pointer reader" do
    op = OpaqueThing.new( FFI::Pointer.new(1) )
    expect(op).to respond_to( :pointer )
  end

  it "pointer should return the pointer" do
    op = OpaqueThing.new( FFI::Pointer.new(1) )
    expect(op.to_ptr).to be_a( FFI::AutoPointer )
  end

  it "should have a to_ptr method" do
    op = OpaqueThing.new( FFI::Pointer.new(1) )
    expect(op).to respond_to( :to_ptr )
  end

  it "to_ptr should return the pointer" do
    op = OpaqueThing.new( FFI::Pointer.new(1) )
    expect(op.to_ptr).to be_a( FFI::AutoPointer )
  end

  it "should have typed_pointer" do
    expect(OpaqueThing).to respond_to( :typed_pointer )
  end

  it "typed_pointer should give a TypedPointer" do
    tp = OpaqueThing.typed_pointer
    expect(tp).to be_an_instance_of( NiceFFI::TypedPointer )
  end

  it "the typed_pointer should have the right type" do
    tp = OpaqueThing.typed_pointer
    expect(tp.type).to be(OpaqueThing)
  end
end
