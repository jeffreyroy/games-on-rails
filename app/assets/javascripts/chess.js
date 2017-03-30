// Page-specific ready function
$('#chess').ready(function() {

  chess();
  
});

var chess = function() {
  game = new Game();

  // Handle click on piece or grid
  // Need to check whether clicking on white or black piece
  // Handle click on piece or grid
  game.click = function(event) {
    var cell = event.target;
    if(event.target.classList.contains("white")) {
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
      url: "chess/click",
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

  // Add queen of same color as promoting pawn
  var addQueen = function(piece, coordinates) {
    var cellId = gameBoard.getCellId(coordinates[1], coordinates[0]);
    console.log(piece.classList);
    if(piece.classList.contains("white")) {
      gameBoard.addDraggablePiece(cellId, wq);
    }
    else {
      gameBoard.addDraggablePiece(cellId, bq);
    }
  }

  // Custom method to move piece, allowing for captures and kings
  var movePiece = function(pieceImage, destinationCell) {
    var from = location(pieceImage.parentElement);
    var to = location(destinationCell);
    console.log("Moving from " + pieceImage.parentElement.id + " to " + destinationCell.id );
    // Move piece to destination
    clearCell(destinationCell);
    // If at end of board, promote pawn
    if(pieceImage.classList.contains("pawn") &&
      (to[1] == 0 || to[1] == 7)) {
      addQueen(pieceImage, to);
      clearCell(pieceImage.parentElement);
    }
    else {
      destinationCell.appendChild(pieceImage);
    }
    // Move rook to complete castling
    if(pieceImage.classList.contains("king") &&
      Math.abs(from[0] - to[0]) == 2) {
      completeCastling(to);
    }

  };

  // Complete castling
  var completeCastling = function(kingLocation) {
    var column = kingLocation[0] == 6 ? 7 : 0;
    var row = kingLocation[1];
    console.log("Moving rook at column " + column);
    var rookCell = gameBoard.cellByCoordinates(column, row);
    var rook = rookCell.firstChild;
    var newColumn = column == 7 ? 5 : 3;
    var rookDestination = gameBoard.cellByCoordinates(newColumn, row);
    rookDestination.appendChild(rook);
  }

  // Handle click on empty cell
  var clickCell = function(cell) { 
    if(cell.classList.contains("black")) { cell = cell.parentElement };
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
        url: "chess/drop",
        data: { move: data, cont: cont }
      })
      .done(function(response){
        console.log(response);
        var move = response.move;
        // Check whether it is the computer's move
        if(move[0][0] != -1) {
          // Make computer move
          from = gameBoard.cellByCoordinates(move[0][1], move[0][0]);
          to = gameBoard.cellByCoordinates(move[1][1], move[1][0]);
          updateBlurb("I move from " + from.id + " to " + to.id + ".");
          piece = from.firstChild;
          movePiece(piece, to);

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
    if(lost("white-king")) { updateBlurb("I win!"); }
    if(lost("black-king")) { updateBlurb("You win!"); }
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

  gameBoard = Grid.generate("board", 23, 25, 8, 8, 90, 90);
  bp = new Piece("black pawn", "black-pawn");
  wp = new Piece("white pawn", "white-pawn");
  bk = new Piece("black king", "black-king");
  wk = new Piece("white king", "white-king");
  bq = new Piece("black queen", "black-queen");
  wq = new Piece("white queen", "white-queen");
  br = new Piece("black rook", "black-rook");
  wr = new Piece("white rook", "white-rook");
  bb = new Piece("black bishop", "black-bishop");
  wb = new Piece("white bishop", "white-bishop");
  bn = new Piece("black knight", "black-knight");
  wn = new Piece("white knight", "white-knight");
  gameBoard.addDraggablePiece("A2", wp);
  gameBoard.addDraggablePiece("B2", wp);
  gameBoard.addDraggablePiece("C2", wp);
  gameBoard.addDraggablePiece("D2", wp);
  gameBoard.addDraggablePiece("E2", wp);
  gameBoard.addDraggablePiece("F2", wp);
  gameBoard.addDraggablePiece("G2", wp);
  gameBoard.addDraggablePiece("H2", wp);
  gameBoard.addDraggablePiece("A7", bp);
  gameBoard.addDraggablePiece("B7", bp);
  gameBoard.addDraggablePiece("C7", bp);
  gameBoard.addDraggablePiece("D7", bp);
  gameBoard.addDraggablePiece("E7", bp);
  gameBoard.addDraggablePiece("F7", bp);
  gameBoard.addDraggablePiece("G7", bp);
  gameBoard.addDraggablePiece("H7", bp);

  gameBoard.addDraggablePiece("A1", wr);
  gameBoard.addDraggablePiece("B1", wn);
  gameBoard.addDraggablePiece("C1", wb);
  gameBoard.addDraggablePiece("D1", wq);
  gameBoard.addDraggablePiece("E1", wk);
  gameBoard.addDraggablePiece("F1", wb);
  gameBoard.addDraggablePiece("G1", wn);
  gameBoard.addDraggablePiece("H1", wr);
  gameBoard.addDraggablePiece("A8", br);
  gameBoard.addDraggablePiece("B8", bn);
  gameBoard.addDraggablePiece("C8", bb);
  gameBoard.addDraggablePiece("D8", bq);
  gameBoard.addDraggablePiece("E8", bk);
  gameBoard.addDraggablePiece("F8", bb);
  gameBoard.addDraggablePiece("G8", bn);
  gameBoard.addDraggablePiece("H8", br);



}
