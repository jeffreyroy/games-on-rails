// Page-specific ready function
$('#checkers').ready(function() {

  checkers();
  
});

var checkers = function() {
  game = new Game();

  // Handle click on piece or grid
  game.click = function(event) {
    var cell = event.target;
    if(event.target.nodeName == "IMG") {
      clickPiece(cell);
    }
    else {
      clickCell(cell);
    }
  };

  // Handle click on a movable piece
  var clickPiece = function(piece) { 
    console.log("clicked on piece " + piece.id);
    var loc = location(piece);
    data = { move: [loc[1], loc[0]] };
    // If clicking on active piece
    if(game.activePiece == piece) {
      // If it's a legal move, submit it
      if(piece.parentElement.classList.contains("highlight")) {

      }
      // Otherwise clear active piece
      else {
        game.activePiece = null;
        unHighlightTargets();
        updateBlurb("Click on a piece to move.");
      }
    }
    // Otherwise, activate piece
    else {
      unHighlightTargets();
      game.activePiece = piece;
      highlightTargets(piece);
      updateBlurb("Click on highlighted space to move.");

    }

  }

  // get list of valid targets from server
  highlightTargets = function(piece) {
    var loc = location(piece.parentElement);
    // // Convert to smaller board used by server
    // loc[1] -= 2;

    data = { move: [loc[1], loc[0]] };
    console.log("That piece seems to be at: " + loc);
    // Perform Ajax call to get list of legal moves from server
    $.ajax({
      method: "post",
      url: "checkers/click",
      data: data
    })
    .done(function(response){
      targetList = response.moves;
      // Highlight targets
      for(var i=0; i<targetList.length; i++) {
        console.log(targetList[i][1]);
        target = gameBoard.cellByCoordinates(targetList[i][1][1], targetList[i][1][0]);
        target.classList.add("highlight");
      }
    })
    .fail(function(response){
      alert("Can't get move for that piece!");
    })
  }

  // Remove all highlighting from game board
  var unHighlightTargets = function() {
    var targetList = document.getElementsByClassName("highlight");
    while(targetList.length > 0) {
      target = targetList[0];
      target.classList.remove("highlight");
    }
  }

  // Add king of same color as given piece
  var addKing = function(piece, coordinates) {
    var cellId = gameBoard.getCellId(coordinates[1], coordinates[0]);
    console.log(piece.classList);
    if(piece.classList.contains("scr") || piece.classList.contains("skr")) {
      gameBoard.addDraggablePiece(cellId, wk);
    }
    else {
      gameBoard.addDraggablePiece(cellId, bk);
    }
  }

  // Custom method to move piece, allowing for captures and kings
  var movePiece = function(pieceImage, destinationCell) {
    var from = location(pieceImage.parentElement);
    var to = location(destinationCell);
    console.log("Moving from " + pieceImage.parentElement.id + " to " + destinationCell.id );
    // Move piece to destination
    clearCell(destinationCell);
    // If at end of board, add king
    if(to[1] == 0 || to[1] == 7) {
      addKing(pieceImage, to);
      clearCell(pieceImage.parentElement);
    }
    else {
      destinationCell.appendChild(pieceImage);
    }
    // Check for capture
    console.log ("from " + from[0] + " to " + to[0])
    var capture = (Math.abs(from[0] - to[0]) == 2)
    if(capture) {
      console.log("That's a capture.");
      // Get square jumped over
      var intX = (from[0] + to[0]) / 2;
      var intY = (from[1] + to[1]) / 2;
      var intCell = gameBoard.cellByCoordinates(intX, intY);
      console.log("Jumped over " + intCell.id)
      // Clear captured piece
      clearCell(intCell);
    }
  };

  // Handle click on empty cell
  var clickCell = function(cell) { 
    // if(cell.classList.nodeName == "IMG") { alert("Space occupied!"); };
    console.log("clicked on cell " + cell.id);
    piece = game.activePiece;
    // Make sure a piece is ready to move
    if(piece && cell.classList.contains("highlight")) {
      var from = location(piece.parentElement);
      var to = location(cell);
      console.log("You seem to be moving from " + from + " to " + to);
      updateBlurb("Thinking...");
      unHighlightTargets();
      movePiece(piece, cell);

      game.activePiece = null;
      // Perform Ajax call to submit move to server
      submitMove(from, to, false);
      // Check to see whether either player has won
      checkForWin();

    }
  }

  // Submit player move to server and get AI response
  // If computer is in middle of series of captures, submit
  // no move, but set cont to true
  var submitMove = function(from, to, cont) {
    var data = { from: [from[1], from[0]], to: [to[1], to[0]] };
    // Perform Ajax call to submit move to server
    console.log("Submitting move " + from + "-" + to)
      $.ajax({
        method: "post",
        url: "checkers/drop",
        data: { move: data, cont: cont }
      })
      .done(function(response){
        console.log(response);
        var move = response.move;
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
            submitMove([-1,-1], [-1,-1], true);
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
    // console.log("location = " + gameBoard.coordinates(cell))
    return gameBoard.coordinates(cell);
  }

  // Check for a win
  var checkForWin = function() {
    if(lost("scb") && lost("skb")) { updateBlurb("I win!"); }
    if(lost("scr") && lost("skr")) { updateBlurb("You win!"); }
  }

  var lost = function(pieceClass) {
    return gameBoard.pieceByClass(pieceClass).length == 0;
  }


  // Functions to allow dragging and dropping
  // (Not used in this game)
  game.dragstart = function(event) {
    // game.activePiece = this;
    // event.dataTransfer.setData("text", event.target.id);
    clickPiece(event.target);
  };

  game.dragover = function(event) {
    var cell = event.target;
    if(cell.classList.nodeName == "IMG") {
      cell = cell.parentElement;
    }
    if(cell.classList.contains("highlight")) {
      event.preventDefault();
    }
  };

  // This is run when user tries to drop a piece
  game.drop = function(event) {
    clickCell(event.target);
  };

  // Create game board

  gameBoard = Grid.generate("board", 31, 31, 8, 8, 68, 68);
  bm = new Piece("black man", "scb");
  wm = new Piece("white man", "scr");
  bk = new Piece("black king", "skb");
  wk = new Piece("white king", "skr");
  gameBoard.addDraggablePiece("A1", bm);
  gameBoard.addDraggablePiece("C1", bm);
  gameBoard.addDraggablePiece("E1", bm);
  gameBoard.addDraggablePiece("G1", bm);
  gameBoard.addDraggablePiece("B2", bm);
  gameBoard.addDraggablePiece("D2", bm);
  gameBoard.addDraggablePiece("F2", bm);
  gameBoard.addDraggablePiece("H2", bm);
  gameBoard.addDraggablePiece("A3", bm);
  gameBoard.addDraggablePiece("C3", bm);
  gameBoard.addDraggablePiece("E3", bm);
  gameBoard.addDraggablePiece("G3", bm);
  gameBoard.addDraggablePiece("B6", wm);
  gameBoard.addDraggablePiece("D6", wm);
  gameBoard.addDraggablePiece("F6", wm);
  gameBoard.addDraggablePiece("H6", wm);
  gameBoard.addDraggablePiece("A7", wm);
  gameBoard.addDraggablePiece("C7", wm);
  gameBoard.addDraggablePiece("E7", wm);
  gameBoard.addDraggablePiece("G7", wm);
  gameBoard.addDraggablePiece("B8", wm);
  gameBoard.addDraggablePiece("D8", wm);
  gameBoard.addDraggablePiece("F8", wm);
  gameBoard.addDraggablePiece("H8", wm);



}
