module "View"
test "createBoard", () ->
  createBoard(8,8)
  ok(document.getElementById("cell_88"))
  ok(document.getElementById("cell_18"))
  ok(document.getElementById("cell_81"))
  ok(document.getElementById("cell_11"))
  ok(document.getElementById("cell_55"))

test "setPiece", () ->
  #createBoard(8,8)
  setPiece('red', 'rook', 8, 3)
  img = document.getElementById("cell_38").childNodes[0]
  equal(img.getAttribute("src"), "img/red/rook.svg")
  setPiece('green', 'king', 2, 7)
  img = document.getElementById("cell_72").childNodes[0]
  equal(img.getAttribute("src"), "img/green/king.svg")

test "removePiece", () ->
  #createBoard(8,8)
  setPiece('blue', 'pawn', 2, 1)
  img = document.getElementById("cell_12").childNodes[0]
  equal(img.getAttribute("src"), "img/blue/pawn.svg")
  removePiece(2, 1)
  img = document.getElementById("cell_12").childNodes[0]
  equal(img, null)
