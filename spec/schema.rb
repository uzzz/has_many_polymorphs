ActiveRecord::Schema.define :version => 0 do
  create_table "simple_models", :force => true do |t|
    t.string   "name"
  end

  create_table :dogs, :force => true do |t|
    t.string   :name
  end

  create_table :cats, :force => true do |t|
    t.string   :name
  end

  create_table :people, :force => true do |t|
    t.string :name
  end

  create_table :ownerships, :force => true do |t|
    t.integer :master_id
    t.integer :pet_id
    t.string  :pet_type
  end
end
