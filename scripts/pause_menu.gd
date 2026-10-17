extends PanelContainer
## ESC pause menu: resume, settings, quit to the main menu.

signal quit_requested

var settings_panel
var hint: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	position = Vector2(140, 56)
	custom_minimum_size = Vector2(200, 0)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	add_child(vb)
	var title := UI.label("PAUSED", Color("#ffd23f"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var resume_btn := UI.button("RESUME")
	resume_btn.pressed.connect(resume)
	vb.add_child(resume_btn)
	var settings_btn := UI.button("SETTINGS")
	settings_btn.pressed.connect(_open_settings)
	vb.add_child(settings_btn)
	var quit_btn := UI.button("QUIT TO MENU")
	quit_btn.pressed.connect(func(): quit_requested.emit())
	vb.add_child(quit_btn)
	hint = UI.label("Your run is saved at the start of every room.", Color("#a89cb8"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(184, 0)
	vb.add_child(hint)

func setup(panel) -> void:
	settings_panel = panel
	panel.closed.connect(func():
		if get_tree().paused:
			visible = true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		if settings_panel and settings_panel.visible:
			settings_panel.close()
		elif visible:
			resume()
		else:
			open()

func open() -> void:
	visible = true
	reset_size()
	get_tree().paused = true

func resume() -> void:
	visible = false
	get_tree().paused = false

func _open_settings() -> void:
	visible = false
	settings_panel.open()
