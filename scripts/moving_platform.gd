class_name MovingPlatform
extends AnimatableBody2D

## MovingPlatform
## Kinematic elevator and transport ledge built on AnimatableBody2D.
## Smoothly ferries the player across hazard chasms without physics jitter.

@export var travel_offset: Vector2 = Vector2(180.0, 0.0)
@export var travel_duration: float = 3.5
@export var platform_size: Vector2 = Vector2(100.0, 20.0)
@export var active_reality: int = -1 # -1 for both realities, or Reality A / B

var _origin_pos: Vector2 = Vector2.ZERO
var _time: float = 0.0
var _collision_shape: CollisionShape2D = null
var _reality_override: int = -1

func set_reality_override(reality: int) -> void:
	_reality_override = reality

func _ready() -> void:
	_origin_pos = global_position
	sync_to_physics = true
	_ensure_collision_shape()

func _ensure_collision_shape() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			_collision_shape = child
			break
	if not _collision_shape:
		_collision_shape = CollisionShape2D.new()
		var box: RectangleShape2D = RectangleShape2D.new()
		box.size = platform_size
		_collision_shape.shape = box
		add_child(_collision_shape)

func _physics_process(delta: float) -> void:
	_time += delta
	
	# Reality check
	var rm: Node = get_node_or_null("/root/RealityManager")
	var is_active: bool = true
	if active_reality != -1:
		var current_reality: int = _reality_override
		if current_reality < 0 and rm:
			current_reality = int(rm.current_reality)
		is_active = current_reality == active_reality
		
	if _collision_shape:
		_collision_shape.set_deferred("disabled", not is_active)
	visible = is_active
	
	if not is_active:
		return
		
	# Smooth ping-pong easing between origin and target
	var progress: float = (sin((_time / travel_duration) * TAU - PI * 0.5) + 1.0) * 0.5
	global_position = _origin_pos + travel_offset * progress
	queue_redraw()

func _draw() -> void:
	var rect: Rect2 = Rect2(-platform_size / 2.0, platform_size)

	var visual_reality: int = _reality_override if _reality_override >= 0 else active_reality
	if visual_reality < 0:
		var reality_manager: Node = get_node_or_null("/root/RealityManager")
		visual_reality = int(reality_manager.current_reality) if reality_manager else RealityManager.Reality.REALITY_A
	var track_col: Color = RealityManager.COLOR_REALITY_A_PRIMARY if visual_reality == RealityManager.Reality.REALITY_A else RealityManager.COLOR_REALITY_B_PRIMARY

	# Solid platform body
	var is_reality_a: bool = visual_reality == RealityManager.Reality.REALITY_A
	var fill_col: Color = Color(0.22, 0.50, 0.56, 1.0) if is_reality_a else Color(0.18, 0.22, 0.30)
	var border_col: Color = Color(0.13, 0.33, 0.40, 1.0) if is_reality_a else Color(0.35, 0.45, 0.60)
	draw_rect(rect, fill_col, true)
	draw_rect(Rect2(rect.position + Vector2(0.0, 3.0), Vector2(rect.size.x, 4.0)), Color(0.28, 0.56, 0.63, 1.0) if is_reality_a else fill_col, true)
	if is_reality_a:
		draw_line(Vector2(rect.position.x + 2.0, rect.position.y + 7.0), Vector2(rect.end.x - 2.0, rect.position.y + 7.0), Color(0.41, 0.71, 0.76, 1.0), 1.0)
	draw_rect(rect, border_col, false, 1.5)

	# Reality-tinted hydraulic guide track
	var glow_col: Color = track_col
	if is_reality_a:
		glow_col = Color(0.15, 0.82, 0.93, 1.0)
		draw_line(Vector2(rect.position.x + 2.0, rect.position.y + 1.0), Vector2(rect.end.x - 2.0, rect.position.y + 1.0), glow_col, 2.0)
	else:
		glow_col.a = 0.20
		draw_line(Vector2(rect.position.x + 2.0, rect.position.y + 1.0), Vector2(rect.end.x - 2.0, rect.position.y + 1.0), glow_col, 3.0)
		draw_line(Vector2(rect.position.x + 2.0, rect.position.y + 1.0), Vector2(rect.end.x - 2.0, rect.position.y + 1.0), track_col, 1.5)

	draw_line(Vector2(rect.position.x + 8, 0), Vector2(rect.end.x - 8, 0), track_col, 2.0)
	
	# Direction arrow notches
	draw_circle(Vector2(-platform_size.x * 0.3, 0), 3.0, track_col)
	draw_circle(Vector2(platform_size.x * 0.3, 0), 3.0, track_col)
