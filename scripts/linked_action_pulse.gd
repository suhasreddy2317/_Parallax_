class_name LinkedActionPulse
extends Node2D

var _effect_size: Vector2 = Vector2.ONE
var _effect_color: Color = Color.WHITE
var _elapsed: float = 0.0
var _activated: bool = true
const DURATION: float = 1.2

func start(effect_size: Vector2, effect_color: Color, activated: bool = true) -> void:
	_effect_size = effect_size
	_effect_color = effect_color
	_elapsed = 0.0
	_activated = activated
	z_as_relative = true
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DURATION:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var progress: float = clampf(_elapsed / DURATION, 0.0, 1.0)
	var expansion: float = lerpf(2.0, 18.0, progress) if _activated else lerpf(18.0, 2.0, progress)
	var pulse_color: Color = _effect_color
	pulse_color.a = (0.35 + 0.65 * sin(progress * PI * 0.5)) * (1.0 - progress) if _activated else (1.0 - progress) * 0.8
	var outline: Rect2 = Rect2(-_effect_size * 0.5 - Vector2.ONE * expansion, _effect_size + Vector2.ONE * expansion * 2.0)
	draw_rect(outline, pulse_color, false, 4.0 if _activated else 3.0)
	pulse_color.a *= 0.5
	draw_rect(outline.grow(5.0), pulse_color, false, 2.0)
