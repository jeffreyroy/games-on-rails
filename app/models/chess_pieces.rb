require_relative 'piece'

class ChessPiece < Piece
  attr_accessor :color, :player
  ICON = [" ", " "]   # Icon represented in unicode
  VALUE = 0  # Value of piece
  # Array used to calculate value of piece dynamically,
  # based on location
  CENTRALIZATION = [
    [1, 1, 1, 2, 2, 1, 1, 1],
    [1, 2, 2, 2, 2, 2, 2, 1],
    [1, 2, 3, 3, 3, 3, 2, 1],
    [1, 2, 3, 4, 4, 3, 2, 1],
    [1, 2, 3, 4, 4, 3, 2, 1],
    [1, 2, 3, 3, 3, 3, 2, 1],
    [1, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 2, 2, 1, 1, 1]
  ]

  def initialize(game, location, player)
    # @game = game
    @location = location
    @value = self.class::VALUE
    @icon = self.class::ICON
    @player = player
  end

  def value
    @value * 10 + self.class::CENTRALIZATION[@location[0]][@location[1]]
  end

  def icon
    @player == :human ? @icon[0] : @icon[1]
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
    # icon1 = self.icon 
    # icon2 = piece_icon(position, location)
    # # Check to see whether both icons have same case
    # (icon1 == icon1.upcase) == (icon2 == icon2.upcase)
    state[:pieces][@player].find { |piece| piece.location == location }
  end

  # Check whether destination is on the board
  def inbounds(destination)
    row = destination[0]
    column = destination[1]
    row >= 0 && row <= 7 && column >= 0 && column <= 7
  end

  def legal_destination(state, destination)
    inbounds(destination) && (empty_space?(state[:position], destination) || !same_owner(state, destination))
  end

end



class StraightMover < ChessPiece
  ICON = ["\u2656", "\u265C"]
  VALUE = 5
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]]


  def legal_moves(state)
    position = state[:position]
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Loop over directions
    self.class::DIRECTIONS.each do |direction|
      row_inc = direction[0]
      col_inc = direction[1]
      row = @location[0] + row_inc
      column = @location[1] + col_inc
      destination = [row, column]
      #  Move along this direction as long as spaces are empty
      while inbounds(destination) && empty_space?(position, destination) 
        move_list << [@location, destination]
        row += row_inc
        column += col_inc
        destination = [row, column]
      end
      # If next space is inbounds (i.e. occupied) add as capture
      if inbounds(destination) && !same_owner(state, destination)
        move_list << [@location, destination]
      end
    end
    # Return move list
    move_list
  end
end



class Rook < StraightMover
  # Icon represented in unicode
  ICON = ["\u2656", "\u265C"]
  VALUE = 5
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]]
end

class Bishop < StraightMover
  ICON = ["\u2657", "\u265D"]
  VALUE = 3
  DIRECTIONS = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
end

class Queen < StraightMover
  ICON = ["\u2655", "\u265B"]
  VALUE = 9
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
end

class ChessKing < ChessPiece
  ICON = ["\u2654", "\u265A"]
  VALUE = 50
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
  def legal_moves(state)
    position = state[:position]
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Loop over directions
    self.class::DIRECTIONS.each do |direction|
      row_inc = direction[0]
      col_inc = direction[1]
      row = @location[0] + row_inc
      column = @location[1] + col_inc
      destination = [row, column]
      # If destination empty or occupied by opponent, add as move
      if legal_destination(state, destination)
        move_list << [@location, destination]
      end
    end
    # Castling not yet implemented
    # Return move list
    move_list
  end
end

class Knight < ChessPiece
  ICON = ["\u2658", "\u265E"]
  VALUE = 3
  DIRECTIONS = [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, -1], [-2, 1]]
  def legal_moves(state)
    position = state[:position]
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Loop over directions
    self.class::DIRECTIONS.each do |direction|
      row_inc = direction[0]
      col_inc = direction[1]
      row = @location[0] + row_inc
      column = @location[1] + col_inc
      destination = [row, column]
      # If destination empty or occupied by opponent, add as move
      if legal_destination(state, destination)
        move_list << [@location, destination]
      end
    end
    # Return move list
    move_list
  end
end


class Pawn < ChessPiece
  ICON = ["\u2659", "\u265F"]
  VALUE = 1

  def direction
    @player == :human ? -1 : 1
  end

  def start_row
    @player == :human ? 6 : 1
  end

  def legal_moves(state)
    position = state[:position]
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Add forward move
    # (Promotion not yet implemented)
    destination = [@location[0] + direction, @location[1]]
    if inbounds(destination) && empty_space?(position, destination)
      move_list << [@location, destination]
    end
    # if on starting square, add move two spaces forward
    destination = [@location[0] + 2 * direction, @location[1]]
    intermediate = [@location[0] + direction, @location[1]]
    if @location[0] == start_row && empty_space?(position, destination) && empty_space?(position, intermediate)
      move_list << [@location, destination]
    end
    # Add captures
    capture_directions = [[direction, 1], [direction, -1]]
    # Loop over directions for capture
    capture_directions.each do |d|
      destination = [@location[0] + d[0], @location[1] + d[1]]
      # If position occupied by opponent, add to move list
      if inbounds(destination) && !empty_space?(position, destination) && !same_owner(state, destination)
        move_list << [@location, destination]
      end
    end
    # (En passant capture no yet implemented)
    # Return move list
    move_list
  end
end