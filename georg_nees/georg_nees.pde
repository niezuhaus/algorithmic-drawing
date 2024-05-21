import processing.svg.*;

int borderDist = 50;
int numberX = 14;
int numberY = 20;
int boxSize  = 40;
int corners = 23;
float gonDist = 5;
boolean mapGonDist = true;
int gonDistStart = 15;
int gonDistEnd = -15;
boolean mapCorners = true;
int cornersStart = 3;
int cornersEnd = 40;

boolean clicked = false;

void settings() {
  size(numberX*boxSize  + 2*borderDist, numberY*boxSize   + 2*borderDist);
}

void setup() {
  noLoop();
  stroke(0);
}

void draw() {
  background(255); //<>//
  if (clicked) {
    beginRecord(SVG, "export.svg");
  }
  for (int y = 0; y <numberY; y++) {
    for (int x = 0; x < numberX; x++) {
      drawShape(x, y, createNGon(x));
    }
  }
  if (clicked) {
    endRecord();
    clicked = false;
  }
}

float[][] createNGon(int column) {  
  if (mapCorners) {
    corners = round(map(column, 0, numberX, cornersStart, cornersEnd));
  }

  float[][] res = new float[corners][2];
  res[0][0] = random(boxSize  - gonDist);
  res[0][1] = random(boxSize  - gonDist);

  boolean horizontal = round(random(1)) == 1 ? true : false;
  float limit;

  for (int i = 1; i < corners; i++) {
    if (horizontal) {
      limit = round(random(1)) == 1 ? res[i-1][0] : boxSize  - res[i-1][0];
      res[i][0] = random(limit);
      res[i][1] = res[i-1][1];
    } else {
      limit = round(random(1)) == 1 ? res[i-1][1] : boxSize  - res[i-1][1];
      res[i][0] = res[i-1][0];
      res[i][1] = random(limit);
    }
    horizontal = !horizontal;
  }
  return res;
}

void drawShape(float column, float row, float[][] vertexes) {
  if (mapGonDist) {
    gonDist = map(row, 1, numberY, gonDistStart, gonDistEnd);
  }
  noFill();
  beginShape();
  for (int i = 0; i < vertexes.length; i++) {
    float x = map(vertexes[i][0], 0, boxSize, gonDist, boxSize - gonDist);
    float y = map(vertexes[i][1], 0, boxSize, gonDist, boxSize - gonDist);
    vertex(borderDist + column*boxSize + x, borderDist + row*boxSize + y);
  }
  endShape(CLOSE);
}

void mouseClicked() {
  clicked = true;
  redraw();
}

void mouseMoved() {
  cornersEnd = round(map(mouseX, 0, width, cornersStart, 50));
  gonDistEnd = round(map(mouseY, 0, height, gonDistStart, -20));
  redraw();
}
