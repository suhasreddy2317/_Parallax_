class_name OpeningIntro
extends Control

## Lightweight opening story card layered over the established title backdrop.

signal finished()

const CYAN := Color(0.08, 0.85, 1.0)
const MAGENTA := Color(0.95, 0.2, 0.75)

@onready var discovery: Label = $Discovery
@onready var fracture: Label = $Fracture
@onready var mission: Label = $Mission
@onready var title: Label = $TitleBox/Title
@onready var subtitle: Label = $TitleBox/Subtitle
@onready var skip_button: Button = $SkipButton

var _intro_tween: Tween
var _finished: bool = false
var _fracture_progress: float = 0.0
var _core_progress: float = 0.0
var _background_alpha: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.pressed.connect(_finish)
	grab_focus()
	_play()

func _unhandled_input(event: InputEvent) -> void:
	if _finished or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE]:
		_finish()
		get_viewport().set_input_as_handled()

func _play() -> void:
	discovery.modulate.a = 0.0
	fracture.modulate.a = 0.0
	mission.modulate.a = 0.0
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	_background_alpha = 0.0
	_fracture_progress = 0.0
	_core_progress = 0.0
	queue_redraw()
	if SoundManager.instance:
		SoundManager.instance.play_door_open()

	_intro_tween = create_tween()
	_intro_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# 0-3 seconds: discovery.
	_intro_tween.set_parallel(true)
	_intro_tween.tween_method(_set_background_alpha, 0.0, 0.94, 0.6)
	_intro_tween.tween_property(discovery, "modulate:a", 1.0, 0.65)
	_intro_tween.set_parallel(false)
	_intro_tween.tween_interval(1.85)
	_intro_tween.tween_property(discovery, "modulate:a", 0.0, 0.5)
	# 3-6 seconds: fracture.
	_intro_tween.tween_callback(_play_fracture_sound)
	_intro_tween.set_parallel(true)
	_intro_tween.tween_method(_set_fracture_progress, 0.0, 1.0, 0.7)
	_intro_tween.tween_property(fracture, "modulate:a", 1.0, 0.55)
	_intro_tween.set_parallel(false)
	_intro_tween.tween_interval(1.55)
	_intro_tween.tween_property(fracture, "modulate:a", 0.0, 0.75)
	# 6-9 seconds: mission.
	_intro_tween.tween_callback(_play_mission_sound)
	_intro_tween.set_parallel(true)
	_intro_tween.tween_method(_set_core_progress, 0.0, 1.0, 0.7)
	_intro_tween.tween_property(mission, "modulate:a", 1.0, 0.55)
	_intro_tween.set_parallel(false)
	_intro_tween.tween_interval(1.55)
	_intro_tween.tween_property(mission, "modulate:a", 0.0, 0.75)
	# 9-10 seconds: title, then the unchanged menu.
	_intro_tween.set_parallel(true)
	_intro_tween.tween_property(title, "modulate:a", 1.0, 0.5)
	_intro_tween.tween_property(subtitle, "modulate:a", 1.0, 0.5)
	_intro_tween.set_parallel(false)
	_intro_tween.tween_interval(0.5)
	_intro_tween.tween_callback(_finish)

func _finish() -> void:
	if _finished:
		return
	_finished = true
	if _intro_tween and _intro_tween.is_running():
		_intro_tween.kill()
	finished.emit()

func _play_fracture_sound() -> void:
	if SoundManager.instance:
		SoundManager.instance.play_reality_shift()

func _play_mission_sound() -> void:
	if SoundManager.instance:
		SoundManager.instance.play_receiver_powered()

func _set_background_alpha(value: float) -> void:
	_background_alpha = value
	queue_redraw()

func _set_fracture_progress(value: float) -> void:
	_fracture_progress = value
	queue_redraw()

func _set_core_progress(value: float) -> void:
	_core_progress = value
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.005, 0.01, 0.025, _background_alpha))
	var center := size * 0.5
	var separation := _fracture_progress * minf(size.x * 0.19, 220.0)
	var cyan_point := center + Vector2(-separation, -18.0)
	var magenta_point := center + Vector2(separation, 18.0)
	var glow_alpha := 0.18 + _fracture_progress * 0.25 + _core_progress * 0.22

	if _fracture_progress > 0.0:
		draw_line(center, cyan_point, Color(CYAN, glow_alpha), 2.0, true)
		draw_line(center, magenta_point, Color(MAGENTA, glow_alpha), 2.0, true)
		draw_circle(cyan_point, 10.0 + _fracture_progress * 8.0, Color(CYAN, glow_alpha))
		draw_circle(magenta_point, 10.0 + _fracture_progress * 8.0, Color(MAGENTA, glow_alpha))

	if _core_progress > 0.0:
		var core_radius := 16.0 + _core_progress * 20.0
		draw_circle(center, core_radius + 22.0, Color(0.16, 0.38, 0.64, _core_progress * 0.10))
		draw_circle(center, core_radius, Color(0.03, 0.10, 0.18, _core_progress * 0.88))
		draw_arc(center, core_radius + 5.0, -PI * 0.5, PI * 0.5, 32, Color(CYAN, _core_progress * 0.75), 2.0, true)
		draw_arc(center, core_radius + 5.0, PI * 0.5, PI * 1.5, 32, Color(MAGENTA, _core_progress * 0.75), 2.0, true)
		draw_circle(center, 5.0 + _core_progress * 4.0, Color(0.9, 0.97, 1.0, _core_progress))
