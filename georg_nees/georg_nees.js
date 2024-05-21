let borderDist = 50;
let numberX = 14;
let numberY = 20;
let boxSize = 40;
let corners = 23;
let gonDist = 5;
let mapGonDist = true;
let gonDistStart = 15;
let gonDistEnd = -15;
let mapCorners = true;
let cornersStart = 3;
let cornersEnd = 40;
function setup() {
    createCanvas(660, 900);
    noLoop();
    stroke(0);
}
function draw() {
    background(255);
    for (let y = 0; y < numberY; y++) {
        for (let x = 0; x < numberX; x++) {
            drawShape(x, y, createNGon(x));
        }
    }
}
function createNGon(column) {
    if (mapCorners) {
        corners = round(map(column, 0, numberX, cornersStart, cornersEnd));
    }
    let res = Array.from(new Array(corners), () => new Array(2));
    res[0][0] = random(boxSize - gonDist);
    res[0][1] = random(boxSize - gonDist);
    let horizontal = round(random(1)) == 1 ? true : false;
    let limit;
    for (let i = 1; i < corners; i++) {
        if (horizontal) {
            limit =
                round(random(1)) == 1 ? res[i - 1][0] : boxSize - res[i - 1][0];
            res[i][0] = random(limit);
            res[i][1] = res[i - 1][1];
        } else {
            limit =
                round(random(1)) == 1 ? res[i - 1][1] : boxSize - res[i - 1][1];
            res[i][0] = res[i - 1][0];
            res[i][1] = random(limit);
        }
        horizontal = !horizontal;
    }
    return res;
}
function drawShape(column, row, vertexes) {
    if (mapGonDist) {
        gonDist = map(row, 1, numberY, gonDistStart, gonDistEnd);
    }
    noFill();
    beginShape();
    for (let i = 0; i < vertexes.length; i++) {
        let x = map(vertexes[i][0], 0, boxSize, gonDist, boxSize - gonDist);
        let y = map(vertexes[i][1], 0, boxSize, gonDist, boxSize - gonDist);
        vertex(
            borderDist + column * boxSize + x,
            borderDist + row * boxSize + y
        );
    }
    endShape(CLOSE);
}
function mouseMoved() {
    cornersEnd = round(map(mouseX, 0, width, cornersStart, 50));
    gonDistEnd = round(map(mouseY, 0, height, gonDistStart, -20));
    redraw();
}
