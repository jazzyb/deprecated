(function() {
  var create_board, dark, light;

  dark = "#8B7355";

  light = "#FFD39B";

  create_board = function(rows, cols) {
    var col, row, table;
    table = "<table style='background-color:black' border='0' cellpadding='0' cellspacing='1'>";
    for (row = rows; rows <= 1 ? row <= 1 : row >= 1; rows <= 1 ? row++ : row--) {
      table += "<tr>";
      for (col = 1; 1 <= cols ? col <= cols : col >= cols; 1 <= cols ? col++ : col--) {
        table += "<td id='" + col + row + "' ";
        table += "width='80' height='80' style='background-color:";
        if ((col % 2) !== (row % 2)) {
          table += dark;
        } else {
          table += light;
        }
        table += "'></td>";
      }
      table += "</tr>";
    }
    table += "</table>";
    return document.write(table);
  };

  create_board(8, 8);

}).call(this);
