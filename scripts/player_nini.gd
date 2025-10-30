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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta: float) -> void:
	var wish_dir := Vector3.ZERO
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if Input.is_action_pressed("move_forward"):
		player.wish_dir = -phantom_camera_3d.transform.basis.z.normalized()
	if Input.is_action_pressed("move_backward"):
		player.wish_dir = phantom_camera_3d.transform.basis.z.normalized()
	if Input.is_action_pressed("move_left"):
		player.wish_dir = -phantom_camera_3d.transform.basis.x.normalized()
	if Input.is_action_pressed("move_right"):
		player.wish_dir = phantom_camera_3d.transform.basis.x.normalized()
