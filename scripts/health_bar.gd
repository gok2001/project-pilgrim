extends ProgressBar

@export var player: Player


func _ready():
	max_value = player.max_health
	player.health_changed.connect(update_health)
	update_health()


func update_health():
	value = player.health
