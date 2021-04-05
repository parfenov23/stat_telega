class AddProcessedToChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :processed, :boolean, default: false
    add_column :channels, :archive, :boolean, default: false

    execute <<-SQL
      UPDATE channels 
      SET processed = true
      WHERE channels.category IS NOT NULL
    SQL
  end
end
