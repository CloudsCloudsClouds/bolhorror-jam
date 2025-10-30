class_name PlayerRigid3D
extends RigidBody3D


@export var max_ground_speed: float = 3
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var model: Node3D = $HumanM_BasicMotionsFREE_2_6
@onready var ground_cast: ShapeCast3D = $Sep/GroundCast


var wish_dir := Vector3.ZERO
var ground_move := true
var blend_param := "parameters/BlendSpace2D/blend_position"
# Lambda time!
var is_on_floor := func () -> bool:
	ground_cast.force_shapecast_update()
	return ground_cast.is_colliding()


var trying_to_get_up := false

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
	elif !ground_move and not trying_to_get_up:
		# Just stop rotation a bit
		state.angular_velocity *= 0.98
	elif trying_to_get_up:
		# Holy this is systems of control
		# KISS. Just lerp and get this over
		state.angular_velocity = Vector3.ZERO
		rotation.x = lerp_angle(rotation.x, 0.0, 0.05)
		rotation.z = lerp_angle(rotation.x, 0.0, 0.05)
		
		# see if close enough
		if abs(rotation.x) <= deg_to_rad(1) and abs(rotation.z) <= deg_to_rad(1):
			rotation.x = 0
			rotation.z = 0
			activate_ground_mode()
	wish_dir = Vector3.ZERO

func _physics_process(_delta: float) -> void:
	ground_cast.position = position

func activate_ground_mode() -> void:
	ground_move = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	axis_lock_angular_y = true
	trying_to_get_up = false

func deactivate_ground_mode() -> void:
	ground_move = false
	axis_lock_angular_x = false
	axis_lock_angular_z = false
	axis_lock_angular_y = false
