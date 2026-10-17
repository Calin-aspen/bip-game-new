extends Node
## Procedural 8-bit sound effects (autoload "Sfx"). No audio files needed.

const RATE := 22050

var sounds := {}
var players: Array[AudioStreamPlayer] = []
var next_player := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # so settings can preview sounds while paused
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
	sounds["press"] = _make([200.0], 0.10, "square", 0.30, -900.0)
	sounds["coin"] = _make([988.0, 1319.0], 0.06, "square", 0.20)
	sounds["hurt"] = _make([0.0], 0.28, "noise", 0.35)
	sounds["hit"] = _make([0.0], 0.06, "noise", 0.25)
	sounds["blip"] = _make([560.0], 0.055, "voice", 0.45)   # Bip's talking voice
	sounds["narrate"] = _make([440.0], 0.08, "mallet", 0.32)  # soft tick for narration
	sounds["bad"] = _make([311.0, 233.0], 0.12, "square", 0.25)
	sounds["good"] = _make([523.0, 659.0, 784.0], 0.06, "tri", 0.35)
	sounds["win"] = _make([523.0, 659.0, 784.0, 1047.0], 0.10, "square", 0.22)
	sounds["buy"] = _make([660.0, 880.0], 0.07, "tri", 0.35)
	sounds["note"] = _make([392.0, 523.0, 466.0], 0.14, "tri", 0.35)
	sounds["overload"] = _make([110.0, 82.0, 55.0], 0.20, "square", 0.30)
	sounds["deny"] = _make([150.0], 0.12, "square", 0.20)
	sounds["roar"] = _make([70.0], 0.6, "noise", 0.30, -40.0)

func play(sound_name: String, pitch := 1.0) -> void:
	if not sounds.has(sound_name):
		return
	var p := players[next_player]
	next_player = (next_player + 1) % players.size()
	p.stream = sounds[sound_name]
	p.pitch_scale = pitch
	var vol: float = Settings.voice if sound_name in ["blip", "narrate"] else Settings.sfx
	p.volume_db = linear_to_db(maxf(vol, 0.001))
	p.play()

## Builds a sound from a list of notes played one after another.
## slide = how many Hz per second the pitch moves (negative = falls).
func _make(notes: Array, note_len: float, wave: String, vol: float, slide := 0.0) -> AudioStreamWAV:
	var per_note := int(note_len * RATE)
	var total := per_note * notes.size()
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	var phase := 0.0
	var noise_val := 0.0
	for n in notes.size():
		var freq: float = notes[n]
		for i in per_note:
			var t := float(i) / RATE
			var f: float = max(freq + slide * t, 20.0)
			phase = fmod(phase + f / RATE, 1.0)
			var s := 0.0
			match wave:
				"square":
					s = 1.0 if phase < 0.5 else -1.0
				"tri":
					s = 4.0 * abs(phase - 0.5) - 1.0
				"sine":
					s = sin(phase * TAU)
				"voice":
					# Rounded tone with a few soft overtones: warm but still audible
					s = (sin(phase * TAU) + 0.4 * sin(phase * TAU * 2.0) + 0.15 * sin(phase * TAU * 3.0)) / 1.3
				"mallet":
					# Like a soft marimba key: a pure tone with a light bright overtone
					s = (sin(phase * TAU) + 0.25 * sin(phase * TAU * 4.0)) / 1.25
				"noise":
					if i % 3 == 0:
						noise_val = randf_range(-1.0, 1.0)
					s = noise_val
			var env := 1.0 - float(i) / per_note   # linear fade out
			if wave == "sine" or wave == "voice":
				env = sin(PI * float(i) / per_note)   # soft fade in and out, no click
			elif wave == "mallet":
				env = min(t / 0.004, 1.0) * exp(-t * 45.0)   # quick soft attack, fast decay
			var v := int(clamp(s * env * vol, -1.0, 1.0) * 32767.0)
			bytes.encode_s16((n * per_note + i) * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	return wav
