extends Node2D
## Top bar: hearts, shields, coins, tension, floor and total presses.

const INK := Color("#f4e9d8")

var font: Font
var hp := 3
var max_hp := 3
var shield := 0
var coins := 0
var tension := 0.0
var act := 1
var where := ""
var total := 0
var peek := ""
var hammer := 0
var show_tension := false

# Tutorial pointer: a blinking arrow whose tip touches arrow_pos
var arrow_on := false
var arrow_pos := Vector2.ZERO
var arrow_up := false

const ARROW_DOWN := [
	"..###..",
	"..###..",
	"..###..",
	"#######",
	".#####.",
	"..###..",
	"...#...",
]

func _process(_delta: float) -> void:
	queue_redraw()

func _text(pos: Vector2, s: String, col := INK, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	draw_string_outline(font, pos, s, align, width, 8, 2, Color.BLACK)
	draw_string(font, pos, s, align, width, 8, col)

func _draw() -> void:
	if font == null:
		return
	Px.rect(self, 0, 0, 480, 20, Color(0, 0, 0, 0.6))
	var x := 6
	for i in max_hp:
		Px.pattern(self, x, 7, Px.HEART, Color("#ff3b4f") if i < hp else Color("#4a3a44"))
		x += 9
	for i in shield:
		Px.pattern(self, x, 7, Px.SHIELD, Color("#6ec6ff"))
		x += 7
	x += 6
	Px.pattern(self, x, 7, Px.COIN, Color("#ffd23f"))
	_text(Vector2(x + 8, 14), str(coins))

	if show_tension:
		var word: String = ["FUN", "FUN", "TENSION", "HUNGER"][act]
		_text(Vector2(150, 14), word)
		var bx := 150 + word.length() * 8 + 6
		Px.rect(self, bx - 1, 6, 82, 10, Color.BLACK)
		var col := Color("#3bceac").lerp(Color("#ffd23f"), clampf(tension / 50.0, 0.0, 1.0))
		if tension > 50.0:
			col = Color("#ffd23f").lerp(Color("#ff3b3b"), clampf((tension - 50.0) / 50.0, 0.0, 1.0))
		Px.rect(self, bx, 7, 80.0 * tension / 100.0, 8, col)

	_text(Vector2(274, 14), where, INK, HORIZONTAL_ALIGNMENT_RIGHT, 200)
	_text(Vector2(274, 32), "PRESSES %d" % total, Color("#a89cb8"), HORIZONTAL_ALIGNMENT_RIGHT, 200)
	if hammer > 0:
		_text(Vector2(274, 44), "HAMMER %d/%d" % [hammer, Meta.HAMMER_PIECES], Color("#c0c0d0"), HORIZONTAL_ALIGNMENT_RIGHT, 200)
	if peek != "":
		_text(Vector2(6, 32), "NEXT: " + peek, Color("#ffd23f"))
	if arrow_on:
		_draw_arrow()

func _draw_arrow() -> void:
	var bob := int(abs(sin(Time.get_ticks_msec() / 150.0)) * 4.0)
	var rows: Array = ARROW_DOWN.duplicate()
	var pos := Vector2(arrow_pos.x - 3, arrow_pos.y - 7 - bob)
	if arrow_up:
		rows.reverse()
		pos = Vector2(arrow_pos.x - 3, arrow_pos.y + bob)
	for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		Px.pattern(self, pos.x + o.x, pos.y + o.y, rows, Color.BLACK)
	Px.pattern(self, pos.x, pos.y, rows, Color("#ffd23f"))
