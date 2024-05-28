import processing.svg.*;

// Parameters
int xSize = 800;                        // width of the drawing
int ySize = 800;                        // height of the drawing

//int xSize = 800;
//int ySize = 800;

int rows = 8;                           // number of rows
int rowheight = 50;                     // any number between 0 and 99
int distFromBorder = 50;                // the distance the lines will have from the border

int strokeBase = 2;                     // minimum length of a stroke (gets multiplied by max. 4)

float thickStrokeProbability = 0;
int thinStrokeThickness = 1;
int thickStrokeThickness = 3;

float backwardsProbability = 0.15;      // will not affect if mapBackwardsProbability is true
boolean mapBackwardsProbability = true; // lower rows will be more complex
float minBackwardsProbability = 0;      // probability of drawing backwards applied to the first row
float maxBackwardsProbability = 0.5;   // probability of drawing backwards applied to the last row 

boolean loop = false;                   // generates automaticly new images

boolean drawRowBorder = false;          // draws the row limits
boolean exportSVG = true;               // exports the drawing as svg
String svgFilename = "export";          // name of the exported file

// internel variables
int rowdist = (ySize - 2*distFromBorder - rows*rowheight) / (rows-1);
int row;
int prevWeight = 1;
float[] pencil = new float[2];
float[] destiny = new float[2];

void settings() {
  size(xSize, ySize);
  pixelDensity(displayDensity());
}

void setup() {
  strokeWeight(2);
  noFill();
  strokeCap(SQUARE);
  noLoop();
}

void draw() {
  background(255);

  if (exportSVG) {
    beginRecord(SVG, svgFilename + ".svg");
  }
  
  if (drawRowBorder) {
    drawRowBorders();
  }

  row = - 1;
  pencil[1] = distFromBorder + rowheight * (row+0.5) + rowdist * row;
  while (rowBorder(1, row) < height - (distFromBorder - 20) - rowheight - rowdist) {
    row++;
    pencil[0] = distFromBorder;
    pencil[1] = distFromBorder + rowheight * (row+0.5) + rowdist * row;
    noFill();
    beginShape();
    drawline();
    endShape();
  }
  endRecord();
  //exit();
}

void mouseClicked() {
  redraw();
}

void keyPressed() {
  if (keyCode == ENTER) {
    redraw();
  }
}

// programmable patterns:
// 0: diagonal, 1: vertical, 2: horizintal
// 1: down, -1: up, 0: no direction

int[][] horizontal = {{2, 0}};
int[][] diagonal_up = {{0, -1}};
int[][] diagonal_down = {{0, 1}};
int[][] vertical_up = {{1, -1}};
int[][] vertical_down = {{1, 1}};
int[][] triangle = {{0, 1}, {0, -1}};
int[][] square = {{2, 0}, {1, 1}, {2, 0}, {1, -1}};
int[][] square_doubleheight = {{2, 0}, {1, 1}, {1, 1}, {2, 0}, {1, -1}, {1, -1}};
int[][][] forms = {horizontal, diagonal_up, vertical_up, vertical_down, diagonal_down, triangle, square, square_doubleheight};

void drawline() {
  int  mode;
  float times;
  float backforth;
  float weight;
  int linelength;
  while (pencil[0] < width - distFromBorder) {
    mode = round(random(forms.length - 1));
    linelength = round(random(1, 4));

    times = random(1);
    times = times > 0.1 ? times : 4;
    times = times > 0.25 ? times : 3;
    times = times > 0.6 ? times : 2;
    times = times > 1 ? times : 1;

    if (mapBackwardsProbability) {
      backwardsProbability = map(row, 0, rows, minBackwardsProbability, maxBackwardsProbability);
    }

    backforth = random(1);
    backforth = backforth > backwardsProbability ? 1 : -1;

    //thickStrokeProbability = pencil[0]/width;
    weight = random(1);
    weight = weight > thickStrokeProbability ? thinStrokeThickness : thickStrokeThickness;
    //weight = map(pencil[0]/width, 0, 1, 0, 8);

    if (prevWeight != (int)weight) {
      endShape();
      beginShape();
    }

    strokeWeight(weight);
    prevWeight = (int)weight;

    vertex(pencil[0], pencil[1]);
    drawPatterns(forms[mode], linelength, (int)times, (int)backforth);
  }
}
void drawPatterns(int[][] modes, int linelength, int times, int backforth) {
  for (int i = 0; i < times; i++) {
    for (int j = 0; j < modes.length; j++) {
      switch (modes[j][0]) {
      case 0: // diagonal
        destiny[0] = pencil[0] + strokeBase * linelength * backforth;
        destiny[1] = pencil[1] + strokeBase * linelength * modes[j][1];
        break;

      case 1: // vertical
        destiny[0] = pencil[0];
        destiny[1] = pencil[1] + strokeBase * linelength * modes[j][1];
        break;

      default: // horizontal
        destiny[0] = pencil[0] + strokeBase * linelength * backforth;
      }

      if (destiny[0] < distFromBorder) {
        destiny[0] += 2 * linelength * strokeBase;
      }
      if (destiny[0] > width - distFromBorder) {
        continue;
      }
      if (destiny[1] < rowBorder(0, row) || destiny[1] > rowBorder(1, row)) {
        destiny[1] = pencil[1];
      }

      //line(pencil[0], pencil[1], destiny[0], destiny[1]);
      vertex(destiny[0], destiny[1]);

      arrayCopy(destiny, pencil);
    }
  }
}

void drawRowBorders() {
  for (int i = 0; i < 7; i++) {
    if (rowBorder(1, i) < height) {
      rect(distFromBorder, rowBorder(0, i), width - distFromBorder * 2, rowheight);
    }
  }
}

float rowBorder(int which, int l) {
  float res;
  if (which == 0) { // top border
    res = distFromBorder + (rowheight+rowdist)*l;
    return res;
  } else { // lower border
    res = distFromBorder + rowheight*(l+1) + rowdist*l;
    return res;
  }
}
