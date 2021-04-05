class AddUserIdToChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :user_id, :integer
  end
end
