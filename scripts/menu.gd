extends Node2D
## Title screen: continue, new game, tutorial, settings, quit.

signal confirm_chosen(index: int)

var room
var bip
var buttons: VBoxContainer
var confirm: PanelContainer
var confirm_label: Label
var confirm_buttons: HBoxContainer
var settings_panel

func _ready() -> void:
	get_tree().paused = false
	var act := Meta.act() if Meta.has_progress() else 1
	room = preload("res://scripts/room.gd").new()
	room.act = act
	add_child(room)
	bip = preload("res://scripts/bip.gd").new()
	bip.act = act
	bip.position = Vector2(150, 178)
	add_child(bip)

	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.theme = UI.theme()
	root.size = Vector2(480, 270)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var title := UI.label("BIP", [Color("#ee3344"), Color("#ee3344"), Color("#c8424c"), Color("#8a1824")][act])
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_outline_color", Color("#1a0b12"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(30, 36)
	title.size = Vector2(240, 36)
	root.add_child(title)
	var sub := UI.label(["", "a game about one big button", "a game about one big button.", "a game about hunger"][act])
	sub.add_theme_constant_override("outline_size", 4)
	sub.add_theme_color_override("font_outline_color", Color("#1a0b12"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 80)
	sub.size = Vector2(300, 12)
	root.add_child(sub)

	buttons = VBoxContainer.new()
	buttons.position = Vector2(306, 74)
	buttons.custom_minimum_size = Vector2(150, 0)
	buttons.add_theme_constant_override("separation", 6)
	root.add_child(buttons)
	if Meta.has_progress():
		var text := "CONTINUE"
		if Meta.data.run is Dictionary:
			text = "CONTINUE (F%d)" % int(Meta.data.run.floor)
		_add(text, _on_continue)
	_add("NEW GAME", _on_new)
	_add("TUTORIAL", _on_tutorial)
	_add("SETTINGS", _on_settings)
	_add("QUIT", func(): get_tree().quit())

	var hint := UI.label("F11 FULLSCREEN", Color("#8a7c9a"))
	hint.position = Vector2(6, 258)
	root.add_child(hint)
	if Meta.data.endings.size() > 0:
		var ends := UI.label("ENDINGS %d/3" % Meta.data.endings.size(), Color("#ffd23f"))
		ends.position = Vector2(378, 258)
		root.add_child(ends)

	confirm = PanelContainer.new()
	confirm.position = Vector2(110, 90)
	confirm.custom_minimum_size = Vector2(260, 0)
	confirm.visible = false
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	confirm_label = UI.label("")
	confirm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_label.custom_minimum_size = Vector2(244, 0)
	confirm_buttons = HBoxContainer.new()
	confirm_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_buttons.add_theme_constant_override("separation", 12)
	cv.add_child(confirm_label)
	cv.add_child(confirm_buttons)
	confirm.add_child(cv)
	root.add_child(confirm)

	settings_panel = preload("res://scripts/settings_panel.gd").new()
	settings_panel.position = Vector2(90, 40)
	settings_panel.closed.connect(func(): buttons.visible = true)
	root.add_child(settings_panel)

func _add(text: String, callback: Callable) -> void:
	var b := UI.button(text)
	b.pressed.connect(callback)
	buttons.add_child(b)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if bip.hit_rect().has_point(event.position):
			bip.press()
			Sfx.play("press", randf_range(0.92, 1.08))
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if settings_panel.visible:
			settings_panel.close()

func ask(text: String, options: Array) -> int:
	confirm_label.text = text
	for c in confirm_buttons.get_children():
		c.queue_free()
	for i in options.size():
		var b := UI.button(options[i])
		b.pressed.connect(func(): confirm_chosen.emit(i))
		confirm_buttons.add_child(b)
	confirm.visible = true
	confirm.reset_size()
	var choice: int = await confirm_chosen
	confirm.visible = false
	return choice

func _start(mode: String, after := "menu") -> void:
	Meta.launch = mode
	Meta.after_tutorial = after
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_continue() -> void:
	_start("continue")

func _on_new() -> void:
	buttons.visible = false
	if Meta.has_progress():
		var c: int = await ask("Start a new game?\nAll story progress will be erased.", ["ERASE", "CANCEL"])
		if c != 0:
			buttons.visible = true
			return
		Meta.reset()
	if not Meta.seen("tutorial"):
		var t: int = await ask("Play the tutorial first?", ["YES", "NO"])
		if t == 0:
			_start("tutorial", "new")
			return
	_start("new")

func _on_tutorial() -> void:
	_start("tutorial", "menu")

func _on_settings() -> void:
	buttons.visible = false
	settings_panel.open()
