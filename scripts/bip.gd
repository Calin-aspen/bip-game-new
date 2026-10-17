extends Node2D
## Bip, the big red button. The origin is the top-center of the pedestal.

var act := 1
var mood := "happy"   # happy, worried, angry, sad, void, calm
var talking := false
var press_t := 0.0
var blink_t := 3.0
var glitch_t := 0.0
var shake_t := 0.0
var t := 0.0

func press() -> void:
	press_t = 0.12

func shake(time := 0.3) -> void:
	shake_t = time

func hit_rect() -> Rect2:
	return Rect2(global_position + Vector2(-42, -50), Vector2(84, 72))

func _process(delta: float) -> void:
	t += delta
	press_t = max(press_t - delta, 0.0)
	shake_t = max(shake_t - delta, 0.0)
	glitch_t = max(glitch_t - delta, 0.0)
	blink_t -= delta
	if blink_t < -0.12:
		blink_t = randf_range(2.0, 5.0)
	# The "something is wrong" glitch: eyes go black for a frame or two
	var glitch_chance: float = [0.0, 0.0012, 0.004, 0.0][act]
	if randf() < glitch_chance:
		glitch_t = 0.05 if act == 1 else 0.15
	queue_redraw()

func _draw() -> void:
	var off := Vector2.ZERO
	if shake_t > 0.0 or mood == "angry":
		off = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	var base: Color
	var dark: Color
	var light: Color
	match act:
		1: base = Color("#ee3344"); dark = Color("#a3162a"); light = Color("#ff8a8a")
		2: base = Color("#c8424c"); dark = Color("#882030"); light = Color("#e08a8a")
		_: base = Color("#8a1824"); dark = Color("#4e0a12"); light = Color("#b04450")
	var outline := Color("#1a0b12")
	var p := 5 if press_t > 0.0 else 0
	var cx := off.x
	var cy := -12.0 + p + off.y

	# Shadow
	Px.ellipse(self, 0, 18, 46, 4, Color(0, 0, 0, 0.25))
	# Dome: outline, shade, main color, highlight
	Px.ellipse(self, cx, cy, 33, 25, outline)
	Px.ellipse(self, cx, cy, 32, 24, dark)
	Px.ellipse(self, cx, cy - 3, 30, 20, base)
	Px.ellipse(self, cx - 13, cy - 14, 7, 3, light)
	Px.rect(self, cx - 17, cy - 16, 3, 2, Color(1, 1, 1, 0.9))

	_draw_face(cx, cy)

	if act >= 3:
		var crack := Color("#26040a")
		Px.line(self, Vector2(cx + 8, cy - 21), Vector2(cx + 14, cy - 12), crack)
		Px.line(self, Vector2(cx + 14, cy - 12), Vector2(cx + 11, cy - 4), crack)
		Px.line(self, Vector2(cx - 20, cy - 8), Vector2(cx - 15, cy + 2), crack)

	# Metal pedestal
	Px.rect(self, -41, 1, 82, 18, outline)
	Px.rect(self, -40, 2, 80, 16, Color("#454560") if act < 3 else Color("#2c2433"))
	Px.rect(self, -40, 2, 80, 3, Color("#6a6a8c") if act < 3 else Color("#3e3346"))
	for x in [-34, 32]:
		Px.rect(self, x, 9, 2, 2, Color("#9a9ab8"))

func _draw_face(fx: float, fy: float) -> void:
	var ink := Color("#1a0b12")
	var eye_y := fy - 6
	for side in [-1, 1]:
		var ex: float = fx + side * 10
		if glitch_t > 0.0 or mood == "void":
			Px.rect(self, ex - 3, eye_y - 4, 7, 9, Color.BLACK)
		elif blink_t < 0.0 or mood == "calm":
			Px.rect(self, ex - 3, eye_y + 1, 7, 1, ink)
		else:
			var white := Color("#fff8f0") if act < 3 else Color("#d9c3c3")
			Px.rect(self, ex - 3, eye_y - 4, 7, 9, white)
			var look := 0 if act < 3 else int(sin(t * 0.7) * 2)
			var psize := 3 if act < 3 else 2
			Px.rect(self, ex - 1 + look, eye_y - 1, psize, psize + 1, ink)
		# Eyebrows
		if mood == "worried" or mood == "sad":
			Px.line(self, Vector2(ex - 3, eye_y - 6 + (side + 1)), Vector2(ex + 3, eye_y - 6 + (1 - side)), ink)
		elif mood == "angry":
			Px.line(self, Vector2(ex - 3, eye_y - 7 + (1 - side)), Vector2(ex + 3, eye_y - 7 + (side + 1)), ink)

	var my := fy + 5
	if talking and fmod(t, 0.2) < 0.1:
		Px.rect(self, fx - 4, my, 9, 5, ink)
		Px.rect(self, fx - 2, my + 3, 5, 2, Color("#ff7a8a"))
	elif act >= 3 and mood != "calm":
		Px.rect(self, fx - 7, my, 15, 4, ink)
		for i in range(0, 14, 3):
			Px.rect(self, fx - 6 + i, my, 2, 2, Color("#e8dccc"))
	elif mood == "sad" or mood == "worried":
		Px.pattern(self, fx - 4, my + 1, ["..###..", ".#...#.", "#.....#"], ink)
	elif mood == "calm":
		Px.rect(self, fx - 3, my + 2, 7, 1, ink)
	else:
		Px.pattern(self, fx - 5, my, ["#.........#", ".#.......#.", "..#######.."], ink)
		if act == 1:
			Px.rect(self, fx - 15, my - 1, 4, 2, Color("#ff9aa8"))
			Px.rect(self, fx + 12, my - 1, 4, 2, Color("#ff9aa8"))
