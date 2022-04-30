class AddSharedUserIdToSharedNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :shared_notes, :shared_user_id, :integer
  end
end
