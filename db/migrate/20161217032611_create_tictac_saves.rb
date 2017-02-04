class CreateTictacSaves < ActiveRecord::Migration[5.0]
  def change
    create_table :tictac_saves do |t|
      t.integer :user_id
      t.text :position
      t.boolean :human_to_move
      t.timestamps
    end
  end
end
