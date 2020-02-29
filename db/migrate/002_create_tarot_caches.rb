class CreateTarotCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :tarot_caches do |t|
      t.string :filepath, null: false
      t.string :photo_id, null: false
    end
  end
end
