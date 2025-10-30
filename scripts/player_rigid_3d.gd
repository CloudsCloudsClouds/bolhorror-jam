class_name PlayerRigid3D
extends RigidBody3D

@export var max_ground_speed: float = 3

var wish_dir := Vector3.ZERO
@onready var model: Node3D = $HumanM_BasicMotionsFREE_2_6
var ground_move := true
@onready var animation_tree: AnimationTree = $AnimationTree
var blend_param := "parameters/BlendSpace2D/blend_position"
var is_on_floor := false

func _ready() -> void:
	activate_ground_mode()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if ground_move:
		# Move getting the direction from the player
		state.linear_velocity += wish_dir
		if not state.linear_velocity.is_zero_approx() and wish_dir != Vector3.ZERO:
			model.rotation.y = lerp_angle(model.rotation.y, atan2(-wish_dir.x, -wish_dir.z), 0.1)
		wish_dir = Vector3.ZERO

		# Limit ground speed
		var horizontal_velocity := Vector3(state.linear_velocity.x, 0, state.linear_velocity.z)
		var horizontal_speed := horizontal_velocity.length()
		if horizontal_speed > max_ground_speed:
			horizontal_velocity = horizontal_velocity.normalized() * max_ground_speed
			state.linear_velocity.x = horizontal_velocity.x
			state.linear_velocity.z = horizontal_velocity.z
		
		# Update animation blend parameters
		animation_tree.set(blend_param, Vector2(state.linear_velocity.x, state.linear_velocity.z))

		# Check if still on floor
		# Contact count is set in 3 because sometimes idiot player gets into a corner
		for i in state.get_contact_count():
			var contact_normal := state.get_contact_local_normal(i)
			# BUG: This works. But only if the floor contact is the last one on the for
			# is_on_floor = contact_normal.dot(Vector3.UP) > 0.9
			if contact_normal.dot(Vector3.UP) > 0.9:
				is_on_floor = true
				return
			is_on_floor = false

func activate_ground_mode() -> void:
	ground_move = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_angular_y = true
