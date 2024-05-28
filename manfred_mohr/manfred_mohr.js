// Parameters
let xSize = 800; // width of the drawing
let ySize = 800; // height of the drawing
let rows = 8; // number of rows
let rowheight = 50; // any number between 0 and 99
let distFromBorder = 50; // the distance the lines will have from the border
let strokeBase = 2; // minimum length of a stroke (gets multiplied by max. 4)
let thickStrokeProbability = 0;
let thinStrokeThickness = 1;
let thickStrokeThickness = 3;
let backwardsProbability = 0.15; // will not affect if mapBackwardsProbability is true
let mapBackwardsProbability = true; // lower rows will be more complex
let minBackwardsProbability = 0; // probability of drawing backwards applied to the first row
let maxBackwardsProbability = 0.5; // probability of drawing backwards applied to the last row
let drawRowBorder = false; // draws the row limits
// internel variables
let rowdist = (ySize - 2 * distFromBorder - rows * rowheight) / (rows - 1);
let row;
let prevWeight = 1;
let pencil = new Array(2);
let destiny = new Array(2);
function setup() {
    createCanvas(800, 800);
    strokeWeight(2);
    noFill();
    strokeCap(SQUARE);
    noLoop();
}
function draw() {
    background(255);
    if (drawRowBorder) {
        drawRowBorders();
    }
    row = -1;
    pencil[1] = distFromBorder + rowheight * (row + 0.5) + rowdist * row;
    while (
        rowBorder(1, row) <
        height - (distFromBorder - 20) - rowheight - rowdist
    ) {
        row++;
        pencil[0] = distFromBorder;
        pencil[1] = distFromBorder + rowheight * (row + 0.5) + rowdist * row;
        noFill();
        beginShape();
        drawline();
        endShape();
    } //exit();
}
function mouseClicked() {
    redraw();
}
function keyPressed() {
    if (keyCode == ENTER) {
        redraw();
    }
} // programmable patterns:
// 0: diagonal, 1: vertical, 2: horizintal
// 1: down, -1: up, 0: no direction
let horizontal = [[2, 0]];
let diagonal_up = [[0, -1]];
let diagonal_down = [[0, 1]];
let vertical_up = [[1, -1]];
let vertical_down = [[1, 1]];
let triangle_movement = [
    [0, 1],
    [0, -1],
];
let square_movement = [
    [2, 0],
    [1, 1],
    [2, 0],
    [1, -1],
];
let square_doubleheight = [
    [2, 0],
    [1, 1],
    [1, 1],
    [2, 0],
    [1, -1],
    [1, -1],
];
let forms = [
    horizontal,
    diagonal_up,
    vertical_up,
    vertical_down,
    diagonal_down,
    triangle_movement,
    square_movement,
    square_doubleheight,
];
function drawline() {
    let mode;
    let times;
    let backforth;
    let weight;
    let linelength;
    while (pencil[0] < width - distFromBorder) {
        mode = round(random(forms.length - 1));
        linelength = round(random(1, 4));
        times = random(1);
        times = times > 0.1 ? times : 4;
        times = times > 0.25 ? times : 3;
        times = times > 0.6 ? times : 2;
        times = times > 1 ? times : 1;
        if (mapBackwardsProbability) {
            backwardsProbability = map(
                row,
                0,
                rows,
                minBackwardsProbability,
                maxBackwardsProbability
            );
        }
        backforth = random(1);
        backforth = backforth > backwardsProbability ? 1 : -1; //thickStrokeProbability = pencil[0]/width;
        weight = random(1);
        weight =
            weight > thickStrokeProbability
                ? thinStrokeThickness
                : thickStrokeThickness; //weight = map(pencil[0]/width, 0, 1, 0, 8);
        if (prevWeight != weight) {
            endShape();
            beginShape();
        }
        strokeWeight(weight);
        prevWeight = weight;
        vertex(pencil[0], pencil[1]);
        drawPatterns(forms[mode], linelength, times, backforth);
    }
}
function drawPatterns(modes, linelength, times, backforth) {
    for (let i = 0; i < times; i++) {
        for (let j = 0; j < modes.length; j++) {
            switch (modes[j][0]) {
                case 0: // diagonal
                    destiny[0] =
                        pencil[0] + strokeBase * linelength * backforth;
                    destiny[1] =
                        pencil[1] + strokeBase * linelength * modes[j][1];
                    break;
                case 1: // vertical
                    destiny[0] = pencil[0];
                    destiny[1] =
                        pencil[1] + strokeBase * linelength * modes[j][1];
                    break;
                default:
                    // horizontal
                    destiny[0] =
                        pencil[0] + strokeBase * linelength * backforth;
            }
            if (destiny[0] < distFromBorder) {
                destiny[0] += 2 * linelength * strokeBase;
            }
            if (destiny[0] > width - distFromBorder) {
                continue;
            }
            if (
                destiny[1] < rowBorder(0, row) ||
                destiny[1] > rowBorder(1, row)
            ) {
                destiny[1] = pencil[1];
            } //line(pencil[0], pencil[1], destiny[0], destiny[1]);
            vertex(destiny[0], destiny[1]);
            arrayCopy(destiny, pencil);
        }
    }
}
function drawRowBorders() {
    for (let i = 0; i < 7; i++) {
        if (rowBorder(1, i) < height) {
            rect(
                distFromBorder,
                rowBorder(0, i),
                width - distFromBorder * 2,
                rowheight
            );
        }
    }
}
function rowBorder(which, l) {
    let res;
    if (which == 0) {
        // top border
        res = distFromBorder + (rowheight + rowdist) * l;
        return res;
    } else {
        // lower border
        res = distFromBorder + rowheight * (l + 1) + rowdist * l;
        return res;
    }
}
