extends CharacterBody2D


@onready var camera = $Camera2D
@onready var tilemap = get_parent().get_node('TileMap')

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
	
	if Input.is_action_just_pressed('jump') and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis('left', 'right')
	velocity.x = direction * WALK_SPEED

	move_and_slide()
