class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :category
      t.string :link

      t.timestamps
    end
  end
end
