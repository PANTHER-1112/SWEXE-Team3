class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :disaster_type, null: false

      t.timestamps
    end
  end
end
