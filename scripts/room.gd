extends Node2D
## The room around Bip. It slowly decays as the story moves through the acts.

const W := 480
const H := 270
const FLOOR_Y := 196

var act := 1
var t := 0.0
var door := false    # true ending: a door appears and Tudor lies where Bip was
var confetti := []
var notes := []
var tallies := []

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234   # same layout every time
	var colors := [Color("#ff5d73"), Color("#ffd23f"), Color("#3bceac"), Color("#5e8bff"), Color("#c77dff")]
	for i in 70:
		confetti.append([Vector2(rng.randi_range(0, W), rng.randi_range(20, H)), colors[rng.randi() % colors.size()]])
	for i in 24:
		notes.append(Vector2(rng.randi_range(10, W - 20), rng.randi_range(30, FLOOR_Y - 40)))
	for i in 60:
		tallies.append(Vector2(rng.randi_range(6, W - 16), rng.randi_range(26, FLOOR_Y - 30)))

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	var wall: Color
	var stripe: Color
	var trim: Color
	var floor_col: Color
	var plank: Color
	match act:
		1:
			wall = Color("#f7c5d5"); stripe = Color("#fbd9e4"); trim = Color("#e48aa8")
			floor_col = Color("#d39563"); plank = Color("#b07344")
		2:
			wall = Color("#a49ca8"); stripe = Color("#aea7b1"); trim = Color("#7c7480")
			floor_col = Color("#6f6058"); plank = Color("#584a43")
		_:
			var breath := 0.5 + 0.5 * sin(t * 1.4)
			wall = Color("#3a0e14").lerp(Color("#4d141c"), breath)
			stripe = wall.lightened(0.06); trim = Color("#22070b")
			floor_col = Color("#25080c"); plank = Color("#170406")

	# Wall with vertical wallpaper stripes
	Px.rect(self, 0, 0, W, FLOOR_Y, wall)
	for x in range(0, W, 24):
		Px.rect(self, x, 0, 12, FLOOR_Y, stripe)
	Px.rect(self, 0, FLOOR_Y - 22, W, 3, trim)
	# Wooden floor
	Px.rect(self, 0, FLOOR_Y, W, H - FLOOR_Y, floor_col)
	for row in range(0, H - FLOOR_Y, 12):
		Px.rect(self, 0, FLOOR_Y + row, W, 1, plank)
		var shift := (row / 12) * 17
		for x in range(-40 + shift % 40, W, 40):
			Px.rect(self, x, FLOOR_Y + row, 1, 12, plank)

	match act:
		1: _draw_act1()
		2: _draw_act2(wall)
		_: _draw_act3()
	if door:
		_draw_door()

func _draw_door() -> void:
	# A door that was never there, with warm light behind it
	Px.ellipse(self, 420, 150, 46, 50, Color(1.0, 0.85, 0.5, 0.15))
	Px.rect(self, 398, 104, 44, 92, Color("#3a2414"))
	Px.rect(self, 402, 108, 36, 88, Color("#ffe9a8"))
	Px.rect(self, 402, 108, 36, 30, Color("#bfe8a0"))
	Px.rect(self, 402, 160, 36, 36, Color("#7fc860"))
	# Tudor, curled up asleep where the button used to be
	Px.rect(self, 182, 184, 34, 10, Color("#4a5a8a"))
	Px.ellipse(self, 176, 186, 7, 6, Color("#e0b090"))
	Px.rect(self, 170, 180, 12, 3, Color("#3a2a20"))

func _draw_act1() -> void:
	# One hidden tally mark behind the balloons (the first clue)
	Px.tally(self, 76, 104, Color("#d79ab0"))
	for c in confetti:
		Px.rect(self, c[0].x, c[0].y, 2, 2, c[1])
	_balloon(70, 70, Color("#ff5d73"), 0.0)
	_balloon(92, 88, Color("#ffd23f"), 1.3)
	_balloon(410, 76, Color("#5e8bff"), 2.1)
	_balloon(432, 94, Color("#3bceac"), 0.7)
	# Toy blocks
	Px.rect(self, 380, 182, 14, 14, Color("#ff5d73"))
	Px.rect(self, 395, 182, 14, 14, Color("#5e8bff"))
	Px.rect(self, 387, 168, 14, 14, Color("#ffd23f"))
	Px.rect(self, 60, 186, 20, 10, Color("#c77dff"))

func _draw_act2(wall: Color) -> void:
	for i in 10:
		Px.tally(self, tallies[i].x, tallies[i].y, wall.darkened(0.3))
	for i in 5:
		_note(notes[i])
	# Deflated balloons lying on the floor
	Px.ellipse(self, 80, 198, 9, 3, Color("#9c5560"))
	Px.ellipse(self, 405, 200, 8, 3, Color("#5a6890"))
	Px.rect(self, 380, 186, 12, 10, Color("#7a5a60"))
	# Peeling wallpaper
	Px.rect(self, 300, 40, 18, 26, wall.darkened(0.15))
	Px.rect(self, 140, 120, 10, 30, wall.darkened(0.15))
	# Flickering light
	if fmod(t, 3.7) < 0.09 or fmod(t, 5.3) < 0.05:
		Px.rect(self, 0, 0, W, H, Color(0, 0, 0, 0.35))

func _draw_act3() -> void:
	var vein := Color("#7a1a26")
	for i in 7:
		var x0 := 20.0 + i * 70.0
		var pts := []
		for s in 9:
			var y := s * 22.0
			pts.append(Vector2(x0 + sin(y * 0.05 + i + t) * 8.0, y))
		for s in pts.size() - 1:
			Px.line(self, pts[s], pts[s + 1], vein)
	for tm in tallies:
		Px.tally(self, tm.x, tm.y, Color("#1a0508"))
	for n in notes:
		_note(n)
	# Dark vignette around the edges
	for i in 6:
		var a := 0.12
		Px.rect(self, 0, 0, W, 6 + i * 6, Color(0, 0, 0, a))
		Px.rect(self, 0, H - 6 - i * 6, W, 6 + i * 6, Color(0, 0, 0, a))
		Px.rect(self, 0, 0, 8 + i * 8, H, Color(0, 0, 0, a))
		Px.rect(self, W - 8 - i * 8, 0, 8 + i * 8, H, Color(0, 0, 0, a))

func _balloon(x: float, y: float, col: Color, phase: float) -> void:
	var by := y + sin(t * 1.5 + phase) * 3.0
	Px.line(self, Vector2(x, by + 11), Vector2(x + sin(t + phase) * 2.0, by + 40), Color("#7a5f6a"))
	Px.ellipse(self, x, by, 9, 11, col.darkened(0.25))
	Px.ellipse(self, x, by - 1, 8, 10, col)
	Px.rect(self, x - 4, by - 6, 2, 3, Color(1, 1, 1, 0.7))

func _note(p: Vector2) -> void:
	Px.rect(self, p.x, p.y, 10, 12, Color("#e8e2cf"))
	for r in 4:
		Px.rect(self, p.x + 2, p.y + 2 + r * 2, 6, 1, Color("#8a8370"))
	Px.rect(self, p.x + 4, p.y - 1, 2, 2, Color("#c0392b"))
