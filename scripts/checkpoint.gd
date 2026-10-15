class_name CheckpointTerminal
extends Area2D

## CheckpointTerminal
## Sci-fi dimensional anchor terminal that records player respawn coordinates.

signal checkpoint_activated(checkpoint_id: int, position: Vector2)

@export var checkpoint_id: int = 0
@export var terminal_size: Vector2 = Vector2(40.0, 70.0)

var is_activated: bool = false
var _pulse_time: float = 0.0

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	_ensure_collision()

func _ensure_collision() -> void:
	var shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if not shape:
		shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		var box: RectangleShape2D = RectangleShape2D.new()
		box.size = terminal_size
		shape.shape = box
		add_child(shape)

func _process(delta: float) -> void:
	_pulse_time += delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body is PuzzlePlayer or body.is_in_group("player"):
		# Proximity check: prevent spurious activation during stage loading
		if global_position.distance_to(body.global_position) > 120.0:
			return
		var stage: StageBase = get_parent() as StageBase
		if stage:
			if checkpoint_id <= stage.active_checkpoint_id:
				return
			# Progressive checkpointing: in Stage 3, Checkpoint 2 requires Checkpoint 1
			if stage.stage_index == 3 and checkpoint_id == 2 and stage.active_checkpoint_id < 1:
				return
		if not is_activated:
			activate()
		if body.has_method("set_checkpoint"):
			body.call("set_checkpoint", global_position)

func activate() -> void:
	is_activated = true
	if SoundManager.instance:
		SoundManager.instance.play_checkpoint()
	checkpoint_activated.emit(checkpoint_id, global_position)
	queue_redraw()

func _draw() -> void:
	var half_w: float = terminal_size.x * 0.5
	var half_h: float = terminal_size.y * 0.5
	var base_rect: Rect2 = Rect2(-half_w, -half_h, terminal_size.x, terminal_size.y)

	# Pillar body
	var body_col: Color = Color(0.14, 0.16, 0.22, 0.95)
	draw_rect(base_rect, body_col, true)

	var border_col: Color = Color(0.2, 0.95, 0.65) if is_activated else Color(0.95, 0.7, 0.2, 0.7)
	draw_rect(base_rect, border_col, false, 2.0)

	# Floating Core Beacon
	var core_y: float = -half_h * 0.35 + sin(_pulse_time * 4.0) * 3.0
	var core_color: Color = border_col
	var pulse_radius: float = 8.0 + (sin(_pulse_time * 6.0) + 1.0) * 2.0

	if is_activated:
		# Glowing radiant halo
		draw_circle(Vector2(0, core_y), pulse_radius + 4.0, Color(border_col.r, border_col.g, border_col.b, 0.25))
	draw_circle(Vector2(0, core_y), pulse_radius, core_color)
	draw_circle(Vector2(0, core_y), pulse_radius * 0.4, Color.WHITE)

	# Status text / symbol
	var status_text: String = "ACTIVE" if is_activated else "CHECKPOINT"
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 9
	var text_size: Vector2 = font.get_string_size(status_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(-text_size.x * 0.5, half_h - 10.0), status_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, border_col)
