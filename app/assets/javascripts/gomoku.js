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
    gameBoard.addPiece(cell.id, bk);

  };


  // Submit player move to server and get AI response
  var submitMove = function(from, to, cont) {
    data = { from: [from[1], from[0]], to: [to[1], to[0]] };
    // Perform Ajax call to submit move to server
    var done = false;
      $.ajax({
        method: "post",
        url: "annuvin/drop",
        data: { move: data, cont: cont }
      })
      .done(function(response){
        console.log(response);
        move = response.move;
        cont = response.cont;
        // Check whether it is the computer's move
        if(move[0][0] != -1) {
          // Make computer move
          from = gameBoard.cellByCoordinates(move[0][1], move[0][0]);
          to = gameBoard.cellByCoordinates(move[1][1], move[1][0]);
          updateBlurb("I move from " + from.id + " to " + to.id + ".");
          piece = from.firstChild;
          movePiece(piece, to);
          // Continue making additional moves for computer if possible
          if(cont) {
            submitMove(from, to, true);
          }
        }
        // Check to see whether either player has won
        checkForWin();
      })
      .fail(function(response){
        alert("Can't make that move!");
      })

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
  gameBoard.addPiece("G9", bk);



}
