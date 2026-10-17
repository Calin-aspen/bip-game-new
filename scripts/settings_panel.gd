extends PanelContainer
## Settings window, used both in the main menu and in the pause menu.

signal closed

var values := {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	custom_minimum_size = Vector2(300, 0)
	visible = false
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	add_child(vb)
	var title := UI.label("SETTINGS", Color("#ffd23f"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	_row(vb, "VOLUME", "master")
	_row(vb, "VOICES", "voice")
	_row(vb, "EFFECTS", "sfx")
	_row(vb, "TEXT SPEED", "text")
	_row(vb, "SCREEN SHAKE", "shake")
	_row(vb, "FULLSCREEN", "full")
	var back := UI.button("BACK")
	back.pressed.connect(close)
	vb.add_child(back)

func _row(parent: Control, text: String, key: String) -> void:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 4)
	var l := UI.label(text)
	l.custom_minimum_size = Vector2(120, 0)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var minus := UI.button("<", Vector2(24, 0))
	var val := UI.label("", Color("#ffd23f"))
	val.custom_minimum_size = Vector2(80, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var plus := UI.button(">", Vector2(24, 0))
	minus.pressed.connect(_change.bind(key, -1))
	plus.pressed.connect(_change.bind(key, 1))
	for n in [l, minus, val, plus]:
		hb.add_child(n)
	parent.add_child(hb)
	values[key] = val

func _change(key: String, dir: int) -> void:
	match key:
		"master": Settings.master = clampf(snappedf(Settings.master + dir * 0.1, 0.1), 0.0, 1.0)
		"voice": Settings.voice = clampf(snappedf(Settings.voice + dir * 0.1, 0.1), 0.0, 1.0)
		"sfx": Settings.sfx = clampf(snappedf(Settings.sfx + dir * 0.1, 0.1), 0.0, 1.0)
		"text": Settings.text_speed = wrapi(Settings.text_speed + dir, 0, Settings.TEXT_SPEEDS.size())
		"shake": Settings.shake = not Settings.shake
		"full": Settings.fullscreen = not Settings.fullscreen
	Settings.apply()
	# Let the player hear the new volume right away
	if key == "voice":
		Sfx.play("blip")
	elif key == "sfx" or key == "master":
		Sfx.play("coin")
	_refresh()

func _refresh() -> void:
	values["master"].text = "%d%%" % roundi(Settings.master * 100)
	values["voice"].text = "%d%%" % roundi(Settings.voice * 100)
	values["sfx"].text = "%d%%" % roundi(Settings.sfx * 100)
	values["text"].text = Settings.TEXT_SPEED_NAMES[Settings.text_speed]
	values["shake"].text = "ON" if Settings.shake else "OFF"
	values["full"].text = "ON" if Settings.fullscreen else "OFF"

func open() -> void:
	_refresh()
	visible = true
	reset_size()

func close() -> void:
	Settings.save_settings()
	visible = false
	closed.emit()
