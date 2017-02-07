class CreateCheckersSaves < ActiveRecord::Migration[5.0]
  def change
    create_table :checkers_saves do |t|
      t.integer :user_id
      t.text :position
      t.boolean :human_to_move
      t.integer :moving_piece_row
      t.integer :moving_piece_column
      
      t.timestamps
    end
  end
end
