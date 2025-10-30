class_name PlayerRigid3D
extends RigidBody3D

var wish_dir := Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = wish_dir
