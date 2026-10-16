class_name VictoryScreen
extends Control

## VictoryScreen
## Short, animated campaign ending shown after the final validated exit.

signal play_again_requested()
signal main_menu_requested()

const CYAN := Color(0.08, 0.85, 1.0)
const MAGENTA := Color(0.95, 0.2, 0.75)
const FINALE_DURATION := 11.85

@onready var title: Label = $Center/Content/Title
@onready var subtitle: Label = $Center/Content/Subtitle
@onready var message: Label = $Center/Content/Message
@onready var stats_label: Label = $Center/Content/StatsLabel
@onready var options: HBoxContainer = $Center/Content/Options
@onready var replay_btn: Button = $Center/Content/Options/ReplayBtn
@onready var menu_btn: Button = $Center/Content/Options/MenuBtn

var _ending_sequence_started: bool = false
var _core_progress: float = 0.0
var _convergence_progress: float = 0.0
var _reveal_progress: float = 0.0
var _title_glitch: float = 0.0
var _particle_drift: float = 0.0
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
	_convergence_progress = 0.0
	_reveal_progress = 0.0
	_title_glitch = 0.0
	_particle_drift = 0.0
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	message.modulate.a = 0.0
	stats_label.modulate.a = 0.0
	options.modulate.a = 0.0
	replay_btn.disabled = true
	menu_btn.disabled = true
	queue_redraw()

	# A single pause-safe timeline keeps the end state deterministic while the
	# gameplay tree is paused.  0-2: activation, 2-5: convergence, 5-8:
	# stabilisation, 8-11.85: title and existing menu actions.
	_ending_tween = create_tween()
	_ending_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_ending_tween.set_parallel(true)
	_ending_tween.tween_method(_set_background_alpha, 0.0, 0.68, 2.0)
	_ending_tween.tween_method(_set_core_progress, 0.0, 1.0, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_ending_tween.tween_method(_set_particle_drift, 0.0, 0.32, 2.0)
	_ending_tween.set_parallel(false)
	_ending_tween.tween_callback(_play_activation_impact)
	_ending_tween.set_parallel(true)
	_ending_tween.tween_method(_set_convergence_progress, 0.0, 1.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_ending_tween.tween_method(_set_particle_drift, 0.32, 0.65, 3.0)
	_ending_tween.set_parallel(false)
	_ending_tween.tween_callback(_play_convergence_impact)
	_ending_tween.set_parallel(true)
	_ending_tween.tween_method(_set_reveal_progress, 0.0, 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_ending_tween.tween_method(_set_particle_drift, 0.65, 1.0, 3.0)
	_ending_tween.set_parallel(false)
	_ending_tween.tween_callback(_begin_title_reveal)
	_ending_tween.set_parallel(true)
	_ending_tween.tween_method(_set_title_glitch, 1.0, 0.0, 0.55).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_ending_tween.tween_property(title, "modulate:a", 1.0, 0.35)
	# Keep the final world view legible: the live player camera remains framed on
	# the exit, while this restrained veil keeps the title readable above it.
	_ending_tween.tween_method(_set_background_alpha, 0.68, 0.58, 0.9)
	_ending_tween.set_parallel(false)
	_ending_tween.tween_property(subtitle, "modulate:a", 1.0, 0.4)
	_ending_tween.tween_property(message, "modulate:a", 1.0, 0.35)
	_ending_tween.tween_property(stats_label, "modulate:a", 0.8, 0.3)
	_ending_tween.tween_interval(1.5)
	_ending_tween.tween_property(options, "modulate:a", 1.0, 0.4)
	_ending_tween.tween_callback(_enable_options)

func reset_ending_sequence() -> void:
	if _ending_tween and _ending_tween.is_running():
		_ending_tween.kill()
	_ending_sequence_started = false
	_core_progress = 0.0
	_convergence_progress = 0.0
	_reveal_progress = 0.0
	_title_glitch = 0.0
	_particle_drift = 0.0
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

func _set_convergence_progress(value: float) -> void:
	_convergence_progress = value
	queue_redraw()

func _set_reveal_progress(value: float) -> void:
	_reveal_progress = value
	queue_redraw()

func _set_title_glitch(value: float) -> void:
	_title_glitch = value
	queue_redraw()

func _set_particle_drift(value: float) -> void:
	_particle_drift = value
	queue_redraw()

func _set_background_alpha(value: float) -> void:
	_background_alpha = value
	queue_redraw()

func _play_activation_impact() -> void:
	if SoundManager.instance:
		SoundManager.instance.play_door_open()

func _play_convergence_impact() -> void:
	if SoundManager.instance:
		SoundManager.instance.play_reality_shift()

func _begin_title_reveal() -> void:
	_title_glitch = 1.0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.008, 0.014, 0.03, _background_alpha))
	var center := Vector2(size.x * 0.5, size.y * 0.5 - 78.0)
	var operative_frame := Vector2(size.x * 0.5, size.y * 0.5)
	var initial_spread: float = minf(size.x * 0.22, 230.0)
	var spread: float = lerpf(initial_spread, initial_spread * 0.34, _core_progress)
	spread = lerpf(spread, 0.0, _convergence_progress)
	var cyan_orb := center + Vector2(-spread, 0.0)
	var magenta_orb := center + Vector2(spread, 0.0)
	var stream_alpha: float = minf(_core_progress * 1.35, 0.68)

	draw_line(center + Vector2(-initial_spread - 120.0, 0.0), cyan_orb, Color(CYAN, stream_alpha), 2.0, true)
	draw_line(center + Vector2(initial_spread + 120.0, 0.0), magenta_orb, Color(MAGENTA, stream_alpha), 2.0, true)
	draw_circle(cyan_orb, 8.0 + _core_progress * 4.0, Color(CYAN, stream_alpha + 0.2))
	draw_circle(magenta_orb, 8.0 + _core_progress * 4.0, Color(MAGENTA, stream_alpha + 0.2))

	# Deterministic energy motes move inward during convergence, then become a
	# restrained field around the stable core.  They are drawn, not spawned, so
	# this does not add gameplay nodes or affect split-screen cameras.
	for index in range(18):
		var angle := float(index) * TAU / 18.0 + _particle_drift * 1.6
		var start_radius := 126.0 + float(index % 4) * 25.0
		var radius := lerpf(start_radius, 18.0 + float(index % 3) * 9.0, _convergence_progress)
		if _reveal_progress > 0.0:
			radius += sin(_particle_drift * 5.0 + float(index)) * 6.0
		var mote_pos := center + Vector2(cos(angle), sin(angle) * 0.42) * radius
		var mote_color := CYAN if index % 2 == 0 else MAGENTA
		draw_circle(mote_pos, 1.2 + _convergence_progress * 1.3, Color(mote_color, stream_alpha * 0.65))

	var core_alpha: float = clampf((_core_progress - 0.30) * 1.45, 0.0, 1.0)
	if core_alpha > 0.0:
		var core_radius: float = 18.0 + 11.0 * _core_progress + 7.0 * _convergence_progress
		var flash: float = sin(clampf((_convergence_progress - 0.78) / 0.22, 0.0, 1.0) * PI) * 0.72
		draw_circle(center, core_radius + 34.0, Color(0.2, 0.45, 0.75, core_alpha * 0.10 + flash * 0.25))
		draw_circle(center, core_radius + 15.0, Color(0.2, 0.45, 0.75, core_alpha * 0.09))
		draw_circle(center, core_radius, Color(0.04, 0.12, 0.2, core_alpha * 0.9))
		for ring in range(3):
			var ring_radius := core_radius + 7.0 + float(ring) * 12.0 + _convergence_progress * 16.0
			var ring_alpha := core_alpha * (0.75 - float(ring) * 0.16)
			draw_arc(center, ring_radius, -PI * 0.5, PI * 0.5, 40, Color(CYAN, ring_alpha), 2.2, true)
			draw_arc(center, ring_radius, PI * 0.5, PI * 1.5, 40, Color(MAGENTA, ring_alpha), 2.2, true)
		draw_circle(center, 7.0 + 5.0 * _core_progress, Color(0.88, 0.97, 1.0, core_alpha + flash * 0.25))
		if flash > 0.0:
			draw_rect(Rect2(Vector2.ZERO, size), Color(0.82, 0.94, 1.0, flash * 0.22))

	# The player is still rendered by the active gameplay camera below this UI.
	# This soft, translucent frame draws the eye to that live character without
	# reparenting it, changing physics, or disturbing split-screen viewports.
	if _reveal_progress > 0.0:
		var frame_alpha := _reveal_progress * 0.28
		draw_circle(operative_frame, 64.0, Color(0.05, 0.12, 0.20, frame_alpha * 0.26))
		draw_arc(operative_frame, 42.0, -PI * 0.15, PI * 1.15, 28, Color(CYAN, frame_alpha), 1.5, true)
		draw_arc(operative_frame, 42.0, PI * 0.85, PI * 1.85, 28, Color(MAGENTA, frame_alpha), 1.5, true)

	# A short chromatic scanline split precedes the clean title reveal.
	if _title_glitch > 0.0:
		var title_y := size.y * 0.5 - 16.0
		var width := minf(size.x * 0.46, 330.0) * _title_glitch
		draw_rect(Rect2(center.x - width * 0.5 - 10.0 * _title_glitch, title_y, width, 2.0), Color(CYAN, _title_glitch * 0.82))
		draw_rect(Rect2(center.x - width * 0.5 + 10.0 * _title_glitch, title_y + 8.0, width, 2.0), Color(MAGENTA, _title_glitch * 0.82))
