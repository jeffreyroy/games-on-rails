require_relative 'piece'

class CheckersPiece < Piece
  attr_reader :value
  attr_accessor :color, :player
  ICON = "OX"
  VALUE = 0

  def initialize(game, location, player)
    # @game = game 
    @location = location
    @value = self.class::VALUE
    @icon = self.class::ICON
    @player = player
  end

  def icon
    @player == :human ? @icon[0] : @icon[1]
  end

  def inbounds(destination)
    row = destination[0]
    column = destination[1]
    row >= 0 && row <= 7 && column >= 0 && column <= 7
  end

  def directions
    # Fill this in
  end

  # Return icon of piece at location
  def piece_icon(position, location)
    position[location[0]][location[1]]
  end

  # Return true if location in position is empty
  def empty_space?(position, location)
    piece_icon(position, location) == "."
  end

  # Check whether piece at destination is owned by same player
  # as moving piece
  def same_owner(state, location)
    state[:pieces][@player].find { |piece| piece.location == location }
  end

  def generate_moves(state)
    position = state[:position]
    move_list = []
    directions.each do |d|
      destination = [@location[0] + d[0], @location[1] + d[1]]
      if inbounds(destination)
        # If position empty, add to move list
        if empty_space?(position, destination)
          move_list << [@location, destination]
        end
      end
    end
    move_list
  end

  def generate_captures(state)
    position = state[:position]
    move_list = []
    directions.each do |d|
      destination = [@location[0] + d[0], @location[1] + d[1]]
      if inbounds(destination)
        # Check to see whether adjacent space is occupied by opponent
        if !empty_space?(position, destination) && !same_owner(state, destination)
          # If occupied by opponent, verify that next space is empty
          capture_destination = [destination[0] + d[0], destination[1] + d[1]]
          if inbounds(capture_destination) && empty_space?(position, capture_destination)
            move_list << [@location, capture_destination]
          end
        end
      end
    end
    move_list
  end

  # Generate set of legal moves given game state
  def legal_moves(state)
    # puts "Generating moves for piece at #{@location}..."
    position = state[:position]
    move_list = []
    # Check whether in the middle of a series of captures
    if state[:moving_piece]
      if state[:moving_piece] != @location
        return []
      end
      # Add captures only
      move_list += generate_captures(state)
    else
      # Add both normal moves and captures
      move_list += generate_moves(state)
      move_list += generate_captures(state)
    end
    # (En passant capture no yet implemented)
    # Return move list
    move_list
  end

end

class Man < CheckersPiece
  # ICON = ["\u26C0", "\u26C2"]
  ICON = ["\u2659", "\u265F"]
  VALUE = 1

  def directions
    direction = (@player == :human ? -1 : 1)
    [[direction, 1], [direction, -1]]
  end

end

class King < CheckersPiece
  # ICON = ["\u26C1", "\u26C3"]
  ICON = ["\u2654", "\u265A"]
  VALUE = 2

  def directions
    [[1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end