import processing.svg.*; //<>//

// ######################################## //
//             RANDOM BEZIERFORMS           //
// ######################################## //

//       # # #    PARAMETERS    # # #       //

float cMinBezierDist = 10;                   // minimum distance from a bezier puller to its anchorpoint
int cNumberBeziersSmall = 1;                 // number of bezierlines being drawn in a small form 
int cNumberBeziersBig = 10;                  // number of bezierlines being drawn in a big form 
int cNumberPointsSmall = 2;                  // number of bezierpoints in a small form
int cNumberPointsBig = 5;                    // number of bezierpoints in a big form
boolean saveSVG = true;                      // should it be saved as .svg-file?

//       # # #    VARIABLES     # # #        //
//              DO NOT MODIFY                //

ArrayList<bezierForm> forms = new ArrayList<bezierForm>();
float pentagonSize = 1;
int numberBeziersX = 5;
int numberBeziersY = 4;

//       # # #       CODE       # # #       //

void setup() {
  size(990, 700);
  pixelDensity(displayDensity());
  background(0);
  textAlign(CENTER);
  text("PRESS ENTER TO BEGIN", width/2, height/2);
}

void draw() {
}

void keyPressed() {
  if (key == ENTER) {
    if (saveSVG) {
      beginRecord(SVG, "result.svg");
    }
    background(0);
    drawRandomBezierForm(height-(2*height/numberBeziersX), width-(2*width/numberBeziersY), width/2, height/2, cNumberPointsBig, cNumberBeziersBig, 0.75);
    for (float i = 0; i < numberBeziersX; i++) {
      for (float j = 0; j < numberBeziersY; j++) {
        if (i == 0 || i == numberBeziersX - 1 || j == 0 || j == numberBeziersY - 1) {
          drawRandomBezierForm((width-250)/numberBeziersX, (height-250)/numberBeziersY, width/numberBeziersX*(i+0.4), height/numberBeziersY*(j+0.4), cNumberPointsSmall, cNumberBeziersSmall, 0.5);
        }
      }
    }
    if (saveSVG) {
      endRecord();
    }
  }
}

void drawRandomBezierForm(float xSize, float ySize, float xPos, float yPos, int numberPoints, int numberBeziers, float bezierDistance) { //<>//
  bezierForm form = randomForm(xSize, ySize, numberPoints);
  if (form == null) {
    return;
  }
  form.cPosition = new PVector(xPos, yPos);
  pentagonSize = 5 - 0.4*numberBeziers;
  for (int i = 0; i < numberBeziers; i++) {
    drawBezierForm(form);
    form.pullerCloser(bezierDistance);
    pentagonSize += 0.6;
  }

  forms.add(form);
}

bezierForm randomForm(float xSize, float ySize, int numberPoints) {
  PVector[] bezier = new PVector[numberPoints*3];
  PVector a = randomVector(xSize, ySize);
  PVector b = randomVector(xSize, ySize);
  while (a.dist(b) < xSize * 0.1 || a.dist(b) > xSize * 0.9) {
    b = randomVector(xSize, ySize);
  }
  int tryB = 0;
  for (int i = 0; i < bezier.length; i+=3) {
    PVector p = randomVector(xSize, ySize);
    PVector p1 = randomVector(xSize, ySize);
    PVector p2 = switchSide(p, p1);
    while (isOutside(p2, xSize, ySize) || p.dist(p2) < cMinBezierDist) {
      p1 = randomVector(xSize, ySize);
      p2 = switchSide(p, p1);
      tryB++;
      if (tryB > 10000) {
        return null;
      }
    }
    bezier[i] = p1;
    bezier[i+1] = p;
    bezier[i+2] = p2; //<>//
  }
  return new bezierForm(bezier);
}

void drawBezierForm(bezierForm form) {
  stroke(255);
  noFill();
  translate(form.cPosition.x, form.cPosition.y);
  for (int i = 1; i < form.cPoints.length; i+=3) {
    bezier(form.cPoints[i].x, form.cPoints[i].y, form.cPoints[i+1].x, form.cPoints[i+1].y, form.cPoints[(i+2)%form.cPoints.length].x, form.cPoints[(i+2)%form.cPoints.length].y, form.cPoints[(i+3)%form.cPoints.length].x, form.cPoints[(i+3)%form.cPoints.length].y);
  }
  colorMode(HSB, 100);
  stroke(random(0, 100), 100, 100);
  colorMode(RGB, 255);
  for (int i = 0; i < form.cPoints.length; i+=3) {
    //circle(form.cPoints[i+1].x, form.cPoints[i+1].y, 30);
    ngon(form.cPoints[i].x, form.cPoints[i].y, pentagonSize, 5);
    ngon(form.cPoints[i+2].x, form.cPoints[i+2].y, pentagonSize, 5);
  }

  translate(-form.cPosition.x, -form.cPosition.y);
}

PVector randomVector(float xSize, float ySize) {
  return new PVector(random(xSize), random(ySize));
}

PVector switchSide(PVector point, PVector puller) {
  return new PVector(point.x + (point.x - puller.x), point.y + (point.y - puller.y));
}

boolean isOutside(PVector point, float xSize, float ySize) {
  if (point.x < 0 || point.x > xSize || point.y < 0 || point.y > ySize) {
    return true;
  }
  return false;
}

boolean isInsideBox(PVector point, PVector[] box) {
  if (point.x > box[0].x && point.y > box[0].y && point.x < box[1].x && point.y < box[1].y) {
    return true;
  }
  return false;
}

void ngon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
