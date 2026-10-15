class_name CoopPuzzleLink
extends Node

signal state_changed(is_active: bool)

var source: Object
var target: Node
var target_method: StringName
var source_signal: Signal
var _source_callback: Callable
var _has_applied_state: bool = false
var _last_applied_state: bool = false

func bind(source_switch: PuzzleSwitch, target_node: Node, method: StringName) -> bool:
	if source_switch == null:
		push_error("CoopPuzzleLink requires a puzzle switch source.")
		return false
	return bind_signal(source_switch.toggled, source_switch, target_node, method, source_switch.is_pressed)

func bind_signal(source_event: Signal, source_object: Object, target_node: Node, method: StringName, initial_state: bool) -> bool:
	if source_object == null or target_node == null or not target_node.has_method(method):
		push_error("CoopPuzzleLink requires a switch and a target implementing %s." % method)
		return false
	source = source_object
	target = target_node
	target_method = method
	source_signal = source_event
	_source_callback = Callable(self, "_on_source_toggled")
	source_signal.connect(_source_callback)
	_apply_state(initial_state, false)
	return true

func clear() -> void:
	if is_instance_valid(source) and _source_callback.is_valid() and source_signal.is_connected(_source_callback):
		source_signal.disconnect(_source_callback)
	source = null
	target = null

func _on_source_toggled(is_active: bool) -> void:
	_apply_state(is_active, true)

func _apply_state(is_active: bool, notify: bool) -> void:
	if not is_instance_valid(target):
		return
	if _has_applied_state and _last_applied_state == is_active:
		return
	target.call(target_method, is_active)
	_has_applied_state = true
	_last_applied_state = is_active
	if notify:
		state_changed.emit(is_active)
