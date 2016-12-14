
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