class bezierForm { //<>//
  PVector cPointA;
  PVector[] cPoints;
  PVector[] cPointsBackup;
  PVector cPosition;
  PVector[] cBox;

  bezierForm(PVector[] points) {
    cPoints = points;
    cPointsBackup = points;
    cPointA = points[1];

    float[] xs = new float[points.length];
    float[] ys = new float[points.length];
    for (int i = 0; i < points.length; i++) {
      xs[i] = points[i].x;
      ys[i] = points[i].y;
    }
    PVector[] box = {new PVector(min(xs), min(ys)), new PVector(max(xs), max(ys))};
    cBox = box;

    for (PVector point : points) {
      point.sub(PVector.mult(cBox[1], 0.5));
    }
    cBox[0].sub(PVector.mult(cBox[1], 0.5));
    PVector.mult(cBox[1],0.5);
  }

  PVector[] getAbsoluteBox() {
    PVector[] result = {PVector.add(cBox[0], cPosition), PVector.add(cBox[1], cPosition)};
    return result;
  }

  PVector[] getAbsoluteBox(PVector position) {
    PVector[] result = {PVector.add(cBox[0], position), PVector.add(cBox[1], position)};
    return result;
  }
  
  void pullerCloser(float amount){
    for(int i = 1; i < cPoints.length; i+=3){
      cPoints[i - 1] = PVector.sub(cPoints[i], PVector.mult(PVector.sub(cPoints[i], cPoints[i - 1]), amount));
      cPoints[(i + 1) % cPoints.length] = PVector.sub(cPoints[i], PVector.mult(PVector.sub(cPoints[i], cPoints[(i + 1) % cPoints.length]), amount));
    }
  }
  
  void pullerReset(){
    cPoints = cPointsBackup; //<>//
  }
  
  void printPoints(){
    for(PVector point : cPoints){
      print(point.x + " " + point.y + " ");
    }
    println();
  }
}
