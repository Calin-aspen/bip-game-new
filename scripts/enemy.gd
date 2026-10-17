extends Node2D
## A monster or boss. The origin is where its feet touch the floor.

var kind := "slime"     # slime, bat, sock, plush, other, hunger
var display_name := ""
var hp := 1
var max_hp := 1
var bar_ratio := -1.0   # time left (fights) or attack charge (bosses); -1 hides it
var warn := false       # flashes red right before a boss attack
var flash_t := 0.0
var shake_t := 0.0
var t := 0.0
var font: Font

func hit() -> void:
	flash_t = 0.07
	shake_t = 0.12

func _process(delta: float) -> void:
	t += delta
	flash_t = max(flash_t - delta, 0.0)
	shake_t = max(shake_t - delta, 0.0)
	queue_redraw()

## Hit flash turns everything white; the attack warning blinks red.
func c(col: Color) -> Color:
	if flash_t > 0.0:
		return Color.WHITE
	if warn and fmod(t, 0.16) < 0.08:
		return col.lerp(Color("#ff2020"), 0.6)
	return col

func _draw() -> void:
	var o := Vector2.ZERO
	if shake_t > 0.0:
		o = Vector2(randi_range(-2, 2), randi_range(-1, 1))
	var top := 24.0
	match kind:
		"slime":
			var squish := sin(t * 6.0) * 1.5
			Px.ellipse(self, o.x, o.y - 9, 15 + squish, 10 - squish, c(Color("#1f5a2a")))
			Px.ellipse(self, o.x, o.y - 10, 14 + squish, 9 - squish, c(Color("#5fd35f")))
			Px.rect(self, o.x - 6, o.y - 13, 3, 4, c(Color.BLACK))
			Px.rect(self, o.x + 3, o.y - 13, 3, 4, c(Color.BLACK))
			top = 22
		"bat":
			var fy := o.y - 34 + sin(t * 4.0) * 4.0
			var flap := 4 if fmod(t, 0.25) < 0.125 else -2
			Px.line(self, Vector2(o.x - 6, fy), Vector2(o.x - 20, fy - flap), c(Color("#3a2050")))
			Px.line(self, Vector2(o.x - 20, fy - flap), Vector2(o.x - 6, fy + 4), c(Color("#3a2050")))
			Px.line(self, Vector2(o.x + 6, fy), Vector2(o.x + 20, fy - flap), c(Color("#3a2050")))
			Px.line(self, Vector2(o.x + 20, fy - flap), Vector2(o.x + 6, fy + 4), c(Color("#3a2050")))
			Px.ellipse(self, o.x, fy, 8, 7, c(Color("#6b3fa0")))
			Px.rect(self, o.x - 4, fy - 2, 2, 2, c(Color("#ffe040")))
			Px.rect(self, o.x + 2, fy - 2, 2, 2, c(Color("#ffe040")))
			top = 48
		"sock":
			Px.rect(self, o.x - 7, o.y - 34, 14, 26, c(Color("#e8e0d0")))
			Px.rect(self, o.x - 7, o.y - 12, 22, 12, c(Color("#e8e0d0")))
			Px.rect(self, o.x - 7, o.y - 34, 14, 4, c(Color("#d04040")))
			Px.rect(self, o.x - 4, o.y - 26, 3, 3, c(Color.BLACK))
			Px.rect(self, o.x + 2, o.y - 26, 3, 3, c(Color.BLACK))
			Px.rect(self, o.x - 3, o.y - 20, 7, 2, c(Color.BLACK))
			top = 40
		"plush":
			var bob := sin(t * 2.0) * 2.0
			var fur := Color("#a0683c")
			var fur_d := Color("#6e4424")
			Px.ellipse(self, o.x, o.y - 26 + bob, 26, 26, c(fur_d))
			Px.ellipse(self, o.x, o.y - 27 + bob, 25, 25, c(fur))
			Px.ellipse(self, o.x, o.y - 22 + bob, 14, 14, c(Color("#d8a878")))
			var hy := o.y - 62 + bob
			Px.ellipse(self, o.x - 15, hy - 12, 7, 7, c(fur_d))
			Px.ellipse(self, o.x + 15, hy - 12, 7, 7, c(fur_d))
			Px.ellipse(self, o.x, hy, 19, 16, c(fur))
			Px.ellipse(self, o.x, hy + 5, 8, 6, c(Color("#d8a878")))
			Px.rect(self, o.x - 2, hy + 2, 5, 3, c(Color.BLACK))
			Px.rect(self, o.x - 9, hy - 5, 4, 4, c(Color.BLACK))
			Px.rect(self, o.x + 6, hy - 5, 4, 4, c(Color.BLACK))
			# Stitches
			Px.line(self, Vector2(o.x - 1, hy + 9), Vector2(o.x - 1, hy + 14), c(fur_d))
			top = 82
		"other":
			var press_y := 3 if fmod(t, 0.8) < 0.3 else 0
			var grey := Color("#7a7a82")
			Px.rect(self, o.x - 9, o.y - 44, 18, 44, c(Color("#55555c")))
			Px.rect(self, o.x - 8, o.y - 43, 16, 42, c(grey))
			Px.ellipse(self, o.x, o.y - 54, 9, 10, c(grey))
			Px.rect(self, o.x - 5, o.y - 57, 3, 4, c(Color.BLACK))
			Px.rect(self, o.x + 2, o.y - 57, 3, 4, c(Color.BLACK))
			Px.rect(self, o.x - 2, o.y - 49, 4, 3, c(Color.BLACK))
			# Arm endlessly pressing an invisible button
			Px.rect(self, o.x - 22, o.y - 38 + press_y, 14, 4, c(grey))
			Px.rect(self, o.x - 24, o.y - 38 + press_y, 4, 8, c(grey))
			top = 70
		"hunger":
			var open := 14.0 + sin(t * 2.5) * 6.0
			var cy := o.y - 30
			Px.ellipse(self, o.x, cy, 50, 30, c(Color("#050102")))
			Px.ellipse(self, o.x, cy, 42, open, c(Color("#9b1020")))
			Px.ellipse(self, o.x, cy + open * 0.4, 20, open * 0.35, c(Color("#d84a5a")))
			for i in range(-36, 37, 8):
				var edge := sqrt(max(1.0 - float(i * i) / (42.0 * 42.0), 0.0)) * open
				Px.rect(self, o.x + i - 2, cy - edge, 5, 6, c(Color("#efe6d2")))
				Px.rect(self, o.x + i + 2, cy + edge - 6, 5, 6, c(Color("#efe6d2")))
			top = 66
	_draw_bars(top)

func _draw_bars(top: float) -> void:
	var w := 50
	var y := -top - 14
	if font and display_name != "":
		draw_string_outline(font, Vector2(-60, y - 3), display_name, HORIZONTAL_ALIGNMENT_CENTER, 120, 8, 2, Color.BLACK)
		draw_string(font, Vector2(-60, y - 3), display_name, HORIZONTAL_ALIGNMENT_CENTER, 120, 8, Color.WHITE)
	Px.rect(self, -w / 2 - 1, y - 1, w + 2, 6, Color.BLACK)
	Px.rect(self, -w / 2, y, w, 4, Color("#3a1010"))
	Px.rect(self, -w / 2, y, w * float(hp) / max(max_hp, 1), 4, Color("#ff3b3b"))
	if bar_ratio >= 0.0:
		Px.rect(self, -w / 2 - 1, y + 6, w + 2, 4, Color.BLACK)
		var col := Color("#ffd23f") if not warn else Color("#ff7a20")
		Px.rect(self, -w / 2, y + 7, w * clamp(bar_ratio, 0.0, 1.0), 2, col)
