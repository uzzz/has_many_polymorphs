class Dog < ActiveRecord::Base
end

class Cat < ActiveRecord::Base
end

class Ownership < ActiveRecord::Base
  belongs_to :master, :class_name => 'Person'
  belongs_to :pet, :polymorphic => true
end

class Person < ActiveRecord::Base
  has_many_polymorphs :pets,
    :as      => :master,
    :from    => [:cats, :dogs],
    :through => :ownerships
end

class SimpleModel < ActiveRecord::Base
end
