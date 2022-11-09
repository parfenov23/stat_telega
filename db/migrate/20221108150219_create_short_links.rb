class CreateShortLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :short_links do |t|
      t.string :link_id
      t.string :link
      t.integer :channel_id
      t.integer :order_channel_id

      t.timestamps
    end
  end
end
