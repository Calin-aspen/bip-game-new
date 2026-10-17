class_name Px
## Tiny pixel-art drawing helpers. Everything snaps to whole pixels.

static func rect(ci: CanvasItem, x: float, y: float, w: float, h: float, col: Color) -> void:
	ci.draw_rect(Rect2(int(x), int(y), int(w), int(h)), col)

## Filled ellipse drawn row by row, so the edges look like pixel art.
static func ellipse(ci: CanvasItem, cx: float, cy: float, rx: float, ry: float, col: Color) -> void:
	if rx <= 0.0 or ry <= 0.0:
		return
	var r := int(ry)
	for y in range(-r, r + 1):
		var k := 1.0 - float(y * y) / (ry * ry)
		var w := int(round(rx * sqrt(max(k, 0.0))))
		if w > 0:
			ci.draw_rect(Rect2(int(cx) - w, int(cy) + y, w * 2, 1), col)

## 1px line between two points (Bresenham).
static func line(ci: CanvasItem, a: Vector2, b: Vector2, col: Color) -> void:
	var x0 := int(a.x)
	var y0 := int(a.y)
	var x1 := int(b.x)
	var y1 := int(b.y)
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	while true:
		ci.draw_rect(Rect2(x0, y0, 1, 1), col)
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

## Draws a pattern like ["#..#", ".##."] where "#" is a filled pixel.
static func pattern(ci: CanvasItem, x: float, y: float, rows: Array, col: Color, size := 1) -> void:
	for j in rows.size():
		var row: String = rows[j]
		for i in row.length():
			if row[i] == "#":
				ci.draw_rect(Rect2(int(x) + i * size, int(y) + j * size, size, size), col)

## Tally marks: four lines and a slash, like a prisoner counting days.
static func tally(ci: CanvasItem, x: float, y: float, col: Color) -> void:
	for i in 4:
		rect(ci, x + i * 2, y, 1, 7, col)
	line(ci, Vector2(x - 1, y + 5), Vector2(x + 8, y + 1), col)

const HEART := [
	".##.##.",
	"#######",
	"#######",
	".#####.",
	"..###..",
	"...#...",
]

const COIN := [
	".###.",
	"#####",
	"##.##",
	"#####",
	".###.",
]

const SHIELD := [
	"#####",
	"#####",
	"#####",
	".###.",
	"..#..",
]
