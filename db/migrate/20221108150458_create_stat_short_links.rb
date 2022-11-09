class CreateStatShortLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :stat_short_links do |t|
      t.references :short_link, foreign_key: true, null: false
      t.string :ip
      t.integer :count, default: 0
      t.json :additional_info, default: {}

      t.timestamps
    end
  end
end
