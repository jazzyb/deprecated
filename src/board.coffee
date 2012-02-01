dark = "#8B7355"
light = "#FFD39B"

create_board = (rows, cols) ->
  table = "<table style='background-color:black' border='0' cellpadding='0' cellspacing='1'>"
  for row in [rows..1]
    table += "<tr>"
    for col in [1..cols]
      table += "<td id='" + col + row + "' "
      table += "width='80' height='80' style='background-color:"

      if (col % 2) != (row % 2)
        table += dark
      else
        table += light

      table += "'></td>"
    table += "</tr>"
  table += "</table>"
  document.write(table)

create_board(8,8)
