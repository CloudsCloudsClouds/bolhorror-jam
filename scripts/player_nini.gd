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
	player.axis_lock_angular_y = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta: float) -> void:
	var wish_dir := Vector3.ZERO
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if state == STATE.MOVEMENT:
		var input_rot := phantom_camera_3d.get_third_person_rotation().y
		wish_dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, input_rot)
		wish_dir = wish_dir.normalized() * 0.5
		player.wish_dir = wish_dir

		animation_tree.set(bs2d, Vector2(input_dir.x, input_dir.y))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rot_deg: Vector3

		pcam_rot_deg = phantom_camera_3d.get_third_person_rotation_degrees()
		# TODO Replace this magic number by propper mouse sensitivity setting
		pcam_rot_deg.x -= event.relative.y * 0.1
		# TODO replace magic number by propper min and max pitch settings
		pcam_rot_deg.x = clamp(pcam_rot_deg.x, -89, 89)
		pcam_rot_deg.y -= event.relative.x * 0.1
		pcam_rot_deg.y = wrapf(pcam_rot_deg.y, -180, 180)
		phantom_camera_3d.set_third_person_rotation_degrees(pcam_rot_deg)
