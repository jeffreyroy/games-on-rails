function Grid(name, columns, rows, cellWidth, cellHeight, left, top) {
  this.name = name;  // Must be unique
  this.columns = columns;
  this.rows = rows;
  this.cellWidth = cellWidth;
  this.cellHeight = cellHeight;
  this.left = left;
  this.top = top;
  this.activePiece = null;
  this.LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
}

// Create style tag to position grid
// left, top indicate the location of the upper left corner
Grid.prototype.appendStyle = function() {
  var gridStyle = document.createElement("style");
  gridStyle.type = "text/css";
  var styleText = "#" + this.name + " { ";
  styleText += "position: absolute; ";
  styleText += "left: " + this.left + "px; ";
  styleText += "top: " + this.top + "px; ";
  styleText += " }";
  // Append style to head of document
  var styleNode = document.createTextNode(styleText);
  gridStyle.appendChild(styleNode);
  document.getElementsByTagName('head')[0].appendChild(gridStyle);
};

// Append table to DOM
// cellWidth, cellHeight are dimensions of table cells
// style can be:
// "normal" = rectangular grid
// "offset" = parallelogram
// "hex" = hexagon
Grid.prototype.appendTable = function(style) {
  // Variables for offset or hex grid
  var threshold = Math.floor(this.rows / 2)
  var upperThreshold = this.rows + this.columns - threshold - 1;
  var offset = 0;
  if(style == "offset" || style == "hex") {
    offset = this.cellWidth / 2;
  }

  // Create table
  var newTable = document.createElement("div");
  newTable.setAttribute("id", this.name);
  newTable.setAttribute("class", "grid");
  // Append table entries
  for(var row=0; row < this.rows; row ++) {
    // var currentRow = document.createElement("tr");
    for(var column=0; column < this.columns; column ++) {
      // cut off corners if hex grid
      if( style != "hex" ||
        (row + column >= threshold && row + column < upperThreshold)){
        var leftEdge = this.left + column * this.cellWidth + row * offset;
        var topEdge = this.top + row * this.cellHeight;
        var cellId = this.getCellId(row, column)
        var newCell = this.addCell(leftEdge, topEdge, cellId);
        newTable.appendChild(newCell);   
      }
    }
    // newTable.appendChild(currentRow);
  }
  // Add event listeners to table
  // Requires game.js
  newTable.addEventListener("click", game.click.bind(this));
  newTable.addEventListener("drop", game.drop.bind(this));
  newTable.addEventListener("dragover", game.dragover.bind(this));
  // Append table to body of document
  document.body.appendChild(newTable);
};

// Generate Grid cell
Grid.prototype.addCell = function(leftEdge, topEdge, cellId) {
  // Create div
  var currentCell = document.createElement("div");
  // console.log(leftEdge + " " + topEdge);
  currentCell.setAttribute("class", this.name);
  currentCell.setAttribute("id", cellId);
  // Set dimensions of Cell
  currentCell.style.height = this.cellHeight + "px";
  currentCell.style.width = this.cellWidth + "px";
  currentCell.style.position = "absolute";
  currentCell.style.left = leftEdge + "px";
  currentCell.style.top = topEdge + "px";
  // currentCell.appendChild(currentDiv);
  return currentCell;
}

// Get unique cell id using row and column
Grid.prototype.getCellId = function(row, column) {
  var letter = this.LETTERS[column];
  var number = this.rows - row;
  return letter + number;
}


// Class method to generate Grid and place it on the DOM
Grid.generate = function(name, left, top, columns, rows, cellWidth, cellHeight) {
  newGrid = new Grid(name, columns, rows, cellWidth, cellHeight, left, top);
  newGrid.appendStyle();
  newGrid.appendTable("normal");
  return newGrid
};

// Class method to generate Grid and place it on the DOM
Grid.generateOffset = function(name, left, top, columns, rows, cellWidth, cellHeight) {
  newGrid = new Grid(name, columns, rows, cellWidth, cellHeight, left, top);
  newGrid.appendStyle();
  newGrid.appendTable("offset");
  return newGrid
};

// Class method to generate Grid and place it on the DOM
Grid.generateHex = function(name, left, top, columns, rows, cellWidth, cellHeight) {
  newGrid = new Grid(name, columns, rows, cellWidth, cellHeight, left, top);
  newGrid.appendStyle();
  newGrid.appendTable("hex");
  return newGrid
};


// List of cells in grid
Grid.prototype.cellList = function() {
  return document.getElementsByClassName(this.name);
};

// Returns main table element
Grid.prototype.tableElement = function() {
  return document.getElementById(this.name);
};

// Returns true if the Grid contains the specified element
Grid.prototype.contains = function(element) {
  return this.tableElement().contains(element);
};

// Returns first empty cell in Grid
Grid.prototype.firstEmptyCell = function() {
  var cellList = this.cellList();
  // Does this not work in Chrome?
  // return cellList.find(cellEmpty);
  for(var i in cellList) {
    if(cellEmpty(cellList[i])) {
      return cellList[i];
    }
  }
  return null;
};

// Returns true if Grid contains no pieces
Grid.prototype.empty = function() {
  // for(var row=0; row < this.rows; row ++) {
  //   for(var column=0; column < this.columns; column ++) {
  //     currentCell = this.cellByCoordinates(column, row);
  //     if(!cellEmpty(currentCell)) { return false; }
  //   }
  // }
  var cellList = this.cellList();
  for(var i in cellList) {
    if(!cellEmpty(cellList[i])) {
      return false;
    }
  }
  return true;
};

// Finds cell in Grid by id
Grid.prototype.cellById = function(id) {
  return document.getElementById(id);
};

// Finds cell in Grid given column and row
Grid.prototype.cellByCoordinates = function(column, row) {
  return this.cellById(this.getCellId(row, column));
};

// Finds coordinates for cell
Grid.prototype.coordinates = function(cell) {
  var id = cell.id;
  var letter = id[0];
  var number = parseInt(id.slice(1, id.length));
  var row = this.rows - number;
  var column = this.LETTERS.indexOf(letter);
  return [column, row]
};

// Finds pieces in Grid by class
Grid.prototype.pieceByClass = function(className) {
  return document.getElementsByClassName(className);
};

// Helper functions for using cells
var cellEmpty = function(cell) {
  return cell.firstChild == null;
};

var clearCell = function(cell) {
 while(cell.firstChild) {
  cell.removeChild(cell.firstChild);
 }
};
 
var movePiece = function(pieceImage, destinationCell) {
  clearCell(destinationCell);
  destinationCell.appendChild(pieceImage);
};

// 3. Functions to add pieces to the Grid
// A piece can be either clickable or draggable, but not both
// The library pieces.js is required to get piece data

// Grid.prototype.addPiece = function(cellId, piece) {
//     cell = document.getElementById(cellId);
//     var src = this.imagePath + piece.image;
//     var imageNode = document.createElement("img");
//     imageNode.setAttribute("src", src);
//     imageNode.setAttribute("id", piece.id);
//     imageNode.setAttribute("class", "piece");
//     cell.appendChild(imageNode);
// }

// Add piece to board and return it
Grid.prototype.addPiece = function(cellId, piece) {
    cell = document.getElementById(cellId);
    // var src = piece.image;
    // var imageNode = document.createElement("img");
    // imageNode.setAttribute("src", image_tag(src));
    // imageNode.setAttribute("id", piece.id);
    // imageNode.setAttribute("class", "piece");
    // cell.appendChild(imageNode);
    clearCell(cell);
    cell.appendChild(piece.imageTag());
    return cell.firstChild;
}

Grid.prototype.addDraggablePiece = function(cellId, piece) {
    pieceNode = this.addPiece(cellId, piece);
    // pieceNode = document.getElementById(piece.id);
    pieceNode.addEventListener("dragstart", game.dragstart.bind(piece));
}

Grid.prototype.addClickablePiece = function(cellId, piece) {
    pieceNode = this.addPiece(cellId, piece);
    // pieceNode = document.getElementById(piece.id);
    pieceNode.addEventListener("click", game.click.bind(piece));

}




