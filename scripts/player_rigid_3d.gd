class_name PlayerRigid3D
extends RigidBody3D

@export var max_ground_speed: float = 3

var wish_dir := Vector3.ZERO
@onready var model: Node3D = $HumanM_BasicMotionsFREE_2_6
var ground_move := true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
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
