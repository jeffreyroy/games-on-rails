class CreateGomokuSaves < ActiveRecord::Migration[5.0]
  def change
    create_table :gomoku_saves do |t|
      t.integer :user_id
      t.text :position
      t.boolean :human_to_move
      t.integer :human_last_row
      t.integer :human_last_column
      t.integer :computer_last_row
      t.integer :computer_last_column
      t.integer :top
      t.integer :bottom
      t.integer :left
      t.integer :right
      t.timestamps
    end
  end
end
