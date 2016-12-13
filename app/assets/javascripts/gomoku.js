$('#gomoku').ready(function() {

  runGame();
  
});

// Update message beneath board
var updateBlurb = function(string) {
  blurb = document.getElementById("blurb");
  blurb.innerHTML = string;
}

var runGame = function() {
  game = new Game();

  // Handle click on piece or grid
  game.click = function(event) {
    var cell = event.target;
    var move = gameBoard.coordinates(cell);
    gameBoard.addPiece(cell.id, wk);
    updateBlurb("Thinking...");
    submitMove(move);

  };


  // Submit player move to server and get AI response
  var submitMove = function(move) {
    data = [move[1], move[0]];
    // Perform Ajax call to submit move to server
    var done = false;
      $.ajax({
        method: "post",
        url: "gomoku/drop",
        data: { move: data }
      })
      .done(function(response){
        computerMove(response)
      })
      .fail(function(response){
        alert("Can't make that move!");
      })
  }

  var computerMove = function(response) {
    console.log(response);
    move = response.move;
    winner = response.winner;
    if(winner == "player") {
      updateBlurb("You win!");
    }
    else {
      // Make computer move
      destination = gameBoard.cellByCoordinates(move[1], move[0]);
      gameBoard.addPiece(destination.id, bk);
      // Check to see whether computer has won
      if(winner == "computer") {
        updateBlurb("I win!")
      }
      else {
        updateBlurb("I move to " + destination.id + ".");
      }
    }
  }

  var location = function(cell) {
    console.log("location = " + gameBoard.coordinates(cell))
    return gameBoard.coordinates(cell);
  }

  // Check for a win
  var checkForWin = function() {

  }

  var lost = function(pieceClass) {
    return gameBoard.pieceByClass(pieceClass).length == 0;
  }

  // Create game board

  gameBoard = Grid.generate("board", 5, 5, 19, 19, 20, 20);
  bk = new Piece("black king", "BlackG");
  wk = new Piece("white king", "WhiteG");
  gameBoard.addPiece("J10", bk);



}
