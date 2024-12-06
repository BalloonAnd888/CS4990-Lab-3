class Wall
{
  PVector start;
  PVector end;
  PVector normal;
  PVector direction;
  float len;

  Wall(PVector start, PVector end)
  {
    this.start = start;
    this.end = end;
    direction = PVector.sub(this.end, this.start);
    len = direction.mag();
    direction.normalize();
    normal = new PVector(-direction.y, direction.x);
  }

  // Return the mid-point of this wall
  PVector center()
  {
    return PVector.mult(PVector.add(start, end), 0.5);
  }

  void draw()
  {
    strokeWeight(3);
    line(start.x, start.y, end.x, end.y);
    if (SHOW_WALL_DIRECTION)
    {
      PVector marker = PVector.add(PVector.mult(start, 0.2), PVector.mult(end, 0.8));
      circle(marker.x, marker.y, 5);
    }
  }

  @Override
    public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;
    Wall other = (Wall) obj;
    return (start.equals(other.start) && end.equals(other.end));
  }

  @Override
    public int hashCode() {
    return start.hashCode() + end.hashCode();
  }
}

class Cell {
  ArrayList<Cell> neighbors;
  ArrayList<Wall> walls;
  boolean visited;
  int x, y;

  public Cell(int x, int y) {
    this.x = x;
    this.y = y;
    visited = false;
    neighbors = new ArrayList<Cell>();
    walls = new ArrayList<Wall>();
  }

  void addNeighbor(Cell neighbor) {
    neighbors.add(neighbor);
  }

  public boolean getVisit() {
    return this.visited;
  }

  void setVisit() {
    this.visited = true;
  }

  void draw() {
    stroke(255);
    strokeWeight(3);
  }
}

class Map
{
  ArrayList<ArrayList<Cell>> grid;
  ArrayList<Wall> walls;
  ArrayList<Wall> frontier;
  HashMap<Wall, ArrayList<Cell>> wallCell;

  Map()
  {
    grid = new ArrayList<ArrayList<Cell>>();
    walls = new ArrayList<Wall>();
    frontier = new ArrayList<Wall>();
    wallCell = new HashMap<Wall, ArrayList<Cell>>();
  }

  void generate(int which)
  {
    walls.clear();
    grid.clear();
    frontier.clear();

    System.out.println("Generate");

    System.out.println("Width: " + width);
    System.out.println("Height: " + height);

    int cols = width / GRID_SIZE;
    int rows = height / GRID_SIZE;

    System.out.println("Cols: " + cols);
    System.out.println("Rows: " + rows);

    for (int x = 0; x < rows; x++) {
      ArrayList<Cell> row = new ArrayList<Cell>();
      for (int y = 0; y < cols; y++) {
        row.add(new Cell(x, y));
      }
      grid.add(row);
    }

    // Add neighbors
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        Cell current = grid.get(x).get(y);

        // Left
        if (y > 0) {
          current.addNeighbor(grid.get(x).get(y-1));
        }

        // Right
        if (y < cols - 1) {
          current.addNeighbor(grid.get(x).get(y+1));
        }

        // Top
        if (x > 0) {
          current.addNeighbor(grid.get(x-1).get(y));
        }

        // Bottom
        if (x < rows - 1) {
          current.addNeighbor(grid.get(x+1).get(y));
        }
      }
    }

    //printCellNeighbor();
    //printGridLayout(cols, rows);

    // Create cell walls
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        Cell current = grid.get(x).get(y);

        // Top Wall
        PVector topStart = new PVector(y*GRID_SIZE, x*GRID_SIZE);
        PVector topEnd = new PVector((y+1)*GRID_SIZE, x*GRID_SIZE);
        Wall topWall = new Wall(topStart, topEnd);
        current.walls.add(topWall);
        walls.add(topWall);

        if (!isBorderWall(topWall, current, rows, cols)) {
          wallCell.putIfAbsent(topWall, new ArrayList<Cell>());
          wallCell.get(topWall).add(current);
        }

        // Bottom Wall
        PVector bottomStart = new PVector(y*GRID_SIZE, (x+1)*GRID_SIZE);
        PVector bottomEnd = new PVector((y+1)*GRID_SIZE, (x+1)*GRID_SIZE);
        Wall bottomWall = new Wall(bottomStart, bottomEnd);
        current.walls.add(bottomWall);
        if (x == rows-1) {
          walls.add(bottomWall);
        }

        if (!isBorderWall(bottomWall, current, rows, cols)) {
          wallCell.putIfAbsent(bottomWall, new ArrayList<Cell>());
          wallCell.get(bottomWall).add(current);
        }

        // Left Wall
        PVector leftStart = new PVector(y*GRID_SIZE, x*GRID_SIZE);
        PVector leftEnd = new PVector(y*GRID_SIZE, (x+1)*GRID_SIZE);
        Wall leftWall = new Wall(leftStart, leftEnd);
        current.walls.add(leftWall);
        walls.add(leftWall);

        if (!isBorderWall(leftWall, current, rows, cols)) {
          wallCell.putIfAbsent(leftWall, new ArrayList<Cell>());
          wallCell.get(leftWall).add(current);
        }

        // Right Wall
        PVector rightStart = new PVector((y+1)*GRID_SIZE, x*GRID_SIZE);
        PVector rightEnd = new PVector((y+1)*GRID_SIZE, (x+1)*GRID_SIZE);
        Wall rightWall = new Wall(rightStart, rightEnd);
        current.walls.add(rightWall);
        if (y == cols-1) {
          walls.add(rightWall);
        }

        if (!isBorderWall(rightWall, current, rows, cols)) {
          wallCell.putIfAbsent(rightWall, new ArrayList<Cell>());
          wallCell.get(rightWall).add(current);
        }
      }
    }

    printGrid();
    printCellWalls();

    // Get random start index
    Cell startCell = grid.get(int(random(rows))).get(int(random(cols)));
    System.out.println("Starting Cell: " + startCell.x + " " + startCell.y);

    // Mark starting cell as visited
    startCell.setVisit();

    // Add walls around it to the frontier
    for (Wall w : startCell.walls) {
      if (!isBorderWall(w, startCell, rows, cols)
        ) {
        frontier.add(w);
      }
    }

    System.out.println("Frontier List");
    for (Wall w : frontier) {
      System.out.println(w.start + " " + w.end);
    }

    while (!frontier.isEmpty()) {
      // Pick random wall from frontier
      Wall wall = frontier.get(int(random(frontier.size())));
      System.out.println("Random Wall from frontier " + wall.start + " " + wall.end);

      // Get neighbor cell that share the same wall
      Cell neighbor = findNeighbor(wall);

      // If wall does not have a valid neighbor cell (neighbor cell has been visited), removed from frontier
      if (neighbor == null) {
        System.out.println("Null");
        frontier.remove(wall);
        continue;
      }

      System.out.println("Neighbor Cell: " + neighbor.x + " " + neighbor.y);

      // If the neighbor cell that have the wall has not been visited - getVisit()
      if (!neighbor.getVisit()) {
        System.out.println("Neighbor Visited: " + neighbor.getVisit());
        // Remove wall from the map
        for (Wall w : walls) {
          if (w.start.equals(wall.start) && w.end.equals(wall.end)) {
            walls.remove(w);
            break;
          }
        }

        System.out.println("After removing from walls");
        printGrid();

        // Set neighbor cell as visited
        neighbor.setVisit();
        System.out.println("Set neighbor visited: " + neighbor.getVisit());

        // Add neighbor cell's walls that isn't in frontier only if the wall is not the border
        for (Wall neighborWall : neighbor.walls) {
          if (!isBorderWall(neighborWall, neighbor, rows, cols) && !isInFrontier(frontier, neighborWall)) {
            System.out.println("Add to frontier");
            frontier.add(neighborWall);
          } else {
            System.out.println("Skip frontier");
          }
        }
      }
      System.out.println("Frontier before removing");
      for (Wall w : frontier) {
        System.out.println(w.start + " " + w.end);
      }

      // Remove wall from frontier
      frontier.remove(wall);
      System.out.println("After removing from frontier");
      for (Wall w : frontier) {
        System.out.println(w.start + " " + w.end);
      }
    }

    printGrid();
  }

  void printCellNeighbor() {
    System.out.println("Print Cell Neighbors: ");
    for (int x = 0; x < grid.size(); x++) {
      for (int y = 0; y < grid.get(x).size(); y++) {
        Cell cell = grid.get(x).get(y);
        System.out.println("Cell (" + cell.x + ", " + cell.y + ") neighbors:");
        for (Cell c : cell.neighbors) {
          System.out.println("Cell (" + c.x + ", " + c.y + ")");
        }
      }
    }
  }

  void printGridLayout(int cols, int rows) {
    System.out.println("Grid Layout: ");
    for (int x = 0; x < rows; x++) {
      StringBuilder rowString = new StringBuilder();
      for (int y = 0; y < cols; y++) {
        rowString.append("(" + x + "," + y + ") ");
      }
      System.out.println(rowString.toString());
    }
  }

  void printGrid() {
    // Print all walls in the grid (no duplicates)
    System.out.println("Print Grid: ");
    for (Wall w : walls) {
      System.out.println("Wall from " + w.start + " to " + w.end);
    }
    System.out.println(walls.size());
  }

  void printCellWalls() {
    // Print all walls in each cell
    System.out.println("Print Cell Walls: ");
    for (int x = 0; x < grid.size(); x++) {
      for (int y = 0; y < grid.get(x).size(); y++) {
        Cell cell = grid.get(x).get(y);
        System.out.println("Cell (" + cell.x + ", " + cell.y + ") walls:");
        for (Wall wall : cell.walls) {
          System.out.println("  Wall from " + wall.start + " to " + wall.end);
        }
      }
    }
  }

  Cell findNeighbor(Wall wall) {
    ArrayList<Cell> cells = wallCell.get(wall);

    if (cells == null) {
      return null;
    }

    for (Cell cell : cells) {
      if (!cell.getVisit()) {
        return cell;
      }
    }

    return null;
  }

  boolean isBorderWall(Wall wall, Cell cell, int rows, int cols) {
    return (wall.start.y == 0 && wall.end.y == 0 && cell.x == 0) ||
      (wall.start.x == 0 && wall.end.x == 0 && cell.y == 0) ||
      (wall.start.y == rows*GRID_SIZE && wall.end.y == rows*GRID_SIZE && cell.x == rows - 1) ||
      (wall.start.x == cols*GRID_SIZE && wall.end.x == cols*GRID_SIZE && cell.y == cols - 1);
  }

  boolean isInFrontier(ArrayList<Wall> frontier, Wall wall) {
    for (Wall w : frontier) {
      if ((w.start.equals(wall.start) && w.end.equals(wall.end)) ||
        (w.start.equals(wall.end) && w.end.equals(wall.start))) {
        return true;
      }
    }
    return false;
  }

  void update(float dt)
  {
    draw();
  }

  void draw()
  {
    stroke(255);
    strokeWeight(3);
    for (Wall w : walls)
    {
      w.draw();
    }
  }
}
