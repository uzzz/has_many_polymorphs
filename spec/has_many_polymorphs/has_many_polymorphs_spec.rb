require File.expand_path('../../spec_helper', __FILE__)

describe 'has_many_polymorphs' do
  it 'should assert valid options' do
    lambda do
    Person.has_many_polymorphs :pets,
      :as => :master,
      :from => [:cats, :dogs],
      :through => :ownerships,
      :not_valid => true
    end.should raise_error(ArgumentError)
  end

  it 'should raise exception when :from option is not array' do
    lambda do
      SimpleModel.has_many_polymorphs :foobar, :from => :foo
    end.should raise_error(ActiveRecord::Associations::PolymorphicError)
  end

  it 'should rename individual associations if :rename_individual_collections set to true' do
    Person.has_many_polymorphs :pets,
      :as => :master,
      :from => [:cats, :dogs],
      :through => :ownerships,
      :rename_individual_collections => true

    Person.reflections[:pet_cats].should_not be_nil
    Person.reflections[:pet_dogs].should_not be_nil
    Person.reflections[:dogs].should be_nil
    Person.reflections[:cats].should be_nil
  end

  it 'should not rename individual associations if :rename_individual_collections set to false' do
    Person.has_many_polymorphs :pets,
      :as => :master,
      :from => [:cats, :dogs],
      :through => :ownerships

    Person.reflections[:dogs].should_not be_nil
    Person.reflections[:cats].should_not be_nil
  end

  it 'should to gues FK if no :as and no :foreign_key were passed' do
    Person.has_many_polymorphs :pets,
      :from => [:cats, :dogs],
      :through => :ownerships

    Person.reflections[:pets].options[:foreign_key].should == 'person_id'
  end

  it 'should use it if :foreign_key was passed' do
    Person.has_many_polymorphs :pets,
      :from => [:cats, :dogs],
      :through => :ownerships,
      :foreign_key => :master_id

    Person.reflections[:pets].options[:foreign_key].should == :master_id
  end

  it 'should create FK from :as' do
    Person.has_many_polymorphs :pets,
      :as => :master,
      :from => [:cats, :dogs],
      :through => :ownerships

    Person.reflections[:pets].options[:foreign_key].should == 'master_id'
  end
end
