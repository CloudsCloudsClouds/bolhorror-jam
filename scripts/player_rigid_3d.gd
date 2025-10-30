class_name PlayerRigid3D
extends RigidBody3D


@export var max_ground_speed: float = 3
@onready var ground_cast: ShapeCast3D = $GroundCast
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var model: Node3D = $HumanM_BasicMotionsFREE_2_6


var wish_dir := Vector3.ZERO
var ground_move := true
var blend_param := "parameters/BlendSpace2D/blend_position"
# Lambda time!
var is_on_floor := func () -> bool:
	ground_cast.force_shapecast_update()
	return ground_cast.is_colliding()

func _ready() -> void:
	activate_ground_mode()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity += wish_dir
	if ground_move:
		# Move getting the direction from the player
		
		if not state.linear_velocity.is_zero_approx() and wish_dir != Vector3.ZERO:
			model.rotation.y = lerp_angle(model.rotation.y, atan2(-wish_dir.x, -wish_dir.z), 0.1)

		# Limit ground speed
		var horizontal_velocity := Vector3(state.linear_velocity.x, 0, state.linear_velocity.z)
		var horizontal_speed := horizontal_velocity.length()
		if horizontal_speed > max_ground_speed:
			horizontal_velocity = horizontal_velocity.normalized() * max_ground_speed
			state.linear_velocity.x = horizontal_velocity.x
			state.linear_velocity.z = horizontal_velocity.z
		
		# Update animation blend parameters
		animation_tree.set(blend_param, Vector2(state.linear_velocity.x, state.linear_velocity.z))
	wish_dir = Vector3.ZERO

func activate_ground_mode() -> void:
	ground_move = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_angular_y = true

func deactivate_ground_mode() -> void:
	ground_move = false
	axis_lock_angular_x = false
	axis_lock_angular_z = false
	axis_lock_angular_y = false
