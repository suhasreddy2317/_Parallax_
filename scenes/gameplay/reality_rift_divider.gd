class_name RealityRiftDivider
extends Control

var _time: float = 0.0
var _pulse: float = 0.0
var _pulse_reality: int = RealityManager.Reality.REALITY_A
var _pulse_activated: bool = true
var _particles: Array[Dictionary] = []
const PULSE_DURATION: float = 1.5

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in range(14):
		_particles.append({
			"y": randf() * size.y,
			"speed": randf_range(18.0, 52.0),
			"offset": randf_range(-2.5, 2.5),
			"phase": randf() * TAU,
			"radius": randf_range(0.7, 1.8)
		})

func pulse(reality: int = RealityManager.Reality.REALITY_A, activated: bool = true) -> void:
	_pulse = 1.0
	_pulse_reality = reality
	_pulse_activated = activated
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	_pulse = move_toward(_pulse, 0.0, delta / PULSE_DURATION)
	for particle in _particles:
		particle["y"] = fposmod(float(particle["y"]) - float(particle["speed"]) * delta, maxf(size.y, 1.0))
	queue_redraw()

func _draw() -> void:
	var seam_x: float = size.x * 0.5
	var pulse_alpha: float = 0.5 + 0.18 * sin(_time * 2.4) + _pulse * 0.3
	draw_rect(Rect2(seam_x - 5.0, 0.0, 10.0, size.y), Color(0.015, 0.02, 0.04, 0.72))
	draw_line(Vector2(seam_x - 2.0, 0.0), Vector2(seam_x - 2.0, size.y), Color(0.08, 0.82, 0.98, pulse_alpha * 0.22), 5.0)
	draw_line(Vector2(seam_x + 2.0, 0.0), Vector2(seam_x + 2.0, size.y), Color(0.96, 0.18, 0.72, pulse_alpha * 0.22), 5.0)
	draw_line(Vector2(seam_x - 1.0, 0.0), Vector2(seam_x - 1.0, size.y), Color(0.08, 0.82, 0.98, pulse_alpha), 1.0)
	draw_line(Vector2(seam_x + 1.0, 0.0), Vector2(seam_x + 1.0, size.y), Color(0.96, 0.18, 0.72, pulse_alpha), 1.0)
	if _pulse > 0.0:
		var center: Vector2 = Vector2(seam_x, size.y * 0.5)
		var progress: float = 1.0 - _pulse
		var pulse_alpha_envelope: float = sin(progress * PI) if _pulse_activated else 1.0 - progress
		var direction: float = 1.0 if _pulse_activated else -1.0
		var reality_a_progress: float = clampf(progress - (0.12 if _pulse_reality == RealityManager.Reality.REALITY_B else 0.0), 0.0, 1.0)
		var reality_b_progress: float = clampf(progress - (0.12 if _pulse_reality == RealityManager.Reality.REALITY_A else 0.0), 0.0, 1.0)
		var reality_a_color: Color = RealityManager.COLOR_REALITY_A_PRIMARY
		var reality_b_color: Color = RealityManager.COLOR_REALITY_B_PRIMARY
		reality_a_color.a = pulse_alpha_envelope * (0.95 if _pulse_activated else 0.75)
		reality_b_color.a = pulse_alpha_envelope * (0.95 if _pulse_activated else 0.75)
		_draw_energy_ring(center, reality_a_color, reality_a_progress, direction)
		_draw_energy_ring(center, reality_b_color, reality_b_progress, direction)
	for particle in _particles:
		var y: float = float(particle["y"])
		var x: float = seam_x + float(particle["offset"]) + sin(_time * 3.0 + float(particle["phase"])) * 1.2
		var color: Color = Color(0.08, 0.82, 0.98, 0.65) if int(particle["phase"] * 2.0) % 2 == 0 else Color(0.96, 0.18, 0.72, 0.65)
		draw_circle(Vector2(x, y), float(particle["radius"]), color)

func _draw_energy_ring(center: Vector2, ring_color: Color, progress: float, direction: float) -> void:
	var radius: float = lerpf(12.0, 58.0, progress) if direction > 0.0 else lerpf(58.0, 12.0, progress)
	draw_arc(center, radius, 0.0, TAU, 48, ring_color, 4.0)
	ring_color.a *= 0.55
	draw_arc(center, radius * 0.72, 0.0, TAU, 40, ring_color, 2.5)
	draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), ring_color, 3.0)
