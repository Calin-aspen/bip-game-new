extends Node
## Player settings (autoload "Settings"), saved to user://settings.cfg.
## F11 or Alt+Enter toggles fullscreen anywhere in the game.

const PATH := "user://settings.cfg"
const TEXT_SPEEDS := [22.0, 40.0, 75.0]   # characters per second
const TEXT_SPEED_NAMES := ["SLOW", "NORMAL", "FAST"]

var master := 0.8
var voice := 0.8
var sfx := 0.8
var text_speed := 1
var shake := true
var fullscreen := true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		master = cfg.get_value("audio", "master", master)
		voice = cfg.get_value("audio", "voice", voice)
		sfx = cfg.get_value("audio", "sfx", sfx)
		text_speed = cfg.get_value("game", "text_speed", text_speed)
		shake = cfg.get_value("game", "shake", shake)
		fullscreen = cfg.get_value("video", "fullscreen", fullscreen)
	apply()

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master)
	cfg.set_value("audio", "voice", voice)
	cfg.set_value("audio", "sfx", sfx)
	cfg.set_value("game", "text_speed", text_speed)
	cfg.set_value("game", "shake", shake)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.save(PATH)

func apply() -> void:
	AudioServer.set_bus_mute(0, master <= 0.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master, 0.001)))
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)

func chars_per_second() -> float:
	return TEXT_SPEEDS[clampi(text_speed, 0, TEXT_SPEEDS.size() - 1)]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
			fullscreen = not fullscreen
			apply()
			save_settings()
			get_viewport().set_input_as_handled()
