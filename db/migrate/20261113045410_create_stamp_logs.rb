class CreateStampLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :stamp_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :facility, null: false, foreign_key: true
      t.datetime :visited_at, null: false

      t.timestamps
    end
    add_index :stamp_logs, [ :user_id, :facility_id ], unique: true
  end
end
