# Class representing Annuvin state
# For use saving game to database

class AnnuvinSave < ApplicationRecord
  def position_array=(array)
    position = array.join
  end
end
