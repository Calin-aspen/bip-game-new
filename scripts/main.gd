extends Node2D
## The whole game flow: runs, stages, events, fights, shop, story and endings.
##
## Controls: click Bip or press SPACE/ENTER. ESC pauses. F11 or Alt+Enter toggles fullscreen.
## Debug keys: F1/F2/F3 force act 1/2/3, F6 back to normal story,
##             F4 wipe the save, F5 give all hammer pieces.

signal advanced
signal fight_done(won: bool)
signal popup_chosen(index: int)
signal bip_pressed
signal stage_finished

enum S { BUSY, DIALOGUE, STAGE, FIGHT, BOSS, CHOICE, SHOP, OVER }

const BIP_POS := Vector2(200, 176)
const ENEMY_POS := Vector2(362, 196)
const FLOORS := 3
const FLOOR_PLAN := ["stage", "stage", "shop", "stage", "boss"]
const BOSSES := ["plush", "other", "hunger"]
const BOSS_NAMES := {"plush": "MR. PLUSH", "other": "THE OTHER", "hunger": "THE HUNGER"}
const BOSS_HP := [26, 38, 52]
const BOSS_SPEED := [3.0, 2.5, 2.1]   # seconds between boss attacks
const MONSTERS := [["slime", "SLIME"], ["bat", "BAT"], ["sock", "LOST SOCK"]]

# id: [name, description, price, can be bought again]
const UPGRADES := {
	"glove": ["Lucky Glove", "20% chance to dodge bombs, thieves and hunger pangs.", 25, false],
	"golden": ["Golden Button", "+1 coin every time you press.", 20, false],
	"glass": ["Glass Shield", "Blocks one hit, then shatters.", 12, true],
	"ice": ["Ice Cube", "Tension rises 35% slower.", 22, false],
	"cursed": ["Cursed Grin", "Coin gifts x2. Bombs hit twice as hard.", 25, false],
	"peek": ["Peephole", "See what the next press will do.", 28, false],
	"spare": ["Spare Heart", "+1 max heart.", 30, false],
	"finger": ["Strong Finger", "Double damage to monsters and bosses.", 24, false],
}

const EVENT_NAMES := {
	"coins": "COINS", "jackpot": "JACKPOT!", "heart": "HEART", "shield": "SHIELD",
	"bomb": "BOMB", "thief": "THIEF", "pang": "PANG", "calm": "CALM",
	"monster": "MONSTER", "stranger": "STRANGER", "gamble": "GAMBLE",
	"nothing": "NOTHING", "note": "A NOTE", "hammer": "???",
}

var font: Font
var world: Node2D
var room
var bip
var enemy
var fx
var hud

var flash: ColorRect
var fade: ColorRect
var stop_btn: Button
var smash_btn: Button
var dialog_panel: PanelContainer
var dialog_label: Label
var dialog_more: Label
var popup: PanelContainer
var popup_title: Label
var popup_body: Label
var popup_buttons: HBoxContainer
var shop: PanelContainer
var shop_list: VBoxContainer
var shop_desc: Label
var shop_coins: Label
var pause_menu
var settings_panel

# Tutorial: events are scripted instead of random, and you can't die
var tutorial := false
var tut_queue := []

var state: S = S.BUSY
var act := 1

# Current run
var hp := 3
var max_hp := 3
var shield := 0
var coins := 0
var tension := 0.0
var floor_n := 1
var step_i := 0
var owned := {}
var run_presses := 0
var stage_presses := 0
var min_presses := 4
var next_event := "nothing"
var hammers_this_run := 0
var silence_done := false

# Timers
var idle_t := 0.0
var idle_said := false
var silence_i := 0
var enemy_time := 0.0
var enemy_time_max := 1.0
var boss_attack_t := 0.0
var shake_t := 0.0
var mood_t := 0.0

# Dialogue box
var blocking := false
var narrating := false
var type_pos := 0.0
var box_hide_t := 0.0

# ---------------------------------------------------------------- setup

func _ready() -> void:
	randomize()
	get_tree().paused = false
	font = UI.font()
	_build_world()
	_build_ui()
	match Meta.launch:
		"tutorial":
			run_tutorial()
		"continue":
			if Meta.data.run is Dictionary:
				continue_run()
			else:
				start_run()
		_:
			start_run()

func _build_world() -> void:
	world = Node2D.new()
	add_child(world)
	room = preload("res://scripts/room.gd").new()
	world.add_child(room)
	bip = preload("res://scripts/bip.gd").new()
	bip.position = BIP_POS
	world.add_child(bip)
	enemy = preload("res://scripts/enemy.gd").new()
	enemy.position = ENEMY_POS
	enemy.font = font
	enemy.visible = false
	world.add_child(enemy)
	fx = preload("res://scripts/fx.gd").new()
	fx.font = font
	world.add_child(fx)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = preload("res://scripts/hud.gd").new()
	hud.font = font
	layer.add_child(hud)

	var root := Control.new()
	root.theme = UI.theme()
	root.size = Vector2(480, 270)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	flash = _rect(Color(1, 0.1, 0.1, 0))
	root.add_child(flash)

	stop_btn = _button("STOP", Vector2(388, 112), Vector2(84, 22))
	stop_btn.pressed.connect(_on_stop)
	stop_btn.visible = false
	root.add_child(stop_btn)
	smash_btn = _button("SMASH", Vector2(388, 140), Vector2(84, 22))
	smash_btn.pressed.connect(_on_smash)
	smash_btn.visible = false
	root.add_child(smash_btn)

	fade = _rect(Color(0, 0, 0, 0))
	root.add_child(fade)

	dialog_panel = PanelContainer.new()
	dialog_panel.position = Vector2(6, 206)
	dialog_panel.custom_minimum_size = Vector2(468, 58)
	dialog_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog_panel.visible = false
	dialog_label = Label.new()
	dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_label.custom_minimum_size = Vector2(452, 40)
	dialog_label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	dialog_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog_panel.add_child(dialog_label)
	root.add_child(dialog_panel)
	dialog_more = Label.new()
	dialog_more.text = ">"
	dialog_more.position = Vector2(458, 250)
	dialog_more.add_theme_color_override("font_color", Color("#ffd23f"))
	dialog_more.visible = false
	root.add_child(dialog_more)

	popup = PanelContainer.new()
	popup.position = Vector2(90, 46)
	popup.custom_minimum_size = Vector2(300, 0)
	popup.visible = false
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 10)
	popup_title = Label.new()
	popup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_title.add_theme_color_override("font_color", Color("#ffd23f"))
	popup_body = Label.new()
	popup_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_body.custom_minimum_size = Vector2(284, 0)
	popup_buttons = HBoxContainer.new()
	popup_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	popup_buttons.add_theme_constant_override("separation", 12)
	pv.add_child(popup_title)
	pv.add_child(popup_body)
	pv.add_child(popup_buttons)
	popup.add_child(pv)
	root.add_child(popup)

	shop = PanelContainer.new()
	shop.position = Vector2(96, 26)
	shop.custom_minimum_size = Vector2(288, 0)
	shop.visible = false
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 6)
	var st := Label.new()
	st.text = "BIP'S SHOP"
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	st.add_theme_color_override("font_color", Color("#ffd23f"))
	shop_coins = Label.new()
	shop_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_list = VBoxContainer.new()
	shop_list.add_theme_constant_override("separation", 4)
	shop_desc = Label.new()
	shop_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_desc.custom_minimum_size = Vector2(272, 30)
	shop_desc.add_theme_color_override("font_color", Color("#a89cb8"))
	for n in [st, shop_coins, shop_list, shop_desc]:
		sv.add_child(n)
	shop.add_child(sv)
	root.add_child(shop)

	settings_panel = preload("res://scripts/settings_panel.gd").new()
	settings_panel.position = Vector2(90, 40)
	root.add_child(settings_panel)
	pause_menu = preload("res://scripts/pause_menu.gd").new()
	root.add_child(pause_menu)
	pause_menu.setup(settings_panel)
	pause_menu.quit_requested.connect(_quit_to_menu)

func _rect(col: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = col
	r.size = Vector2(480, 270)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

func _button(text: String, pos: Vector2, size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.custom_minimum_size = size
	b.focus_mode = Control.FOCUS_NONE
	return b

# ---------------------------------------------------------------- input & loop

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F1, KEY_F2, KEY_F3:
				Meta.data.forced_act = event.keycode - KEY_F1 + 1
				Meta.save_game()
				get_tree().reload_current_scene()
				return
			KEY_F6:
				Meta.data.forced_act = 0
				Meta.save_game()
				get_tree().reload_current_scene()
				return
			KEY_F4:
				Meta.reset()
				get_tree().reload_current_scene()
				return
			KEY_F5:
				Meta.data.hammer = Meta.HAMMER_PIECES
				Meta.save_game()
				fx.float_text(Vector2(240, 60), "DEBUG: ALL HAMMER PIECES", Color("#ffd23f"))
				return

	var pressed := false
	if event is InputEventKey and event.pressed and not event.echo:
		pressed = event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = state == S.DIALOGUE or bip.hit_rect().has_point(event.position)
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	match state:
		S.DIALOGUE: _advance_dialogue()
		S.STAGE: stage_press()
		S.FIGHT, S.BOSS: attack_enemy()

func _process(delta: float) -> void:
	_update_dialogue(delta)
	if shake_t > 0.0:
		shake_t -= delta
		if Settings.shake:
			world.position = Vector2(randi_range(-2, 2), randi_range(-2, 2))
	else:
		world.position = Vector2.ZERO
	var fc := flash.color
	fc.a = maxf(fc.a - delta * 2.0, 0.0)
	flash.color = fc
	if mood_t > 0.0:
		mood_t -= delta
		if mood_t <= 0.0:
			bip.mood = "happy"

	match state:
		S.STAGE:
			_idle_tick(delta)
		S.FIGHT:
			enemy_time -= delta
			enemy.bar_ratio = enemy_time / enemy_time_max
			if enemy_time <= 0.0:
				state = S.BUSY
				fight_done.emit(false)
		S.BOSS:
			var speed: float = BOSS_SPEED[floor_n - 1]
			boss_attack_t -= delta
			enemy.bar_ratio = 1.0 - boss_attack_t / speed
			enemy.warn = boss_attack_t < 0.6
			if boss_attack_t <= 0.0:
				boss_attack_t = speed
				fx.burst(bip.global_position + Vector2(0, -20), Color("#ff3b3b"), 14, 110)
				damage(1)
				if state == S.OVER:
					fight_done.emit(false)
	_update_hud()

func _update_hud() -> void:
	hud.hp = hp
	hud.max_hp = max_hp
	hud.shield = shield
	hud.coins = coins
	hud.tension = tension
	hud.act = act
	hud.where = "TUTORIAL" if tutorial else "FLOOR %d-%d" % [floor_n, step_i]
	hud.total = int(Meta.data.total_presses)
	hud.hammer = int(Meta.data.hammer)
	hud.show_tension = state == S.STAGE or tension > 0.0
	hud.peek = EVENT_NAMES[next_event] if owned.has("peek") and state == S.STAGE else ""
	if shop.visible:
		shop_coins.text = "COINS: %d" % coins

func _wait(time: float) -> void:
	await get_tree().create_timer(time, false).timeout   # false = stops while paused

func _fade_to(alpha: float, time: float, col := Color.BLACK) -> void:
	var tw := create_tween()
	tw.tween_property(fade, "color", Color(col.r, col.g, col.b, alpha), time)
	await tw.finished

func set_mood(m: String, time: float) -> void:
	bip.mood = m
	mood_t = time

func tension_word() -> String:
	return ["FUN", "FUN", "TENSION", "HUNGER"][act]

# ---------------------------------------------------------------- dialogue

func _show_line(text: String) -> void:
	narrating = text.begins_with("*")
	var shown := text.trim_prefix("*").strip_edges()
	dialog_label.text = shown if narrating else "\"%s\"" % shown
	dialog_label.add_theme_color_override("font_color", Color("#b8a8e0") if narrating else Color("#f4e9d8"))
	dialog_label.visible_characters = 0
	type_pos = 0.0
	box_hide_t = 2.2 + text.length() * 0.03
	dialog_panel.visible = true

## Bip says something without stopping the game.
func say(text: String) -> void:
	if blocking or text == "":
		return
	_show_line(text)
	if tutorial:
		box_hide_t = 600.0   # tutorial instructions stay on screen

## Plays lines one by one; the player clicks / presses SPACE to continue.
func say_block(lines: Array) -> void:
	var prev := state
	state = S.DIALOGUE
	blocking = true
	for line in lines:
		_show_line(line)
		await advanced
	blocking = false
	dialog_panel.visible = false
	bip.talking = false
	state = prev

func _advance_dialogue() -> void:
	var total := dialog_label.get_total_character_count()
	if dialog_label.visible_characters < total:
		dialog_label.visible_characters = total
	else:
		advanced.emit()

func _update_dialogue(delta: float) -> void:
	dialog_more.visible = false
	if not dialog_panel.visible:
		bip.talking = false
		return
	var total := dialog_label.get_total_character_count()
	if dialog_label.visible_characters < total:
		type_pos += delta * Settings.chars_per_second()
		var n := mini(int(type_pos), total)
		if n != dialog_label.visible_characters:
			var low := 0.8 if act == 3 else 1.0
			if narrating and n % 3 == 0:
				Sfx.play("narrate", randf_range(0.97, 1.03) * low)
			elif not narrating and n % 2 == 0:
				Sfx.play("blip", randf_range(0.92, 1.12) * low)
			dialog_label.visible_characters = n
		bip.talking = not narrating
	else:
		bip.talking = false
		if blocking:
			dialog_more.visible = fmod(Time.get_ticks_msec() / 1000.0, 0.8) < 0.5
		else:
			box_hide_t -= delta
			if box_hide_t <= 0.0:
				dialog_panel.visible = false

func _chatter(table: Dictionary, chance: float) -> void:
	if randf() < chance:
		say(Story.pick(table, act))

# ---------------------------------------------------------------- run flow

func _prepare_room(a: int) -> void:
	act = a
	room.act = act
	room.door = false
	bip.act = act
	bip.visible = true
	bip.modulate = Color.WHITE
	bip.mood = "happy"
	enemy.visible = false
	fade.color = Color(0, 0, 0, 0)

func _reset_run() -> void:
	hp = 3
	max_hp = 3
	shield = 0
	coins = 0
	tension = 0.0
	floor_n = 1
	step_i = 0
	owned = {}
	run_presses = 0
	hammers_this_run = 0
	silence_done = false

## Saves the run so CONTINUE can bring the player back to the start of this room.
func _save_run() -> void:
	if tutorial:
		return
	Meta.data.run = {
		"hp": hp, "max_hp": max_hp, "shield": shield, "coins": coins,
		"floor": floor_n, "step": step_i, "owned": owned,
		"presses": run_presses, "hammers": hammers_this_run, "silence": silence_done,
	}
	Meta.save_game()

func _clear_run() -> void:
	Meta.data.run = null
	Meta.save_game()

func continue_run() -> void:
	state = S.BUSY
	_prepare_room(Meta.act())
	var r: Dictionary = Meta.data.run
	hp = int(r.hp)
	max_hp = int(r.max_hp)
	shield = int(r.shield)
	coins = int(r.coins)
	floor_n = int(r.floor)
	step_i = int(r.step)
	owned = r.owned
	run_presses = int(r.presses)
	hammers_this_run = int(r.hammers)
	silence_done = bool(r.silence)
	tension = 0.0
	say(Story.pick(Story.RUN_START, act))
	next_step()

func start_run() -> void:
	state = S.BUSY
	Meta.data.runs = int(Meta.data.runs) + 1
	Meta.data.run = null
	Meta.save_game()
	_prepare_room(Meta.act())
	_reset_run()

	if not Meta.seen("intro"):
		await say_block(Story.INTRO)
		Meta.mark_seen("intro")
	elif act == 2 and not Meta.seen("act2"):
		await say_block(Story.ACT2_INTRO)
		Meta.mark_seen("act2")
	elif act == 3 and not Meta.seen("act3"):
		bip.mood = "sad"
		await say_block(Story.ACT3_INTRO)
		bip.mood = "happy"
		Meta.mark_seen("act3")
	else:
		say(Story.pick(Story.RUN_START, act))
	next_step()

func next_step() -> void:
	if step_i >= FLOOR_PLAN.size():
		step_i = 0
		floor_n += 1
		fx.float_text(Vector2(240, 70), "FLOOR %d" % floor_n, Color("#ffd23f"))
	_save_run()
	var kind: String = FLOOR_PLAN[step_i]
	step_i += 1
	match kind:
		"stage": begin_stage()
		"shop": open_shop()
		"boss": begin_boss()

func begin_stage() -> void:
	tension = 0.0
	stage_presses = 0
	min_presses = 3 + floor_n
	idle_t = 0.0
	idle_said = false
	silence_i = 0
	bip.mood = "happy"
	roll_next_event()
	stop_btn.visible = true
	smash_btn.visible = act >= 3 and int(Meta.data.hammer) >= Meta.HAMMER_PIECES
	_update_stop()
	state = S.STAGE

func _update_stop() -> void:
	var left := min_presses - stage_presses
	stop_btn.disabled = left > 0
	stop_btn.text = "%d MORE" % left if left > 0 else "STOP"

func _count_press() -> void:
	bip.press()
	Sfx.play("press", randf_range(0.92, 1.08))
	run_presses += 1
	if not tutorial:
		Meta.data.total_presses = int(Meta.data.total_presses) + 1
		var total: int = Meta.data.total_presses
		if Story.MILESTONES.has(total):
			say(Story.MILESTONES[total])
			if act == 1:
				fx.confetti(bip.global_position + Vector2(0, -40), 40)
	idle_t = 0.0
	idle_said = false
	if silence_i > 0:
		silence_i = 0
		bip.mood = "happy"

func stage_press() -> void:
	_count_press()
	stage_presses += 1
	var rise := randf_range(7.0, 13.0) * (0.65 if owned.has("ice") else 1.0)
	tension = minf(tension + rise, 95.0 if tutorial else 100.0)
	if owned.has("golden"):
		coins += 1
	await resolve_event(next_event)
	if state == S.OVER:
		return
	state = S.STAGE
	if tension >= 100.0:
		await overload()
		return
	roll_next_event()
	_update_stop()
	bip_pressed.emit()

func _on_stop() -> void:
	if state != S.STAGE or stage_presses < min_presses:
		Sfx.play("deny")
		return
	end_stage(true)

func end_stage(stopped: bool) -> void:
	state = S.BUSY
	stop_btn.visible = false
	smash_btn.visible = false
	if stopped:
		var bonus := int(tension / 8.0)
		if bonus > 0:
			_gain(bonus, bip.global_position + Vector2(0, -64), "BONUS")
		if not tutorial:
			say(Story.pick(Story.STOP, act))
	tension = 0.0
	if tutorial:
		stage_finished.emit()
		return
	Meta.save_game()
	await _wait(1.0)
	next_step()

func overload() -> void:
	state = S.BUSY
	Sfx.play("overload")
	shake_t = 0.6
	bip.shake(0.6)
	set_mood("angry", 1.5)
	fx.burst(bip.global_position + Vector2(0, -24), Color("#ff3b3b"), 30, 140)
	fx.float_text(bip.global_position + Vector2(0, -70), "OVERLOAD!", Color("#ff3b3b"))
	say(Story.pick(Story.OVERLOAD, act))
	damage(2)
	if state == S.OVER:
		return
	await end_stage(false)

# ---------------------------------------------------------------- events

func _remaining_notes() -> Array:
	var out := []
	for a in range(1, act + 1):
		for n in Story.NOTES[a]:
			if not (n[0] in Meta.data.notes_found):
				out.append(n)
	return out

func roll_next_event() -> void:
	if tutorial:
		next_event = tut_queue.pop_front() if not tut_queue.is_empty() else "coins"
		return
	var t := tension
	var w := {
		"coins": 30.0 - t * 0.1,
		"jackpot": 3.0 + t * 0.06,
		"heart": 4.0,
		"shield": 3.0,
		"bomb": 7.0 + t * 0.22,
		"thief": 3.0 + t * 0.06,
		"pang": 6.0,
		"calm": 5.0,
		"monster": 6.0 + t * 0.08,
		"stranger": 2.5,
		"gamble": 2.5,
		"nothing": 9.0,
	}
	if not _remaining_notes().is_empty():
		w["note"] = 1.5 + act
	if act >= 2 and int(Meta.data.hammer) < Meta.HAMMER_PIECES and hammers_this_run < 2:
		w["hammer"] = 1.0 + act
	var total := 0.0
	for k in w:
		total += maxf(w[k], 0.0)
	var r := randf() * total
	for k in w:
		r -= maxf(w[k], 0.0)
		if r <= 0.0:
			next_event = k
			return
	next_event = "nothing"

func _gain(n: int, pos: Vector2, label := "COINS") -> void:
	coins += n
	fx.float_text(pos, "+%d %s" % [n, label], Color("#ffd23f"))
	fx.burst(pos + Vector2(0, 10), Color("#ffd23f"), 8, 70)
	Sfx.play("coin")

func resolve_event(ev: String) -> void:
	var mult := 1.0 + tension / 100.0
	var cursed := 2 if owned.has("cursed") else 1
	var head: Vector2 = bip.global_position + Vector2(0, -56)
	if ev in ["bomb", "thief", "pang"] and owned.has("glove") and randf() < 0.2:
		fx.float_text(head, "LUCKY DODGE!", Color("#3bceac"))
		Sfx.play("good")
		return
	match ev:
		"coins":
			_gain(int(round(randi_range(3, 6) * mult)) * cursed, head)
			_chatter(Story.GOOD, 0.2)
		"jackpot":
			_gain(int(round(randi_range(12, 20) * mult)) * cursed, head, "JACKPOT")
			fx.confetti(head, 30)
			Sfx.play("win")
			say(Story.pick(Story.GOOD, act))
		"heart":
			if hp < max_hp:
				hp += 1
				fx.float_text(head, "+1 HEART", Color("#ff5d73"))
				Sfx.play("good")
			else:
				_gain(5, head)
		"shield":
			shield += 1
			fx.float_text(head, "+1 SHIELD", Color("#6ec6ff"))
			Sfx.play("good")
		"bomb":
			fx.burst(bip.global_position + Vector2(0, -20), Color("#ff9f1c"), 20, 120)
			fx.float_text(head, "BOOM!", Color("#ff9f1c"))
			damage(cursed)
			if state != S.OVER:
				_chatter(Story.BAD, 0.5)
		"thief":
			var lost := int(ceil(coins * 0.3))
			if lost <= 0:
				fx.float_text(head, "A THIEF FOUND NOTHING", Color("#a89cb8"))
			else:
				coins -= lost
				fx.float_text(head, "THIEF! -%d COINS" % lost, Color("#ff5d73"))
				Sfx.play("bad")
				set_mood("worried", 1.5)
		"pang":
			tension = minf(tension + 20.0, 100.0)
			fx.float_text(head, "+20 " + tension_word(), Color("#ff7a20"))
			Sfx.play("bad")
			set_mood("angry", 1.2)
			bip.shake(0.3)
		"calm":
			tension = maxf(tension - 25.0, 0.0)
			fx.float_text(head, "-25 " + tension_word(), Color("#3bceac"))
			Sfx.play("good")
			set_mood("calm", 1.0)
		"monster":
			await _fight()
		"stranger":
			var c: int = await popup_msg("A STRANGER", "A shadowy stranger offers you 25 coins for one of your hearts.", ["DEAL", "NO THANKS"])
			if c == 0:
				if hp > 1:
					hp -= 1
					_gain(25, head)
				else:
					fx.float_text(head, "YOU CAN'T SPARE ONE", Color("#a89cb8"))
		"gamble":
			if coins < 4:
				_gain(3, head)
				return
			var bet := coins / 2
			var c: int = await popup_msg("DOUBLE OR NOTHING", "Bip: \"Let's play a game! Bet %d coins? I flip, you trust me!\"" % bet, ["BET", "NO"])
			if c == 0:
				if randf() < 0.5:
					_gain(bet, head, "WON")
					Sfx.play("win")
				else:
					coins -= bet
					fx.float_text(head, "LOST %d" % bet, Color("#ff5d73"))
					Sfx.play("bad")
		"note":
			await _show_note()
		"hammer":
			await _find_hammer()
		_:
			fx.float_text(head, ["...NOTHING", "*SQUEAK*", "BIP GIGGLES"][act - 1], Color("#a89cb8"))
			_chatter(Story.PRESS, 0.6)

func damage(n: int) -> void:
	for i in n:
		if shield > 0:
			shield -= 1
			fx.float_text(bip.global_position + Vector2(0, -72), "BLOCKED!", Color("#6ec6ff"))
		else:
			hp -= 1
	if tutorial:
		hp = maxi(hp, 1)   # nobody dies in the tutorial
	shake_t = 0.3
	bip.shake(0.3)
	flash.color = Color(1, 0.1, 0.1, 0.45)
	Sfx.play("hurt")
	if hp <= 0 and state != S.OVER:
		game_over()

func _show_note() -> void:
	var pool := _remaining_notes()
	if pool.is_empty():
		return
	var n: Array = pool[0]
	Meta.data.notes_found.append(n[0])
	Meta.save_game()
	Sfx.play("note")
	await popup_msg("A NOTE ON THE FLOOR", "\"%s\"" % n[1], ["..."])
	say(Story.pick(Story.NOTE_REACT, act))
	if act == 2:
		set_mood("worried", 2.0)

func _find_hammer() -> void:
	hammers_this_run += 1
	Meta.data.hammer = int(Meta.data.hammer) + 1
	Meta.save_game()
	Sfx.play("note")
	await popup_msg("SOMETHING SHINY", "You pry a rusty piece of metal out of the floorboards.\n\nHAMMER PIECE %d/%d" % [int(Meta.data.hammer), Meta.HAMMER_PIECES], ["KEEP IT"])
	say(Story.pick(Story.HAMMER_REACT, act))
	if act >= 3 and int(Meta.data.hammer) >= Meta.HAMMER_PIECES:
		smash_btn.visible = true

func popup_msg(title: String, body: String, options: Array) -> int:
	var prev := state
	state = S.CHOICE
	popup_title.text = title
	popup_body.text = body
	for c in popup_buttons.get_children():
		c.queue_free()
	for i in options.size():
		var b := Button.new()
		b.text = options[i]
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func(): popup_chosen.emit(i))
		popup_buttons.add_child(b)
	popup.visible = true
	popup.reset_size()
	var choice: int = await popup_chosen
	popup.visible = false
	state = prev
	return choice

# ---------------------------------------------------------------- fights

func _fight() -> void:
	state = S.BUSY
	stop_btn.visible = false
	smash_btn.visible = false
	var m: Array = MONSTERS.pick_random()
	enemy.kind = m[0]
	enemy.display_name = m[1]
	enemy.max_hp = 4 + floor_n * 3
	enemy.hp = enemy.max_hp
	enemy.warn = false
	enemy.bar_ratio = 1.0
	enemy.visible = true
	Sfx.play("roar", 1.6)
	say(Story.pick(Story.FIGHT, act))
	enemy_time_max = 4.5
	enemy_time = enemy_time_max
	state = S.FIGHT
	var won: bool = await fight_done
	enemy.visible = false
	stop_btn.visible = true
	smash_btn.visible = act >= 3 and int(Meta.data.hammer) >= Meta.HAMMER_PIECES
	if won:
		fx.burst(ENEMY_POS + Vector2(0, -20), Color("#5fd35f"), 24)
		_gain(int(round(randi_range(6, 10) * (1.0 + tension / 100.0))), ENEMY_POS + Vector2(0, -40))
		Sfx.play("win")
	else:
		fx.float_text(bip.global_position + Vector2(0, -72), "IT BIT YOU!", Color("#ff5d73"))
		damage(1)

func attack_enemy() -> void:
	_count_press()
	enemy.hp = maxi(enemy.hp - (2 if owned.has("finger") else 1), 0)
	enemy.hit()
	Sfx.play("hit", randf_range(0.9, 1.2))
	fx.burst(ENEMY_POS + Vector2(randf_range(-12, 12), -24), Color.WHITE, 5, 70)
	if enemy.hp <= 0:
		state = S.BUSY
		enemy.warn = false
		fight_done.emit(true)

func begin_boss() -> void:
	state = S.BUSY
	stop_btn.visible = false
	smash_btn.visible = false
	var i := floor_n - 1
	var id: String = BOSSES[i]
	enemy.kind = id
	enemy.display_name = BOSS_NAMES[id]
	enemy.max_hp = BOSS_HP[i]
	enemy.hp = enemy.max_hp
	enemy.bar_ratio = 0.0
	enemy.warn = false
	enemy.visible = true
	Sfx.play("roar")
	shake_t = 0.5
	await say_block(Story.BOSS[id])
	boss_attack_t = BOSS_SPEED[i]
	state = S.BOSS
	var won: bool = await fight_done
	enemy.visible = false
	enemy.warn = false
	if not won:
		return
	fx.confetti(ENEMY_POS + Vector2(0, -40), 40)
	Sfx.play("win")
	say(Story.BOSS_WIN[id])
	_gain(15, ENEMY_POS + Vector2(0, -60))
	Meta.save_game()
	await _wait(1.6)
	if floor_n >= FLOORS:
		await victory()
		return
	next_step()

# ---------------------------------------------------------------- shop

func open_shop() -> void:
	state = S.SHOP
	say(Story.pick(Story.SHOP, act))
	for c in shop_list.get_children():
		c.queue_free()
	var pool := []
	for id in UPGRADES:
		if UPGRADES[id][3] or not owned.has(id):
			pool.append(id)
	pool.shuffle()
	var extra := (floor_n - 1) * 5
	for id in pool.slice(0, 3):
		var u: Array = UPGRADES[id]
		_shop_button("%s  %dc" % [u[0], u[2] + extra], u[1], id, u[2] + extra)
	_shop_button("Patch Up  12c", "Heal one heart.", "heal", 12)
	var leave := Button.new()
	leave.text = "LEAVE"
	leave.focus_mode = Control.FOCUS_NONE
	leave.pressed.connect(_leave_shop)
	shop_list.add_child(leave)
	shop_desc.text = "Hover over an item to see what it does."
	shop.visible = true
	_refresh_shop()
	shop.reset_size()

func _shop_button(text: String, desc: String, id: String, price: int) -> void:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.set_meta("price", price)
	b.set_meta("id", id)
	b.pressed.connect(_buy.bind(b))
	b.mouse_entered.connect(func(): shop_desc.text = desc)
	shop_list.add_child(b)

func _refresh_shop() -> void:
	shop_coins.text = "COINS: %d" % coins
	for b in shop_list.get_children():
		if b.has_meta("price"):
			var full: bool = b.get_meta("id") == "heal" and hp >= max_hp
			b.disabled = b.has_meta("sold") or coins < int(b.get_meta("price")) or full

func _buy(b: Button) -> void:
	var price: int = b.get_meta("price")
	var id: String = b.get_meta("id")
	if coins < price:
		Sfx.play("deny")
		return
	coins -= price
	Sfx.play("buy")
	match id:
		"heal": hp = mini(hp + 1, max_hp)
		"glass": shield += 1
		"spare":
			max_hp += 1
			hp += 1
	if id != "heal":
		owned[id] = int(owned.get(id, 0)) + 1
		b.set_meta("sold", true)
		b.text = "SOLD"
	fx.burst(bip.global_position + Vector2(0, -40), Color("#ffd23f"), 12)
	_refresh_shop()

func _leave_shop() -> void:
	shop.visible = false
	state = S.BUSY
	next_step()

# ---------------------------------------------------------------- silence, death, endings

func _idle_tick(delta: float) -> void:
	idle_t += delta
	if act >= 2 and not silence_done:
		if silence_i < Story.SILENCE.size() and idle_t >= Story.SILENCE[silence_i][0]:
			say(Story.SILENCE[silence_i][1])
			bip.mood = ["worried", "sad", "angry", "sad", "calm"][silence_i]
			mood_t = 0.0
			if silence_i == 2:
				bip.shake(1.0)
			silence_i += 1
		if idle_t >= 60.0:
			_silence_reached()
	elif idle_t > 8.0 and not idle_said:
		idle_said = true
		say(Story.pick(Story.IDLE, act))

func _silence_reached() -> void:
	silence_done = true
	Meta.data.silences = int(Meta.data.silences) + 1
	Meta.save_game()
	if int(Meta.data.silences) >= Meta.SILENCES_NEEDED:
		await play_ending("silence")
	else:
		fx.float_text(bip.global_position + Vector2(0, -72), "SILENCE %d/%d" % [int(Meta.data.silences), Meta.SILENCES_NEEDED], Color("#b8a8e0"))
		say("...Thank you. I don't know why I said that. ...Press me now.")

func game_over() -> void:
	state = S.OVER
	stop_btn.visible = false
	smash_btn.visible = false
	Meta.data.deaths = int(Meta.data.deaths) + 1
	_clear_run()
	bip.mood = "sad" if act < 3 else "void"
	mood_t = 0.0
	Sfx.play("overload")
	await _wait(0.9)
	enemy.visible = false
	await _fade_to(0.6, 0.8)
	await say_block([Story.pick(Story.DEATH, act)])
	await popup_msg("YOU FELL ASLEEP", "Reached floor %d\nPresses this run: %d\nTotal presses: %d" % [floor_n, run_presses, int(Meta.data.total_presses)], ["WAKE UP"])
	await _fade_to(0.0, 0.6)
	start_run()

func victory() -> void:
	state = S.BUSY
	Meta.data.wins = int(Meta.data.wins) + 1
	_clear_run()
	if act >= 3:
		await play_ending("cycle")
		return
	fx.confetti(bip.global_position + Vector2(0, -40), 50)
	await say_block(Story.VICTORY[act])
	start_run()

func _on_smash() -> void:
	if state != S.STAGE:
		return
	await play_ending("door")

func play_ending(id: String) -> void:
	state = S.BUSY
	stop_btn.visible = false
	smash_btn.visible = false
	enemy.visible = false
	if not (id in Meta.data.endings):
		Meta.data.endings.append(id)
	_clear_run()
	match id:
		"cycle":
			var lines := Story.ENDING_CYCLE
			await say_block(lines.slice(0, 4))
			bip.mood = "calm"
			create_tween().tween_property(bip, "modulate:a", 0.0, 2.0)
			await say_block(lines.slice(4, 5))
			await _fade_to(1.0, 1.2)
			await say_block(lines.slice(5, 7))
			act = 1
			room.act = 1
			bip.act = 1
			bip.mood = "happy"
			bip.modulate = Color.WHITE
			await _fade_to(0.0, 1.5)
			await say_block(lines.slice(7))
		"silence":
			bip.mood = "calm"
			await say_block(Story.ENDING_SILENCE.slice(0, 9))
			await _fade_to(1.0, 3.0)
			await say_block(Story.ENDING_SILENCE.slice(9))
		"door":
			var lines := Story.ENDING_DOOR
			await say_block(lines.slice(0, 3))
			bip.mood = "sad"
			await say_block(lines.slice(3, 4))
			Sfx.play("overload")
			shake_t = 0.6
			await _fade_to(1.0, 0.15, Color.WHITE)
			bip.visible = false
			room.door = true
			await _fade_to(0.0, 0.8, Color.WHITE)
			await say_block(lines.slice(4, 10))
			await _fade_to(1.0, 2.0, Color.WHITE)
			await say_block(lines.slice(10))
	var found: int = Meta.data.endings.size()
	var c: int = await popup_msg("THE END", "Endings found: %d / 3\n\nThanks for playing!" % found, ["CONTINUE", "NEW CYCLE"])
	if c == 1:
		# Start the story over, but remember which endings were found
		var endings: Array = Meta.data.endings.duplicate()
		Meta.reset()
		Meta.data.endings = endings
		Meta.save_game()
	await _fade_to(0.0, 0.5)
	start_run()

# ---------------------------------------------------------------- menu & tutorial

func _quit_to_menu() -> void:
	if not tutorial:
		Meta.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

const ARROW_BIP := Vector2(200, 118)
const ARROW_FUN := Vector2(220, 18)
const ARROW_HEARTS := Vector2(16, 15)
const ARROW_STOP := Vector2(430, 108)

func _point(pos: Vector2, up := false) -> void:
	hud.arrow_on = true
	hud.arrow_pos = pos
	hud.arrow_up = up

func _unpoint() -> void:
	hud.arrow_on = false

## A guided practice run. Events are scripted and the player can't die.
func run_tutorial() -> void:
	tutorial = true
	state = S.BUSY
	pause_menu.hint.text = "Nothing in the tutorial is saved."
	_prepare_room(1)
	_reset_run()
	await say_block([
		"* TUTORIAL",
		"Hi hi! I'm Bip, the big red button!",
		"This is just practice. Nothing here counts, so relax!",
	])

	# 1. Pressing
	tut_queue = ["coins"]
	begin_stage()
	_point(ARROW_BIP)
	say("Press me! Click on me or hit SPACE.")
	await bip_pressed

	# 2. The FUN bar
	_point(ARROW_FUN, true)
	await say_block([
		"See? Coins! Every press does something random.",
		"Up top is the FUN bar. It fills up a little with every press.",
		"More FUN means bigger rewards... but also bigger dangers!",
		"If it ever hits the top, I OVERLOAD and you get hurt. A lot.",
	])
	_unpoint()

	# 3. Bad things happen too
	tut_queue = ["bomb", "calm", "jackpot"]
	roll_next_event()
	say("Now press me 3 more times!")
	await bip_pressed
	_point(ARROW_HEARTS, true)
	await say_block([
		"Ouch! That was a bomb. Sorry!",
		"Those are your hearts. Lose them all and you fall asleep. The run is over.",
		"Keep going! 2 more presses!",
	])
	_unpoint()
	say("2 more presses!")
	await bip_pressed
	await bip_pressed

	# 4. The STOP button
	_point(ARROW_STOP)
	await say_block([
		"This is the STOP button. It unlocks after a few presses in each room.",
		"When you STOP, you keep your coins and get a BONUS for all the FUN you built up.",
		"Push your luck, or play it safe. Your choice!",
	])
	say("Press STOP to finish this room.")
	await stage_finished
	_unpoint()
	await _wait(0.8)

	# 5. Monsters
	await say_block([
		"Sometimes a monster sneaks in.",
		"When that happens, press me as FAST as you can before its timer runs out!",
		"Here comes one now!",
	])
	await _fight()
	stop_btn.visible = false
	smash_btn.visible = false
	await _wait(0.8)

	# 6. Everything else
	await say_block([
		"Nice one!",
		"Every few rooms you'll find my SHOP. Spend your coins on upgrades there.",
		"At the end of each floor there's a BOSS. Hit it before it hits you!",
		"Beat all 3 floors to win. And if you fall asleep, you just wake up and try again.",
		"Sometimes you'll find strange notes on the floor. ...Don't worry about those.",
		"Press ESC anytime to pause or change the settings.",
		"That's everything! Let's have FUN!",
	])
	Meta.mark_seen("tutorial")
	tutorial = false
	if Meta.after_tutorial == "new":
		pause_menu.hint.text = "Your run is saved at the start of every room."
		start_run()
	else:
		_quit_to_menu()
