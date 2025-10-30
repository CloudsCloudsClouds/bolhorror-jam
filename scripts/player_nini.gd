extends Node3D

@onready var player: PlayerRigid3D = $PlayerRigid3D
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var arrow: CSGCombiner3D = $PlayerRigid3D/Arrow
var bs2d := "parameters/BlendSpace2D/blend_position"


enum STATE {
	# Walking around and iddle. The usual
	MOVEMENT,
	# Ragdoll driven free fall, until velocity is near zero and we can regain control
	# I have no idea yet how to implement ragdoll in Godot 4
	THROW,
	# Kick. You kick the player so it goes flying in mid air
	# There is no jump here, it's a rage game!
	# So kick is the only way to get up
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

# The transitions
# 1. MOVEMENT -> THROW : If player is not on floor
# 2. THROW -> GETTING_UP : If velocity is near zero and on floor
# 3. GETTING_UP -> MOVEMENT : After getting up animation is done
# 4. MOVEMENT -> KICK : If player inputs kick
# 5. ANY -> JUMPSCARE : If jumpscare is triggered by game event
# 6. JUMPSCARE -> THROW : JUMPSCARE ends with a kick in random direction, entering THROW state

# PlayerRigid is kind of an extension of RigidBody3D
# It has no state
# The idea is to manage state here and send commands to PlayerRigid3D


# Simple state machine helpers
signal state_changed(old_state, new_state)
var state: STATE = STATE.THROW


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# Ignore mouse motion if mouse is not captured
			# No accidental camera movement when in UI mode
			return
		var pcam_rot_deg: Vector3

		pcam_rot_deg = phantom_camera_3d.get_third_person_rotation_degrees()
		# TODO Replace this magic number by propper mouse sensitivity setting
		pcam_rot_deg.x -= event.relative.y * 0.1
		# TODO replace magic number by propper min and max pitch settings
		pcam_rot_deg.x = clamp(pcam_rot_deg.x, -89, 89)
		pcam_rot_deg.y -= event.relative.x * 0.1
		pcam_rot_deg.y = wrapf(pcam_rot_deg.y, -180, 180)
		phantom_camera_3d.set_third_person_rotation_degrees(pcam_rot_deg)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	change_state(STATE.MOVEMENT)

func _physics_process(_delta: float) -> void:
	run_state_machine(_delta)


func run_state_machine(_delta: float) -> void:
	match state:
		STATE.MOVEMENT:
			var wish_dir := Vector3.ZERO
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
			# If only there was a better name to describe a kick instead of a jump...
			var wish_kick := Input.is_action_just_pressed("jump")

			
			var input_rot := phantom_camera_3d.get_third_person_rotation().y
			wish_dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, input_rot)
			wish_dir = wish_dir.normalized()
			player.wish_dir = wish_dir

			# Check if is on floor. If not, change state to THROW
			# For free fall
			# BUG: This is bugged. Sometimes is_on_floor is false even when on floor
			"""
			if not player.is_on_floor:
				change_state(STATE.THROW)
				return
			"""
			# TODO: Maybe the player should have a dedicated button for throwing themselves to the ground? To activate the ragdoll. For the fun of it
			
			# Check for wishing to kick input
			if wish_kick:
				change_state(STATE.KICK)
				return
		STATE.THROW:
			# Ragdoll state
			pass
		STATE.KICK:
			# Kicking state
			pass
		STATE.GETTING_UP:
			# Getting up state
			pass
		STATE.JUMPSCARE:
			# Jumpscare state
			pass

func change_state(new_state: STATE) -> void:
	if new_state == state:
		return
	var old_state := state
	_exit_state(old_state)
	state = new_state
	_enter_state(state)
	emit_signal("state_changed", old_state, state)

func _enter_state(s: STATE) -> void:
	match s:
		STATE.MOVEMENT:
			# Regain player control
			# e.g. stop ragdoll, enable input processing, reset timers
			# player.exit_ragdoll()  # implement on PlayerRigid3D if needed
			arrow.visible = false
			print_debug("Entered MOVEMENT state")
		STATE.THROW:
			# Enter ragdoll / physics-driven behaviour
			# e.g. player.enter_ragdoll()
			pass
		STATE.KICK:
			# Perform kick: apply impulse / play animation
			# e.g. player.apply_kick()
			pass
		STATE.GETTING_UP:
			# Play getting up animation, block input until done
			pass
		STATE.JUMPSCARE:
			# Play jumpscare animation + effects
			pass

func _exit_state(s: STATE) -> void:
	match s:
		STATE.MOVEMENT:
			# Clean up movement state if needed
			pass
		STATE.THROW:
			# Prepare for leaving ragdoll (e.g. smooth to animated pose)
			pass
		STATE.KICK:
			# End kick-specific flags
			pass
		STATE.GETTING_UP:
			# Finish getting up transition
			pass
		STATE.JUMPSCARE:
			# Cleanup jumpscare effects
			pass

func is_state(s: STATE) -> bool:
	return state == s

func state_name(s: int) -> String:
	match s:
		STATE.MOVEMENT: return "MOVEMENT"
		STATE.THROW: return "THROW"
		STATE.KICK: return "KICK"
		STATE.GETTING_UP: return "GETTING_UP"
		STATE.JUMPSCARE: return "JUMPSCARE"
		_ : return "UNKNOWN"
