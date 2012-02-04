darkCell = "#8B7355"
lightCell = "#FFD39B"

buildCell = (row, i, j) ->
  cell = row.insertCell(-1)
  cell.setAttribute("id", "cell_" + j + i)
  cell.setAttribute("width", "80")
  cell.setAttribute("height", "80")
  value = if (j % 2) != (i % 2) then darkCell else lightCell
  cell.setAttribute("style", "background-color:" + value)

buildRow = (table, cols, i) ->
  row = table.insertRow(-1)
  buildCell(row, i, j) for j in [1..cols]

createBoard = (rows, cols) ->
  table = document.createElement("table")
  table.setAttribute("id", "board")
  table.setAttribute("border", "0")
  table.setAttribute("cellpadding", "0")
  table.setAttribute("cellspacing", "1")
  table.setAttribute("style", "background-color:black")
  buildRow(table, cols, i) for i in [rows..1]
  document.documentElement.appendChild(table)

setPiece = (color, piece, row, col) ->
  pos = document.getElementById("cell_" + col + row)
  img = document.createElement("img")
  img.setAttribute("src", "img/" + color + "/" + piece + ".svg")
  img.setAttribute("width", pos.getAttribute("width"))
  img.setAttribute("height", pos.getAttribute("height"))
  pos.appendChild(img)

removePiece = (row, col) ->
  pos = document.getElementById("cell_" + col + row)
  pos.removeChild(pos.firstChild)

#createBoard(8,8)
#setPiece('red', 'rook', 8, 3)
#setPiece('green', 'king', 2, 7)
#removePiece(8, 3)
