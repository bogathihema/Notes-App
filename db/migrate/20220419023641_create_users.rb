class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :permissions
      t.string :role
      t.text :shared_notes
      t.text :shared_users
      t.text :notes_permissions
      t.timestamps
    end
  end
end
