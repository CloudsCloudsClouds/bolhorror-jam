# Here for the main attraction
class_name Cholita
extends Area3D


# Alright. Very very broadly
# - If player doesn't move in like 10 or 15 seconds, it spawns
# - If player doesn't move in like 10 seconds more, it starts getting closer
# - Gets too close and the scene resets
# - If at any given moment, players jumps, it despawns

@export var follow_player: PlayerRigid3D
@export var move_speed: float = 0
@export var spawn_distance: float = 10
@export var spawn_variance: float = 5

var is_watching: bool = false
var is_following: bool = false

func _physics_process(delta: float) -> void:
    # This means it's despawned
    if not is_watching and not is_following:
        pass
    elif is_watching and not is_following:
        # Just watch the player from a distance
        look_at(follow_player.global_transform.origin, Vector3.UP)
    elif is_following:
        # Move towards the player
        var direction_to_player := (follow_player.global_transform.origin - global_transform.origin).normalized()
        look_at(follow_player.global_transform.origin, Vector3.UP)
        global_transform.origin += direction_to_player * move_speed * delta
        
        # Check if too close
        var distance_to_player := global_transform.origin.distance_to(follow_player.global_transform.origin)
        if distance_to_player < 2.0:
            # Reset the scene
            get_tree().reload_current_scene()