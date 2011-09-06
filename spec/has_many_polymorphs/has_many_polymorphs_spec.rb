require File.expand_path('../../spec_helper', __FILE__)

describe 'has_many_polymorphs' do
  it 'should assert valid options' do
    lambda do
      SimpleModel.has_many_polymorphs :foobar, :from => [:foo, :bar],
        :not_valid => true
    end.should raise_error(ArgumentError)
  end

  it 'should raise exception when :from option is not array' do
    lambda do
      SimpleModel.has_many_polymorphs :foobar, :from => :foo
    end.should raise_error(ActiveRecord::Associations::PolymorphicError)
  end
end
