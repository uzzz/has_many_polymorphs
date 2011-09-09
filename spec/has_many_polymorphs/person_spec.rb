require File.expand_path('../../spec_helper', __FILE__)

describe 'Person' do
  before(:each) do
    clean_database!
    @person = Person.create :name => 'Max'
  end

  it 'should have pets polymorphic association' do
    Person.reflections[:pets].should_not be_nil
    Person.reflections[:pets].class.should == ActiveRecord::Reflection::PolymorphicReflection
    Person.reflections[:pets].macro.should == :has_many_polymorphs
  end

  it 'should have ownerships has_many association' do
    Person.reflections[:ownerships].should_not be_nil
    Person.reflections[:ownerships].class.should == ActiveRecord::Reflection::AssociationReflection
    Person.reflections[:ownerships].macro.should == :has_many
  end

  it 'should know how to create and push different models to association' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog
    @person.pets.push(cat)

    @person.pets.should == [dog, cat]
  end

  it 'should reload' do
    @person.pets.reload.should == []
  end

  it 'should corretly recognize join association' do
    dog = Dog.create :name => 'Dog'
    Ownership.create :master => @person, :pet => dog

    @person.pets.should == [dog]
  end

  it 'should have self-reference' do

  end

  it 'should know how to count objects in a polymorphic association' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog << cat

    @person.pets.count.should == 2
  end

  it 'should delete on polymorphic association' do
    dog = Dog.create :name => 'Dog'
    @person.pets << dog

    @person.pets.delete(dog)
    @person.pets.count.should == 0
    Ownership.find_by_pet_id_and_pet_type(dog.id, 'Dog').should be_nil
  end

  it 'should clear on polymorphic association' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog << cat

    @person.pets.count.should == 2

    @person.pets.clear
    @person.pets.count.should == 0
    Ownership.find_by_pet_id_and_pet_type(dog.id, 'Dog').should be_nil
    Ownership.find_by_pet_id_and_pet_type(cat.id, 'Cat').should be_nil
  end

  it 'should have individual collections' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog << cat

    @person.pet_cats.should == [cat]
    @person.pet_dogs.should == [dog]
  end

  it 'should know how to push to individual collections' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'

    @person.pet_dogs.push(dog)
    @person.pet_dogs.push(cat)

    @person.pets.should == [dog, cat]
  end

  it 'should know how to delete on individual collections' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog << cat

    @person.pet_dogs.delete(dog)

    @person.pet_dogs.should be_blank
    @person.pet_cats.should == [cat]
    @person.pets.should == [cat]
  end

  it 'should know how to clear individual collections' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog << cat

    @person.pet_dogs.clear

    @person.pet_dogs.should be_blank
    @person.pet_cats.should == [cat]
    @person.pets.should == [cat]
  end

  it 'should have association on children models' do
    dog = Dog.create :name => 'Dog'
    @person.pets << dog

    dog.ownerships.should_not be_nil
    dog.ownerships.count.should == 1
    @person.ownerships.count.should == 1
  end

  it 'should have empty collections on unsaved record' do
    Person.new.pets.should be_empty
    Dog.new.ownerships.should be_empty
  end

  it 'should scope' do
    dog = Dog.create :name => 'Dog'
    cat = Cat.create :name => 'Cat'
    @person.pets << dog << cat

    @person.pets.order('ownerships.id ASC').should == [dog, cat]
    @person.pets.order('ownerships.id DESC').should == [cat, dog]
    @person.pets.limit(1).all.size.should == 1
    @person.pets.where('dogs.name' => 'Dog').should == [dog]
  end
end
