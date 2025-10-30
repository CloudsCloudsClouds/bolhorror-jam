class_name PlayerRigid3D
extends RigidBody3D

var wish_dir := Vector3.ZERO
@onready var model: Node3D = $HumanM_BasicMotionsFREE_2_6

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity += wish_dir
	if not state.linear_velocity.is_zero_approx():
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-wish_dir.x, -wish_dir.z), 0.1)
	wish_dir = Vector3.ZERO
