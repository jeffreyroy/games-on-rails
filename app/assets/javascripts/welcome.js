$(document).ready(function() {

  runGame();
  
});

var updateBlurb = function(string) {
  blurb = document.getElementById("blurb");
  blurb.innerHTML = string;
}

var runGame = function() {
  game = new Game();

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
    if(event.target.id == "BlackK") {
      clickPiece(cell);
    }
    else {
      clickCell(cell);
    }
  };

  var clickPiece = function(piece) { 
    console.log("clicked on piece " + piece.id);
    var loc = location(piece);
    // Convert to smaller board used by server
    loc[1] -= 2;
    data = { move: [loc[1], loc[0]] };
    if(game.activePiece == piece) {
      game.activePiece = null;
      unHighlightTargets(piece);
    }
    else {
      game.activePiece = piece;
      highlightTargets(piece);
    }

  }

  // get list of valid targets from server
  highlightTargets = function(piece) {
    var loc = location(piece.parentElement);
    // Convert to smaller board used by server
    loc[1] -= 2;

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
        target = gameBoard.cellByCoordinates(targetList[i][1], targetList[i][0] + 2);
        target.classList.add("highlight");
      }
    })
    .fail(function(response){
      alert("Can't get move for that piece!");
    })
  }

  // Remove all highlighting from game board
  var unHighlightTargets = function(piece) {
    var targetList = document.getElementsByClassName("highlight");
    while(targetList.length > 0) {
      target = targetList[0];
      target.classList.remove("highlight");
    }
  }

  var clickCell = function(cell) { 
    if(cell.id == "WhiteK") { cell = cell.parentElement };
    console.log("clicked on cell " + cell.id);
    piece = game.activePiece;
    // Make sure a piece is ready to move
    if(piece && cell.classList.contains("highlight")) {
      var from = location(piece.parentElement);
      var to = location(cell);
      // Convert to smaller board
      from[1] -= 2;
      to[1] -= 2;
      data = { from: [from[1], from[0]], to: [to[1], to[0]] };
      console.log("You seem to be moving from " + data.from + " to " + data.to);
      updateBlurb("Thinking...");
      unHighlightTargets(piece);
      movePiece(piece, cell);
      game.activePiece = null;
      // Perform Ajax call to submit move to server
      submitMove(data)
    }
  }

  var submitMove = function(moveData) {
      // Perform Ajax call to submit move to server
      $.ajax({
        method: "post",
        url: "annuvin/drop",
        data: moveData
      })
      .done(function(response){
        console.log("Response: " + response);
        move = response.move;
        from = gameBoard.cellByCoordinates(move[0][1], move[0][0] + 2);
        to = gameBoard.cellByCoordinates(move[1][1], move[1][0] + 2);
        updateBlurb("I move from " + from.id + " to " + to.id + ".");
        piece = from.firstChild;
        movePiece(piece, to);

      })
      .fail(function(response){
        alert("Can't make that move!");
      })

  }

  var location = function(cell) {
    console.log("location = " + gameBoard.coordinates(cell))
    return gameBoard.coordinates(cell);
  }



  game.dragstart = function(event) {
    // game.activePiece = this;
    // event.dataTransfer.setData("text", event.target.id);
    var piece = event.target;
    clickPiece(piece);
  };

  game.dragover = function(event) {
    var cell = event.target;
    if(cell.classList.contains("highlight")) {
      event.preventDefault();
    }
  };

  // This is run when user tries to drop a piece
  game.drop = function(event) {
    var cell = event.target;
    var piece = game.activePiece;
    unHighlightTargets(piece);
    cell.appendChild(piece);
  };

  // Create game board

  gameBoard = Grid.generateHex("board", -25, 16, 7, 7, 50, 42);
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


  // gameBoard.tableElement().addEventListener("click", gameBoard.click);

  var a = gameBoard.cellById("A1");
  var b = gameBoard.cellById("BlackK").parentElement;

  console.log(b);

}
