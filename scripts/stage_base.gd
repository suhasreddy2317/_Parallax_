class_name StageBase
extends Node2D

## StageBase
## Base class for campaign stages in RESPawn: PARALLAX.

signal stage_completed(next_stage: int, player_id: int)
signal checkpoint_reached(checkpoint_id: int, pos: Vector2)

@export var stage_index: int = 1
@export var stage_title: String = "STAGE 01: FIRST CONTACT"
@export var stage_objective: String = "Traverse the fractured facility and reach the transit gate."
@export var default_spawn_position: Vector2 = Vector2(120.0, 480.0)
@export var abyss_kill_y: float = 720.0

var active_checkpoint: Vector2 = Vector2.ZERO
var active_checkpoint_id: int = 0
var _visual_reality_override: int = -1

func _ready() -> void:
	active_checkpoint = default_spawn_position
	active_checkpoint_id = 0
	_connect_checkpoints_and_exits()
	var reality_manager: Node = get_node_or_null("/root/RealityManager")
	if reality_manager and reality_manager.has_signal("reality_changed"):
		if not reality_manager.reality_changed.is_connected(_on_stage_reality_changed):
			reality_manager.reality_changed.connect(_on_stage_reality_changed)
		_update_static_block_palette(int(reality_manager.current_reality))

func _connect_checkpoints_and_exits() -> void:
	for child in find_children("*", "CheckpointTerminal", true, false):
		var cp: CheckpointTerminal = child as CheckpointTerminal
		if not cp.checkpoint_activated.is_connected(_on_checkpoint_activated):
			cp.checkpoint_activated.connect(_on_checkpoint_activated)

	for child in find_children("*", "ExitPortal", true, false):
		var ep: ExitPortal = child as ExitPortal
		if not ep.exit_reached.is_connected(_on_exit_reached):
			ep.exit_reached.connect(_on_exit_reached)

func configure_cooperative_reality(reality: int) -> void:
	_visual_reality_override = reality
	_update_static_block_palette(reality)
	var required_player_id: int = reality + 1
	for child in find_children("*", "ExitPortal", true, false):
		(child as ExitPortal).required_player_id = required_player_id

func _on_stage_reality_changed(reality: int) -> void:
	if _visual_reality_override < 0:
		_update_static_block_palette(reality)

func get_visual_reality() -> int:
	if _visual_reality_override >= 0:
		return _visual_reality_override
	var reality_manager: Node = get_node_or_null("/root/RealityManager")
	return int(reality_manager.current_reality) if reality_manager else RealityManager.Reality.REALITY_A

func _update_static_block_palette(reality: int) -> void:
	var is_reality_a: bool = reality == RealityManager.Reality.REALITY_A
	for block in find_children("*", "StaticBody2D", true, false):
		if block.is_in_group("stage_static_block"):
			_update_static_block_palette_for_body(block as StaticBody2D, is_reality_a)

func _on_checkpoint_activated(cp_id: int, pos: Vector2) -> void:
	if cp_id > active_checkpoint_id:
		active_checkpoint_id = cp_id
		active_checkpoint = pos
		checkpoint_reached.emit(cp_id, pos)

func _on_exit_reached(next_stage: int, player_id: int) -> void:
	stage_completed.emit(next_stage, player_id)

## Helper to create static geometry block
func create_static_block(pos: Vector2, size: Vector2, border_color: Color = Color(0.25, 0.32, 0.45)) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = pos
	body.add_to_group("stage_static_block")
	
	var col: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = size
	col.shape = box
	body.add_child(col)
	
	var rect_vis: ColorRect = ColorRect.new()
	rect_vis.color = Color(0.10, 0.12, 0.16)
	rect_vis.set_meta("default_visual_color", rect_vis.color)
	rect_vis.size = size
	rect_vis.position = -size / 2.0
	body.add_child(rect_vis)

	var top_surface: ColorRect = ColorRect.new()
	top_surface.set_meta("stage_platform_top_surface", true)
	top_surface.set_meta("default_visual_color", rect_vis.color)
	top_surface.size = Vector2(size.x, 4.0)
	top_surface.position = Vector2(-size.x / 2.0, -size.y / 2.0 + 3.0)
	body.add_child(top_surface)

	var inner_highlight: ColorRect = ColorRect.new()
	inner_highlight.set_meta("stage_platform_inner_highlight", true)
	inner_highlight.set_meta("default_visual_color", rect_vis.color)
	inner_highlight.size = Vector2(size.x, 1.0)
	inner_highlight.position = Vector2(-size.x / 2.0, -size.y / 2.0 + 7.0)
	body.add_child(inner_highlight)

	var top_edge: ColorRect = ColorRect.new()
	top_edge.set_meta("stage_platform_top_edge", true)
	top_edge.set_meta("default_visual_color", border_color)
	top_edge.size = Vector2(size.x, 3.0)
	top_edge.position = Vector2(-size.x / 2.0, -size.y / 2.0)
	body.add_child(top_edge)
	
	var border: ReferenceRect = ReferenceRect.new()
	border.border_color = border_color
	border.set_meta("default_visual_color", border_color)
	border.border_width = 1.5
	border.editor_only = false
	border.size = size
	border.position = -size / 2.0
	body.add_child(border)
	
	var reality_manager: Node = get_node_or_null("/root/RealityManager")
	var visual_reality: int = _visual_reality_override
	if visual_reality < 0:
		visual_reality = int(reality_manager.current_reality) if reality_manager else RealityManager.Reality.REALITY_A
	_update_static_block_palette_for_body(body, visual_reality == RealityManager.Reality.REALITY_A)
	add_child(body)
	return body

func _update_static_block_palette_for_body(body: StaticBody2D, is_reality_a: bool) -> void:
	for visual in body.get_children():
		if visual is ColorRect:
			if visual.has_meta("stage_platform_top_edge"):
				visual.color = Color(0.15, 0.82, 0.93, 1.0) if is_reality_a else visual.get_meta("default_visual_color", Color(0.25, 0.32, 0.45))
			elif visual.has_meta("stage_platform_top_surface"):
				visual.color = Color(0.28, 0.56, 0.63, 1.0) if is_reality_a else visual.get_meta("default_visual_color", Color(0.10, 0.12, 0.16))
			elif visual.has_meta("stage_platform_inner_highlight"):
				visual.color = Color(0.41, 0.71, 0.76, 1.0) if is_reality_a else visual.get_meta("default_visual_color", Color(0.10, 0.12, 0.16))
			else:
				visual.color = Color(0.22, 0.50, 0.56, 1.0) if is_reality_a else visual.get_meta("default_visual_color", Color(0.10, 0.12, 0.16))
		elif visual is ReferenceRect:
			visual.border_color = Color(0.13, 0.33, 0.40, 1.0) if is_reality_a else visual.get_meta("default_visual_color", Color(0.25, 0.32, 0.45))
