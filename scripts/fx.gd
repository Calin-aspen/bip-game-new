extends Node2D
## Particles (confetti, sparks) and floating text like "+5 COINS".

var font: Font
var parts := []   # each: [pos, vel, color, life, size]
var texts := []   # each: [pos, text, color, life]

func burst(pos: Vector2, col: Color, count := 12, speed := 90.0) -> void:
	for i in count:
		var dir := Vector2.from_angle(randf() * TAU)
		parts.append([pos, dir * randf_range(speed * 0.4, speed) + Vector2(0, -40), col, randf_range(0.4, 0.9), randi_range(1, 2)])

func confetti(pos: Vector2, count := 24) -> void:
	var colors := [Color("#ff5d73"), Color("#ffd23f"), Color("#3bceac"), Color("#5e8bff"), Color("#c77dff")]
	for i in count:
		var v := Vector2(randf_range(-110, 110), randf_range(-170, -60))
		parts.append([pos, v, colors.pick_random(), randf_range(0.8, 1.4), 2])

func float_text(pos: Vector2, text: String, col := Color.WHITE) -> void:
	texts.append([pos, text, col, 1.1])

func _process(delta: float) -> void:
	for p in parts:
		p[1] = p[1] + Vector2(0, 260.0 * delta)
		p[0] = p[0] + p[1] * delta
		p[3] -= delta
	parts = parts.filter(func(p): return p[3] > 0.0)
	for tx in texts:
		tx[0] = tx[0] + Vector2(0, -22.0 * delta)
		tx[3] -= delta
	texts = texts.filter(func(tx): return tx[3] > 0.0)
	queue_redraw()

func _draw() -> void:
	for p in parts:
		Px.rect(self, p[0].x, p[0].y, p[4], p[4], p[2])
	if font == null:
		return
	for tx in texts:
		var pos := Vector2(int(tx[0].x) - 100, int(tx[0].y))
		var col: Color = tx[2]
		col.a = clamp(tx[3] * 2.0, 0.0, 1.0)
		draw_string_outline(font, pos, tx[1], HORIZONTAL_ALIGNMENT_CENTER, 200, 8, 3, Color(0, 0, 0, col.a))
		draw_string(font, pos, tx[1], HORIZONTAL_ALIGNMENT_CENTER, 200, 8, col)
