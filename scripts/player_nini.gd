extends Node3D

@onready var player: PlayerRigid3D = $PlayerRigid3D
@onready var skeleton_3d: Skeleton3D = $PlayerRigid3D/HumanM_BasicMotionsFREE_2_6/Rig/Skeleton3D
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var animation_tree: AnimationTree = $AnimationTree
var bs2d := "parameters/BlendSpace2D/blend_position"

enum STATE {
	MOVEMENT,
	THROW
}
var state: STATE = STATE.MOVEMENT

func _ready() -> void:
	player.axis_lock_angular_x = true
	player.axis_lock_angular_z = true

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("move_forward"):
		pass
	if Input.is_action_pressed("move_backward"):
		pass
	if Input.is_action_pressed("move_left"):
		pass
	if Input.is_action_pressed("move_right"):
		pass
