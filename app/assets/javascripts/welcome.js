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
    if(event.target.tagName == "IMG") {
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
    data = { move: loc };
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
    data = { move: loc };
    console.log(data);
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
        target = gameBoard.cellByCoordinates(targetList[i][0], targetList[i][1] + 2);
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
    console.log("clicked on cell " + event.target.id);
    var loc = location(cell);
    piece = game.activePiece;
    // Make sure a piece is ready to move
    if(piece && cell.classList.contains("highlight")) {
      loc[1] -= 2;
      data = { move: loc };
      console.log(data);
      updateBlurb("Thinking...");
      unHighlightTargets(piece);
      cell.appendChild(piece);
      game.activePiece = null;
      // Perform Ajax call to submit move to server
      $.ajax({
        method: "post",
        url: "annuvin/drop",
        data: data
      })
      .done(function(response){
        console.log(response);
        updateBlurb("I move " + response.move);
      })
      .fail(function(response){
        alert("Can't make that move!");
      })

    }
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



  // validTargets = function(piece) {
  //   var targetList = [];
  //   var cell = piece.parentElement;
  //   var coordinates = gameBoard.coordinates(cell);
  //   for(i in DIRECTIONS) {
  //     dir = DIRECTIONS[i];
  //     var x = coordinates[0] + dir[0];
  //     var y = coordinates[1] + dir[1];
  //     var nextCell = gameBoard.cellByCoordinates(x, y);
  //     if(nextCell) {
  //       targetList.push(nextCell);
  //     }
  //   }
  //   return targetList;
  // }

  // Create game board

  gameBoard = Grid.generateHex("board", -25, 16, 7, 7, 50, 42);
  king = new Piece("black king", "BlackK");
  gameBoard.addDraggablePiece("A1", king);


  // gameBoard.tableElement().addEventListener("click", gameBoard.click);

  var a = gameBoard.cellById("A1");
  var b = gameBoard.cellById("BlackK").parentElement;

  console.log(b);

}
