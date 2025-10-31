# Here for the main attraction
class_name Cholita
extends Area3D


# Alright. Very very broadly
# - If player doesn't move in like 10 or 15 seconds, it spawns
# - If player doesn't move in like 10 seconds more, it starts getting closer
# - Gets too close and the scene resets
# - If at any given moment, players jumps, it despawns

@export var follow_player: PlayerNini
@export var move_speed: float = 0
@export var spawn_distance: float = 10
@export var spawn_variance: float = 5

enum STATE {
	DESPAWNED,
	WAITING,
	WATCHING,
	FOLLOWING
}
var state: STATE = STATE.DESPAWNED

var wait_timer: Timer = Timer.new()
var watch_timer: Timer = Timer.new()

func _ready() -> void:
	follow_player.connect("state_changed", watch_player_state)
	wait_timer.one_shot = true
	watch_timer.one_shot = true
	
	add_child(wait_timer)
	add_child(watch_timer)
	

	wait_timer.connect("timeout", func () -> void:
		position = follow_player.player.global_transform.origin + Vector3(
			spawn_distance + randf() * spawn_variance,
			0,
			spawn_distance + randf() * spawn_variance
		)
		state = STATE.WATCHING
		watch_timer.start(10 + randf() * 5)
	)
	watch_timer.connect("timeout", func () -> void:
		state = STATE.FOLLOWING
	)

	connect("body_entered", func (_body: Node) -> void:
		if _body == follow_player.player:
			get_tree().reload_current_scene()
	)

func _physics_process(delta: float) -> void:
	match state:
		STATE.DESPAWNED:
			# Hiding. Doing nothing
			visible = false
			$CollisionShape3D.disabled = true
		STATE.WAITING:
			# Waiting to spawn
			$CollisionShape3D.disabled = false
			visible = false
		STATE.WATCHING:
			# Just standing there, watching
			$CollisionShape3D.disabled = true
			visible = true
			rotation.y = lerp_angle(rotation.y, atan2(
				follow_player.global_transform.origin.x - global_transform.origin.x,
				follow_player.global_transform.origin.z - global_transform.origin.z
			), 0.02)
		STATE.FOLLOWING:
			# Following the player
			# (!!)
			visible = true
			$CollisionShape3D.disabled = true
			var direction := (follow_player.player.global_transform.origin - global_transform.origin).normalized()
			global_transform.origin += direction * move_speed * delta


func watch_player_state(_old_state, new_state) -> void:
	if new_state == PlayerNini.STATE.MOVEMENT:
		state = STATE.WAITING
		wait_timer.start(5 + randf() * 5)
	elif new_state == PlayerNini.STATE.THROW:
		state = STATE.DESPAWNED
