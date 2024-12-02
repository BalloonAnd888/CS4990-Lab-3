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

  void addNeighbors(Cell neighbor) {
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
    fill(255, 0, 0);
  }
}


class Map
{
  ArrayList<ArrayList<Cell>> grid;
  ArrayList<Wall> walls;
  ArrayList<Cell> frontier;

  Map()
  {
    walls = new ArrayList<Wall>();
    frontier = new ArrayList<Cell>();
  }



  void generate(int which)
  {
    walls.clear();

    System.out.println("Width: " + width);
    System.out.println("Height: " + height);

    int cols = width / GRID_SIZE;
    int rows = height / GRID_SIZE;

    System.out.println("Cols: " + cols);
    System.out.println("Rows: " + rows);

    grid = new ArrayList<ArrayList<Cell>>();

    for (int x = 0; x < cols; x++) {
      ArrayList<Cell> row = new ArrayList<Cell>();
      for (int y = 0; y < rows; y++) {
        row.add(new Cell(x, y));
      }
      grid.add(row);
    }

    System.out.println("Grid Layout: ");
    for (int x = 0; x < cols; x++) {
      StringBuilder rowString = new StringBuilder();
      for (int y = 0; y < rows; y++) {
        rowString.append("(" + x + "," + y + ") "); 
      }
      System.out.println(rowString.toString());
    }

    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        Cell current = grid.get(x).get(y);

        // Add right wall if not on the rightmost edge
        if (x < cols - 1) {
          PVector start = new PVector(x * GRID_SIZE, y * GRID_SIZE);
          PVector end = new PVector((x + 1) * GRID_SIZE, y * GRID_SIZE);
          Wall rightWall = new Wall(start, end);
          walls.add(rightWall);
          current.walls.add(rightWall); 
        }

        // Add bottom wall if not on the bottommost edge
        if (y < rows - 1) {
          PVector start = new PVector(x * GRID_SIZE, y * GRID_SIZE);
          PVector end = new PVector(x * GRID_SIZE, (y + 1) * GRID_SIZE);
          Wall bottomWall = new Wall(start, end);
          walls.add(bottomWall);
          current.walls.add(bottomWall);  // Add wall to current cell
        }

        // Add top wall if not on the topmost edge
        if (y > 0) {
          PVector start = new PVector(x * GRID_SIZE, y * GRID_SIZE);
          PVector end = new PVector(x * GRID_SIZE, (y - 1) * GRID_SIZE);
          Wall topWall = new Wall(start, end);
          walls.add(topWall);
          current.walls.add(topWall);
        }

        // Add left wall if not on the leftmost edge
        if (x > 0) {
          PVector start = new PVector(x * GRID_SIZE, y * GRID_SIZE);
          PVector end = new PVector((x - 1) * GRID_SIZE, y * GRID_SIZE);
          Wall leftWall = new Wall(start, end);
          walls.add(leftWall);
          current.walls.add(leftWall);
        }
      }
    }
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

    if (DEBUG) {
      for (ArrayList<Cell> row : grid) {
        for (Cell cell : row) {
          cell.draw();
        }
      }
    }
  }
}
