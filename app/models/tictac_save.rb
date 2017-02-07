class TictacSave < ApplicationRecord
  def position_array=(array)
    position = array.join
  end
end
