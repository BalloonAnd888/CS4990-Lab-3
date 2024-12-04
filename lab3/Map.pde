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

  Map()
  {
    walls = new ArrayList<Wall>();
    frontier = new ArrayList<Wall>();
  }



  void generate(int which)
  {
    walls.clear();

    System.out.println("Generate");

    System.out.println("Width: " + width);
    System.out.println("Height: " + height);

    int cols = width / GRID_SIZE;
    int rows = height / GRID_SIZE;

    System.out.println("Cols: " + cols);
    System.out.println("Rows: " + rows);

    grid = new ArrayList<ArrayList<Cell>>();

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

    printCellNeighbor();
    printGridLayout(cols, rows);

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

        // Bottom Wall
        PVector bottomStart = new PVector(y*GRID_SIZE, (x+1)*GRID_SIZE);
        PVector bottomEnd = new PVector((y+1)*GRID_SIZE, (x+1)*GRID_SIZE);
        Wall bottomWall = new Wall(bottomStart, bottomEnd);
        current.walls.add(bottomWall);
        if (x == rows-1) {
          walls.add(bottomWall);
        }

        // Left Wall
        PVector leftStart = new PVector(y*GRID_SIZE, x*GRID_SIZE);
        PVector leftEnd = new PVector(y*GRID_SIZE, (x+1)*GRID_SIZE);
        Wall leftWall = new Wall(leftStart, leftEnd);
        current.walls.add(leftWall);
        walls.add(leftWall);

        // Right Wall
        PVector rightStart = new PVector((y+1)*GRID_SIZE, x*GRID_SIZE);
        PVector rightEnd = new PVector((y+1)*GRID_SIZE, (x+1)*GRID_SIZE);
        Wall rightWall = new Wall(rightStart, rightEnd);
        current.walls.add(rightWall);
        if (y == cols-1) {
          walls.add(rightWall);
        }
      }
    }

    printGrid();
    printCellWalls();

    //Place all walls
    //  Start at a (random, or selected) node and mark it as visited
    //  Add the walls around it to a list
    //While there are walls in the list, pick a random wall:
    //If only one of the two cells it connects has been visited,
    //  remove the wall from the map, mark that neighbor as
    //  visited and add its walls to the list
    //  Remove the wall from the list

    // Get random start index
    Cell startCell = grid.get(int(random(rows))).get(int(random(cols)));
    System.out.println(startCell.x + " " + startCell.y);

    //System.out.println(startCell.visited);
    startCell.setVisit();
    //System.out.println(startCell.visited);
    for (Wall w : startCell.walls) {
      if ((w.start.y == 0 && w.end.y == 0 && startCell.x == 0) ||
        (w.start.x == 0 && w.end.x == 0 && startCell.y == 0) ||
        (w.start.y == rows*GRID_SIZE && w.end.y == rows*GRID_SIZE && startCell.x == rows - 1) ||
        (w.start.x == cols*GRID_SIZE && w.end.x == cols*GRID_SIZE && startCell.y == cols - 1)
        ) {
        continue;
      }
      frontier.add(w);
    }

    System.out.println("Frontier List");
    for (Wall w : frontier) {
      System.out.println(w.start + " " + w.end);
    }

    // in while loop
    // Pick random wall from frontier
    Wall wall = frontier.get(int(random(frontier.size())));
    System.out.println("Random Wall from frontier " + wall.start + " " + wall.end);

    // Get neighbor cell that share the same wall
    Cell neighbor = findNeighbor(wall);

    System.out.println(neighbor.x + " " + neighbor.y);

    // If the neighbor cell that have the wall has not been visited - getVisit()
    if (!neighbor.getVisit()) {
      // remove wall from the map
      // remove wall from frontier
      // neighbor - setVisit()
      // add neighbor cell's walls that isn't in frontier
    } else {
      frontier.remove(wall);
    }




    //while (!frontier.isEmpty()) {
    //  // Pick random wall from frontier
    //  Wall wall = frontier.get(int(random(frontier.size())));
    //  System.out.println(wall.start + "" + wall.end);

    //  // Get neighbor cell that share the same wall
    //Cell neighbor = findNeighbor(wall);


    //}
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
    for (int x = 0; x < grid.size(); x++) {
      for (int y = 0; y < grid.get(x).size(); y++) {
        Cell cell = grid.get(x).get(y);
        for (Wall w : cell.walls) {
          System.out.println("  Wall from " + w.start + " to " + w.end);
          if ((w.start.equals(wall.start)) && (w.end.equals(wall.end))) {
            System.out.println("Yes");
            return cell;
          }
        }
      }
    }

    return null;
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
