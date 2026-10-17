class_name UI
## Shared pixel font, theme and button helper for every screen.

static var _font: Font
static var _theme: Theme

static func font() -> Font:
	if _font == null:
		var ff = load("res://fonts/PressStart2P-Regular.ttf")
		if ff is FontFile:
			ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
			ff.hinting = TextServer.HINTING_NONE
			ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
			_font = ff
		else:
			_font = ThemeDB.fallback_font
	return _font

static func theme() -> Theme:
	if _theme == null:
		var th := Theme.new()
		th.default_font = font()
		th.default_font_size = 8
		th.set_stylebox("panel", "PanelContainer", box(Color("#1b1424"), Color("#f4e9d8")))
		th.set_stylebox("normal", "Button", box(Color("#3a2a4a"), Color("#f4e9d8")))
		th.set_stylebox("hover", "Button", box(Color("#5a3f70"), Color("#ffd23f")))
		th.set_stylebox("pressed", "Button", box(Color("#ee3344"), Color("#ffd23f")))
		th.set_stylebox("disabled", "Button", box(Color("#2a2430"), Color("#5a5060")))
		th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
		th.set_color("font_color", "Button", Color("#f4e9d8"))
		th.set_color("font_hover_color", "Button", Color("#ffd23f"))
		th.set_color("font_pressed_color", "Button", Color.WHITE)
		th.set_color("font_disabled_color", "Button", Color("#6a6070"))
		th.set_color("font_color", "Label", Color("#f4e9d8"))
		th.set_constant("line_spacing", "Label", 5)
		_theme = th
	return _theme

static func box(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_content_margin_all(6)
	sb.anti_aliasing = false
	return sb

static func button(text: String, size := Vector2.ZERO) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = size
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func(): Sfx.play("press", 1.3))
	return b

static func label(text: String, col := Color("#f4e9d8")) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", col)
	return l
