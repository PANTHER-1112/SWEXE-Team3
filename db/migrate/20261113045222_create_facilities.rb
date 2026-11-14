class CreateFacilities < ActiveRecord::Migration[8.1]
  def change
    create_table :facilities do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.string :address
      t.float :map_x, null: false
      t.float :map_y, null: false

      t.timestamps
    end
  end
end
