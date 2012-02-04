module "View"
test "createBoard", () ->
  createBoard(8,8)
  ok(document.getElementById("cell_88"))
  ok(document.getElementById("cell_18"))
  ok(document.getElementById("cell_81"))
  ok(document.getElementById("cell_11"))
  ok(document.getElementById("cell_55"))
