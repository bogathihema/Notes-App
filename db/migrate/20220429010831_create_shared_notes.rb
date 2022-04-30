class CreateSharedNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :shared_notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true
      t.string :permissions

      t.timestamps
    end
  end
end
