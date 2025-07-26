class_name InteractableZone
extends Node3D


signal focused
signal unfocused
signal noticed
signal unnoticed
signal player_entered
signal player_exited
signal pressed
signal holded
signal released

var is_noticed := false
var is_focused := false
var is_player_inside := false
var is_holding := false
var has_interacted := false
var has_released := false

var state : String :
	get():
		return $State.assigned_animation
	set(v):
		state = v
		$State.play(v)

@export var action_on_focus := false
@export var needs_player_inside := true
@export var press_action := "" :
	set(v):
		press_action = v
		#update_ui_key()

@export var hold_timeout := 0.0 :
	set(v):
		hold_timeout = v
		if is_inside_tree() and v > 0.0:
			$HoldTimeout.wait_time = v

## Enable or disable interactable zone
@export var enabled : bool = true :
	set(v):
		enabled = v
		if is_inside_tree():
			$FocusArea/CollisionShape3D.disabled = !v
			$PlayerArea/CollisionShape3D.disabled = !v


func is_game_class(_name : String) -> bool:
	return _name == "InteractableZone"


func is_interactable():
	return enabled and \
		(not needs_player_inside or is_player_inside) and \
		(is_noticed or (action_on_focus and is_focused))


func focus():
	if not is_focused:
		is_focused = true
		if is_interactable():
			$UI.show()
		focused.emit()


func unfocus():
	if is_focused:
		is_focused = false
		if not is_interactable():
			$UI.hide()
		unfocused.emit()


func _update_ui_key():
	%InteractionLabel.text = press_action
	if press_action.is_empty():
		%InteractionKey.text = ""
	elif InputMap.has_action(press_action):
		%InteractionKey.text = InputMap.action_get_events(press_action)[0].as_text().trim_suffix(" (Physical)")
	else:
		%InteractionKey.text = "??"

func _draw_debug_shape(color: Color):
	var _s = DebugDraw3D.new_scoped_config().set_thickness(0.02)
	for collision in [
		$FocusArea,
		#$PlayerArea,
	]:
		for collision_shape in collision.get_children():
			if collision_shape.get_class() in [
				"CollisionShape3D",
				"CollisionPolygon3D",
			]:
				match collision_shape.shape:
					var s when s is SphereShape3D:
						DebugDraw3D.draw_sphere(
							collision_shape.global_position,
							s.radius,
							color
						)
					var s when s is BoxShape3D:
						DebugDraw3D.draw_box(
							collision_shape.global_position,
							collision_shape.global_basis.get_rotation_quaternion(),
							s.size,
							color,
							true
						)

					var s when s is CylinderShape3D:
						var half_height_vector_up = Vector3.UP * s.height / 2.0
						DebugDraw3D.draw_cylinder_ab(
							collision_shape.global_transform * -half_height_vector_up,
							collision_shape.global_transform * half_height_vector_up,
							s.radius,
							color
						)
