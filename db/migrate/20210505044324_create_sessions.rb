class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.string :names, array: true, default: []
      t.timestamps
    end
  end
end
