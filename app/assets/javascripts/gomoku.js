$('#gomoku').ready(function() {

  gomoku();
  
});

// Update message beneath board
var updateBlurb = function(string) {
  blurb = document.getElementById("blurb");
  blurb.innerHTML = string;
}

// Update face
var updateFace = function(string) {
  image = $("#" + string);
  blurbImage = $("#blurb-image img");
  if(blurbImage) {
    // Put old face into hidden zone
    $("#blurb-images").append(blurbImage)
  }
  // Put new face in display zone
  $("#blurb-image").append(image);
}

var gomoku = function() {
  game = new Game();

  // Handle click on piece or grid
  game.click = function(event) {
    var cell = event.target;
    if(event.target.classList.contains("piece")) {
      updateBlurb("You can't move there.")
    }
    else {
      var move = gameBoard.coordinates(cell);
      gameBoard.addPiece(cell.id, wk);
      updateBlurb("Thinking...");
      submitMove(move);
    }
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
      updateFace("anguished");
    }
    else {
      // Make computer move
      destination = gameBoard.cellByCoordinates(move[1], move[0]);
      gameBoard.addPiece(destination.id, bk);
      // Check to see whether computer has won
      if(winner == "computer") {
        updateBlurb("I win!");
        updateFace("smiling");
      }
      else {
        updateBlurb("I move to " + destination.id + ".");
        updateFace("neutral");
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
