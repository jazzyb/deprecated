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
  equal(img.getAttribute("src"), imageFile('red', 'rook'))
  setPiece('green', 'king', 2, 7)
  img = document.getElementById("cell_72").childNodes[0]
  equal(img.getAttribute("src"), imageFile('green', 'king'))

test "removePiece", () ->
  #createBoard(8,8)
  setPiece('blue', 'pawn', 2, 1)
  img = document.getElementById("cell_12").childNodes[0]
  equal(img.getAttribute("src"), imageFile('blue', 'pawn'))
  removePiece(2, 1)
  img = document.getElementById("cell_12").childNodes[0]
  equal(img, null)

test "changeColors", () ->
  #createBoard(8,8)
  setPiece('white', 'knight', 1, 1)
  setPiece('white', 'knight', 2, 1)
  setPiece('white', 'knight', 3, 1)
  setPiece('white', 'knight', 4, 1)
  setPiece('pink', 'knight', 5, 1)
  changeColors('white', 'black')
  img = document.getElementById("cell_11").firstChild
  equal(img.getAttribute("src"), imageFile('black', 'knight'))
  img = document.getElementById("cell_12").firstChild
  equal(img.getAttribute("src"), imageFile('black', 'knight'))
  img = document.getElementById("cell_13").firstChild
  equal(img.getAttribute("src"), imageFile('black', 'knight'))
  img = document.getElementById("cell_14").firstChild
  equal(img.getAttribute("src"), imageFile('black', 'knight'))
  img = document.getElementById("cell_15").firstChild
  equal(img.getAttribute("src"), imageFile('pink', 'knight'))
