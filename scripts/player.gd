extends CharacterBody2D
class_name Player

signal health_changed

@onready var camera = $Camera2D
@onready var tilemap = get_parent().get_node('TileMap')

@export var max_health := 10
@onready var health: int = max_health

var is_invulnerable := false
var knockback_vector := Vector2.ZERO

@onready var rays_left = $Raycasts/Left.get_children()
@onready var rays_right = $Raycasts/Right.get_children()

var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')
const WALK_SPEED = 300.0
const JUMP_VELOCITY = -500.0


func _ready():
	set_camera_limits()


func set_camera_limits():
	if tilemap:
		var map_rect = tilemap.get_used_rect()
		var cell_size = tilemap.tile_set.tile_size

		camera.limit_left = map_rect.position.x * cell_size.x
		camera.limit_top = map_rect.position.y * cell_size.y
		camera.limit_right = (map_rect.position.x + map_rect.size.x) * cell_size.x
		camera.limit_bottom = (map_rect.position.y + map_rect.size.y) * cell_size.y


func _physics_process(delta: float):
	velocity.y += delta * gravity

	if not is_invulnerable:
		var direction = Input.get_axis('left', 'right') * WALK_SPEED
		velocity.x = direction + knockback_vector.x

		if Input.is_action_just_pressed('jump') and is_on_floor():
			velocity.y = JUMP_VELOCITY

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector

	move_and_slide()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group('spikes') and not is_invulnerable:
		modulate.a = 0.5
		var knockback_direction = get_knockback_direction()
		var knockback_force = Vector2(400 * knockback_direction, -400)

		take_damage(1, knockback_force)
		$HurtTimer.start()


func take_damage(amount := 1, knockback_force := Vector2.ZERO, duration := 0.25):
	health -= amount
	if health <= 0:
		queue_free()

	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force

		var knockback_tween := get_tree().create_tween()
		knockback_tween.tween_property(
			self,
			'knockback_vector',
			Vector2.ZERO,
			duration
		)

	is_invulnerable = true
	health_changed.emit()


func _on_hurt_timer_timeout() -> void:
	modulate.a = 1
	is_invulnerable = false


func get_knockback_direction() -> int:
	var hit_left := rays_left.any(func(r): return r.is_colliding())
	var hit_right := rays_right.any(func(r): return r.is_colliding())

	if hit_left and not hit_right:
		return 1
	elif hit_right and not hit_left:
		return -1
	return 0
