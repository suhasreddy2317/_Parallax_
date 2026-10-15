class_name VictoryScreen
extends Control

## VictoryScreen
## Short, animated campaign ending shown after the final validated exit.

signal play_again_requested()
signal main_menu_requested()

const CYAN := Color(0.08, 0.85, 1.0)
const MAGENTA := Color(0.95, 0.2, 0.75)

@onready var title: Label = $Center/Content/Title
@onready var subtitle: Label = $Center/Content/Subtitle
@onready var message: Label = $Center/Content/Message
@onready var stats_label: Label = $Center/Content/StatsLabel
@onready var options: HBoxContainer = $Center/Content/Options
@onready var replay_btn: Button = $Center/Content/Options/ReplayBtn
@onready var menu_btn: Button = $Center/Content/Options/MenuBtn

var _ending_sequence_started: bool = false
var _core_progress: float = 0.0
var _background_alpha: float = 0.0
var _ending_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	UIHelper.style_button(replay_btn, CYAN)
	UIHelper.style_button(menu_btn, MAGENTA)
	replay_btn.pressed.connect(func(): play_again_requested.emit())
	menu_btn.pressed.connect(func(): main_menu_requested.emit())

func set_stats(time_sec: float, shifts: int, deaths: int) -> void:
	var mins: int = int(time_sec) / 60
	var secs: int = int(time_sec) % 60
	stats_label.text = "TIME %02d:%02d     PHASE SHIFTS %d     HAZARDS %d" % [mins, secs, shifts, deaths]

func play_ending_sequence() -> void:
	if _ending_sequence_started:
		return
	_ending_sequence_started = true
	visible = true
	_background_alpha = 0.0
	_core_progress = 0.0
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	message.modulate.a = 0.0
	stats_label.modulate.a = 0.0
	options.modulate.a = 0.0
	replay_btn.disabled = true
	menu_btn.disabled = true
	queue_redraw()

	_ending_tween = create_tween()
	_ending_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_ending_tween.tween_method(_set_background_alpha, 0.0, 0.97, 0.9)
	_ending_tween.tween_method(_set_core_progress, 0.0, 1.0, 1.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_ending_tween.tween_property(title, "modulate:a", 1.0, 0.45)
	_ending_tween.tween_property(subtitle, "modulate:a", 1.0, 0.35)
	_ending_tween.tween_property(message, "modulate:a", 1.0, 0.45)
	_ending_tween.tween_property(stats_label, "modulate:a", 0.8, 0.35)
	_ending_tween.tween_property(options, "modulate:a", 1.0, 0.4)
	_ending_tween.tween_callback(_enable_options)

func reset_ending_sequence() -> void:
	if _ending_tween and _ending_tween.is_running():
		_ending_tween.kill()
	_ending_sequence_started = false
	_core_progress = 0.0
	visible = false
	_background_alpha = 0.0
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	message.modulate.a = 0.0
	stats_label.modulate.a = 0.0
	options.modulate.a = 0.0
	replay_btn.disabled = true
	menu_btn.disabled = true
	queue_redraw()

func _enable_options() -> void:
	replay_btn.disabled = false
	menu_btn.disabled = false
	replay_btn.grab_focus()

func _set_core_progress(value: float) -> void:
	_core_progress = value
	queue_redraw()

func _set_background_alpha(value: float) -> void:
	_background_alpha = value
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.008, 0.014, 0.03, _background_alpha))
	var center := Vector2(size.x * 0.5, size.y * 0.5 - 78.0)
	var spread: float = lerpf(minf(size.x * 0.22, 230.0), 0.0, _core_progress)
	var cyan_orb := center + Vector2(-spread, 0.0)
	var magenta_orb := center + Vector2(spread, 0.0)
	var stream_alpha: float = minf(_core_progress * 1.8, 0.7)

	draw_line(center + Vector2(-spread - 120.0, 0.0), cyan_orb, Color(CYAN, stream_alpha), 2.0, true)
	draw_line(center + Vector2(spread + 120.0, 0.0), magenta_orb, Color(MAGENTA, stream_alpha), 2.0, true)
	draw_circle(cyan_orb, 8.0 + _core_progress * 3.0, Color(CYAN, stream_alpha + 0.25))
	draw_circle(magenta_orb, 8.0 + _core_progress * 3.0, Color(MAGENTA, stream_alpha + 0.25))

	var core_alpha: float = clampf((_core_progress - 0.52) * 2.1, 0.0, 1.0)
	if core_alpha > 0.0:
		var core_radius: float = 18.0 + 9.0 * _core_progress
		draw_circle(center, core_radius + 15.0, Color(0.2, 0.45, 0.75, core_alpha * 0.09))
		draw_circle(center, core_radius, Color(0.04, 0.12, 0.2, core_alpha * 0.9))
		draw_arc(center, core_radius + 5.0, -PI * 0.5, PI * 0.5, 40, Color(CYAN, core_alpha), 2.5, true)
		draw_arc(center, core_radius + 5.0, PI * 0.5, PI * 1.5, 40, Color(MAGENTA, core_alpha), 2.5, true)
		draw_circle(center, 7.0 + 4.0 * _core_progress, Color(0.88, 0.97, 1.0, core_alpha))
