class_name ExitPortal
extends Area2D

## ExitPortal
## Dimensional warp gate marking the end of a stage and transition to the next chamber.

signal exit_reached(next_stage_id: int, player_id: int)

@export var next_stage_id: int = 1
@export var portal_size: Vector2 = Vector2(54.0, 96.0)
@export var portal_label: String = "GATE"
@export var required_player_id: int = 0

var is_activated: bool = false
var _spin_time: float = 0.0
var _collision_shape: CollisionShape2D

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	_ensure_collision()

func _ensure_collision() -> void:
	_collision_shape = get_node_or_null("CollisionShape2D")
	if not _collision_shape:
		_collision_shape = CollisionShape2D.new()
		_collision_shape.name = "CollisionShape2D"
		var box: RectangleShape2D = RectangleShape2D.new()
		box.size = portal_size
		_collision_shape.shape = box
		add_child(_collision_shape)

func _process(delta: float) -> void:
	_spin_time += delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
	if body is PuzzlePlayer or body.is_in_group("player"):
		if required_player_id > 0 and (not body is PuzzlePlayer or (body as PuzzlePlayer).player_id != required_player_id):
			return
		is_activated = true
		if SoundManager.instance:
			SoundManager.instance.play_stage_complete()
		exit_reached.emit(next_stage_id, (body as PuzzlePlayer).player_id if body is PuzzlePlayer else 0)

func _draw() -> void:
	var half_w: float = portal_size.x * 0.5
	var half_h: float = portal_size.y * 0.5
	var rect: Rect2 = Rect2(-half_w, -half_h, portal_size.x, portal_size.y)

	# Outer gateway frame
	draw_rect(rect, Color(0.10, 0.12, 0.18, 0.95), true)
	draw_rect(rect, Color(0.2, 0.85, 1.0, 0.8), false, 2.5)

	# Dimensional vortex ellipse
	var center: Vector2 = Vector2(0, 0)
	var time: float = _spin_time
	var pulse: float = sin(time * 5.0) * 0.15 + 0.85

	# Swirling portal rings (Cyan and Magenta interwoven)
	var cyan: Color = Color(0.1, 0.9, 1.0, 0.6)
	var magenta: Color = Color(0.95, 0.2, 0.75, 0.6)
	
	draw_circle(center, (half_w - 6.0) * pulse, Color(0.08, 0.15, 0.25, 0.8))
	draw_arc(center, (half_w - 6.0) * pulse, time * 2.0, time * 2.0 + PI, 16, cyan, 2.5)
	draw_arc(center, (half_w - 6.0) * pulse, time * 2.0 + PI, time * 2.0 + TAU, 16, magenta, 2.5)
	draw_arc(center, (half_w - 12.0) * (2.0 - pulse), -time * 3.0, -time * 3.0 + TAU, 16, Color(1, 1, 1, 0.7), 1.5)

	# Portal Header Text
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 10
	var text_size: Vector2 = font.get_string_size(portal_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(-text_size.x * 0.5, -half_h + 14.0), portal_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.9, 0.95, 1.0))

	# Status indicator at base
	var exit_str: String = "TRANSIT"
	var base_size: Vector2 = font.get_string_size(exit_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 9)
	draw_string(font, Vector2(-base_size.x * 0.5, half_h - 6.0), exit_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.2, 0.95, 0.6))
