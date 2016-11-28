game = new Game();

const DIRECTIONS = {
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
  if(game.activePiece == piece) {
    game.activePiece = null;
    unHighlightTargets(piece);
  }
  else {
    game.activePiece = piece;
    highlightTargets(piece);
  }
}

var highlightTargets = function(piece) {
  var targetList = validTargets(piece);
  for(i in targetList) {
    target = targetList[i];
    target.classList.add("highlight");
  }
}

var unHighlightTargets = function(piece) {
  var targetList = validTargets(piece);
  for(i in targetList) {
    target = targetList[i];
    target.classList.remove("highlight");
  }
}

var clickCell = function(cell) { 
  console.log("clicked on cell " + event.target.id);
  piece = game.activePiece;
  if(piece && cell.classList.contains("highlight")) {
    unHighlightTargets(piece);
    cell.appendChild(piece);
    game.activePiece = null;
  }
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

validTargets = function(piece) {
  var targetList = [];
  var cell = piece.parentElement;
  var coordinates = gameBoard.coordinates(cell);
  for(i in DIRECTIONS) {
    dir = DIRECTIONS[i];
    var x = coordinates[0] + dir[0];
    var y = coordinates[1] + dir[1];
    var nextCell = gameBoard.cellByCoordinates(x, y);
    if(nextCell) {
      targetList.push(nextCell);
    }
  }
  return targetList;
}

// Create game board

gameBoard = Grid.generateHex("board", -25, 16, 7, 7, 50, 42);
king = new Piece("black king", "BlackK");
gameBoard.addDraggablePiece("A1", king);


// gameBoard.tableElement().addEventListener("click", gameBoard.click);

var a = gameBoard.cellById("A1");
var b = gameBoard.cellById("BlackK").parentElement;

console.log(b);
