class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :body
      t.text :shared_users
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
