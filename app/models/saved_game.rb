class SavedGame < ApplicationRecord
  # belongs_to :user

  # Parse position string
  # Return position in array form
  def position_array
    size = Math.sqrt(position.length)
    chunk(position, size).map { |row| chunk(row, 1) }
  end

  # Helper function to split string
  def chunk(string, size)
    string.scan(/.{1,#{size}}/)
  end

  def position_array=(array)
    position = array.join
  end

end
