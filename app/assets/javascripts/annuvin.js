// Page-specific ready function
$('#annuvin').ready(function() {

  annuvin();
  
});

var annuvin = function() {
  game = new Game();

  // Six directions for hex board
  var DIRECTIONS = {
    e: [0, 1],
    w: [0, -1],
    ne: [-1, 1],
    nw: [-1, 0],
    se: [1, 0],
    sw: [1, -1]
  }

  // Handle click on piece or grid
  game.click = function(event) {
    var cell = event.target;
    if(event.target.classList.contains("BlackK")) {
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
      url: "annuvin/click",
      data: data
    })
    .done(function(response){
      targetList = response.moves;
      // Highlight targets
      for(i in targetList) {
        target = gameBoard.cellByCoordinates(targetList[i][1], targetList[i][0]);
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

  // Handle click on empty cell or enemy piece
  var clickCell = function(cell) { 
    if(cell.classList.contains("WhiteK")) { cell = cell.parentElement };
    console.log("clicked on cell " + cell.id);
    piece = game.activePiece;
    // Make sure a piece is ready to move
    if(piece && cell.classList.contains("highlight")) {
      var from = location(piece.parentElement);
      var to = location(cell);
 
      console.log("You seem to be moving from " + data.from + " to " + data.to);
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
    if(lost("BlackK")) { updateBlurb("I win!"); }
    if(lost("WhiteK")) { updateBlurb("You win!"); }
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
    if(cell.classList.contains("WhiteK")) {
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

  gameBoard = Grid.generateHex("board", 0, 16, 5, 5, 50, 42);
  bk = new Piece("black king", "BlackK");
  wk = new Piece("white king", "WhiteK");
  gameBoard.addDraggablePiece("A1", bk);
  gameBoard.addDraggablePiece("B1", bk);
  gameBoard.addDraggablePiece("C1", bk);
  gameBoard.addDraggablePiece("D2", bk);
  gameBoard.addDraggablePiece("B4", wk);
  gameBoard.addDraggablePiece("C5", wk);
  gameBoard.addDraggablePiece("D5", wk);
  gameBoard.addDraggablePiece("E5", wk);


}
