extends Node3D

@onready var player: PlayerRigid3D = $PlayerRigid3D
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
var bs2d := "parameters/BlendSpace2D/blend_position"

enum STATE {
	# Walking around and iddle. The usual
	MOVEMENT,
	# Ragdoll driven free fall, until velocity is near zero and we can regain control
	THROW,
	# Kick. You kick the player so it goes flying in mid air
	# There is no jump here, it's a rage game!
	# So kick is the only way to get up. Very... entrophic
	KICK,
	# Getting up from ragdoll state
	GETTING_UP,
	# Jumpscare. The player got caught by la cholita sin cabeza
	# Of course there are jumpscares. This is a horror game!
	# It plays an animation and then kicks the player in a random direction
	# Possibly losing a ton of progress
	# Very sad
	# rip
	JUMPSCARE,
}

# I might need a propper state machine
var state: STATE = STATE.MOVEMENT

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta: float) -> void:
	var wish_dir := Vector3.ZERO
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	# If only there was a better name to describe a kick instead of a jump...
	var wish_kick := Input.is_action_just_pressed("jump")

	if state == STATE.MOVEMENT:
		var input_rot := phantom_camera_3d.get_third_person_rotation().y
		wish_dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, input_rot)
		wish_dir = wish_dir.normalized()
		player.wish_dir = wish_dir

		# Check if is on floor. If not, change state to THROW
		if not player.is_on_floor:
			state = STATE.THROW
			return
		
		# Check for wishing to kick input
		if wish_kick:
			state = STATE.KICK
			return
	

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
