extends Node
## Persistent progress between runs (autoload "Meta").

const SAVE_PATH := "user://save.json"

# When the story moves to the next act (tweak these to pace the story).
const ACT2_RUN := 4          # act 2 starts on run 4...
const ACT2_PRESSES := 250    # ...or after this many total presses
const ACT3_RUN := 8
const ACT3_PRESSES := 600
const HAMMER_PIECES := 7
const SILENCES_NEEDED := 3

var data := {}

# How the game scene should start (set by the main menu)
var launch := "continue"        # "new", "continue" or "tutorial"
var after_tutorial := "menu"    # "menu" or "new"

func _ready() -> void:
	load_game()

func defaults() -> Dictionary:
	return {
		"runs": 0,
		"deaths": 0,
		"wins": 0,
		"total_presses": 0,
		"notes_found": [],
		"hammer": 0,
		"silences": 0,
		"endings": [],
		"seen": [],          # one-time story beats already shown
		"forced_act": 0,     # debug override (F1-F3)
		"run": null,         # the run in progress, saved at the start of every room
	}

func has_progress() -> bool:
	return int(data.runs) > 0

func load_game() -> void:
	data = defaults()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		for k in parsed:
			data[k] = parsed[k]

func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))

func reset() -> void:
	data = defaults()
	save_game()

func act() -> int:
	if int(data.forced_act) > 0:
		return int(data.forced_act)
	var runs := int(data.runs)
	var presses := int(data.total_presses)
	if runs >= ACT3_RUN or presses >= ACT3_PRESSES:
		return 3
	if runs >= ACT2_RUN or presses >= ACT2_PRESSES:
		return 2
	return 1

func seen(key: String) -> bool:
	return key in data.seen

func mark_seen(key: String) -> void:
	if not seen(key):
		data.seen.append(key)
		save_game()
