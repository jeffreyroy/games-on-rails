class CreateChessSaves < ActiveRecord::Migration[5.0]
  def change
    create_table :chess_saves do |t|
      t.integer :user_id
      t.text :position
      t.boolean :human_to_move
      t.boolean :check
      t.boolean :force_analysis

      t.timestamps
    end
  end
end
