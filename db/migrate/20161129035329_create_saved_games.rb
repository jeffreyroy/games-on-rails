class CreateSavedGames < ActiveRecord::Migration[5.0]
  def change
    create_table :saved_games do |t|
      t.integer :user_id
      t.text :position
      t.boolean :human_to_move
      t.integer :human_pieces_left
      t.integer :computer_pieces_left
      t.integer :moving_piece_row
      t.integer :moving_piece_row
      t.integer :moves_left
      t.boolean :force_analysis

      t.timestamps
    end
  end
end
