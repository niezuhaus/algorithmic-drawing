class ArrayList extends Array {
    constructor() {
        super(...[]);
    }
    size() {
        return this.length;
    }
    add(x) {
        this.push(x);
    }
    get(i) {
        return this[i];
    }
    remove(i) {
        this.splice(i, 1);
    }
}

// [processing-p5-convert] import processing.svg.*;
let cMinBezierDist = 10; // minimum distance from a bezier puller to its anchorpoint
let cNumberBeziersSmall = 1; // number of bezierlines being drawn in a small form
let cNumberBeziersBig = 10; // number of bezierlines being drawn in a big form
let cNumberPointsSmall = 2; // number of bezierpoints in a small form
let cNumberPointsBig = 5; // number of bezierpoints in a big form
let forms = new ArrayList();
let pentagonSize = 1;
let numberBeziersX = 5;
let numberBeziersY = 4;
function setup() {
    this.focus();
    createCanvas(990, 700);
    pixelDensity(displayDensity());
    makeArt();
}
function draw() { }
function keyPressed(key) {
    if (key.key == "Enter") {
        makeArt();
    }
}
function makeArt() {
    background(0);
    drawRandomBezierForm(
        height - (2 * height) / numberBeziersX,
        width - (2 * width) / numberBeziersY,
        width / 2,
        height / 2,
        cNumberPointsBig,
        cNumberBeziersBig,
        0.75
    );
    for (let i = 0; i < numberBeziersX; i++) {
        for (let j = 0; j < numberBeziersY; j++) {
            if (
                i == 0 ||
                i == numberBeziersX - 1 ||
                j == 0 ||
                j == numberBeziersY - 1
            ) {
                drawRandomBezierForm(
                    (width - 250) / numberBeziersX,
                    (height - 250) / numberBeziersY,
                    (width / numberBeziersX) * (i + 0.4),
                    (height / numberBeziersY) * (j + 0.4),
                    cNumberPointsSmall,
                    cNumberBeziersSmall,
                    0.5
                );
            }
        }
    }
}
function drawRandomBezierForm(
    xSize,
    ySize,
    xPos,
    yPos,
    numberPoints,
    numberBeziers,
    bezierDistance
) {
    let form = randomForm(xSize, ySize, numberPoints);
    if (form == null) {
        return;
    }
    form.cPosition = new p5.Vector(xPos, yPos);
    pentagonSize = 5 - 0.4 * numberBeziers;
    for (let i = 0; i < numberBeziers; i++) {
        drawBezierForm(form);
        form.pullerCloser(bezierDistance);
        pentagonSize += 0.6;
    }
    forms.add(form);
}
function randomForm(xSize, ySize, numberPoints) {
    let bezier = new Array(numberPoints * 3);
    let a = randomVector(xSize, ySize);
    let b = randomVector(xSize, ySize);
    while (a.dist(b) < xSize * 0.1 || a.dist(b) > xSize * 0.9) {
        b = randomVector(xSize, ySize);
    }
    let tryB = 0;
    for (let i = 0; i < bezier.length; i += 3) {
        let p = randomVector(xSize, ySize);
        let p1 = randomVector(xSize, ySize);
        let p2 = switchSide(p, p1);
        while (isOutside(p2, xSize, ySize) || p.dist(p2) < cMinBezierDist) {
            p1 = randomVector(xSize, ySize);
            p2 = switchSide(p, p1);
            tryB++;
            if (tryB > 10000) {
                return null;
            }
        }
        bezier[i] = p1;
        bezier[i + 1] = p;
        bezier[i + 2] = p2;
    }
    return new bezierForm(bezier);
}
function drawBezierForm(form) {
    stroke(255);
    noFill();
    translate(form.cPosition.x, form.cPosition.y);
    for (let i = 1; i < form.cPoints.length; i += 3) {
        bezier(
            form.cPoints[i].x,
            form.cPoints[i].y,
            form.cPoints[i + 1].x,
            form.cPoints[i + 1].y,
            form.cPoints[(i + 2) % form.cPoints.length].x,
            form.cPoints[(i + 2) % form.cPoints.length].y,
            form.cPoints[(i + 3) % form.cPoints.length].x,
            form.cPoints[(i + 3) % form.cPoints.length].y
        );
    }
    colorMode(HSB, 100);
    stroke(random(0, 100), 100, 100);
    colorMode(RGB, 255);
    for (let i = 0; i < form.cPoints.length; i += 3) {
        //circle(form.cPoints[i+1].x, form.cPoints[i+1].y, 30);
        ngon(form.cPoints[i].x, form.cPoints[i].y, pentagonSize, 5);
        ngon(form.cPoints[i + 2].x, form.cPoints[i + 2].y, pentagonSize, 5);
    }
    translate(-form.cPosition.x, -form.cPosition.y);
}
function randomVector(xSize, ySize) {
    return new p5.Vector(random(xSize), random(ySize));
}
function switchSide(point, puller) {
    return new p5.Vector(
        point.x + (point.x - puller.x),
        point.y + (point.y - puller.y)
    );
}
function isOutside(point, xSize, ySize) {
    if (point.x < 0 || point.x > xSize || point.y < 0 || point.y > ySize) {
        return true;
    }
    return false;
}
function isInsideBox(point, box) {
    if (
        point.x > box[0].x &&
        point.y > box[0].y &&
        point.x < box[1].x &&
        point.y < box[1].y
    ) {
        return true;
    }
    return false;
}
function ngon(x, y, radius, npoints) {
    let angle = TWO_PI / npoints;
    beginShape();
    for (let a = 0; a < TWO_PI; a += angle) {
        let sx = x + cos(a) * radius;
        let sy = y + sin(a) * radius;
        vertex(sx, sy);
    }
    endShape(CLOSE);
}
class bezierForm {
    cPointA;
    cPoints;
    cPointsBackup;
    cPosition;
    cBox;
    constructor(points) {
        this.cPoints = points;
        this.cPointsBackup = points;
        this.cPointA = points[1];
        let xs = new Array(points.length);
        let ys = new Array(points.length);
        for (let i = 0; i < points.length; i++) {
            xs[i] = points[i].x;
            ys[i] = points[i].y;
        }
        let box = [
            new p5.Vector(min(xs), min(ys)),
            new p5.Vector(max(xs), max(ys)),
        ];
        this.cBox = box;
        for (point of points) {
            point.sub(p5.Vector.mult(this.cBox[1], 0.5));
        }
        this.cBox[0].sub(p5.Vector.mult(this.cBox[1], 0.5));
        p5.Vector.mult(this.cBox[1], 0.5);
    }
    getAbsoluteBox() {
        let result = [
            p5.Vector.add(this.cBox[0], this.cPosition),
            p5.Vector.add(this.cBox[1], this.cPosition),
        ];
        return result;
    }
    getAbsoluteBox(position) {
        let result = [
            p5.Vector.add(this.cBox[0], position),
            p5.Vector.add(this.cBox[1], position),
        ];
        return result;
    }
    pullerCloser(amount) {
        for (let i = 1; i < this.cPoints.length; i += 3) {
            this.cPoints[i - 1] = p5.Vector.sub(
                this.cPoints[i],
                p5.Vector.mult(
                    p5.Vector.sub(this.cPoints[i], this.cPoints[i - 1]),
                    amount
                )
            );
            this.cPoints[(i + 1) % this.cPoints.length] = p5.Vector.sub(
                this.cPoints[i],
                p5.Vector.mult(
                    p5.Vector.sub(
                        this.cPoints[i],
                        this.cPoints[(i + 1) % this.cPoints.length]
                    ),
                    amount
                )
            );
        }
    }
    pullerReset() {
        this.cPoints = this.cPointsBackup;
    }
    printPoints() {
        for (point of this.cPoints) {
            console.log(point.x + " " + point.y + " ");
        }
        console.log();
    }
}