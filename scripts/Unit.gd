extends Area2D

@export var speed := 120.0

var selected := false
var target_position: Vector2

@onready var body_rect: ColorRect = $Body

func _ready() -> void:
	target_position = global_position
	_update_visual()

func _process(delta: float) -> void:
	var distance = global_position.distance_to(target_position)
	if distance > 4.0:
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta

func set_target(new_target: Vector2) -> void:
	target_position = new_target

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	_update_visual()

func _update_visual() -> void:
	if selected:
		body_rect.color = Color(0.2, 0.8, 1.0)
	else:
		body_rect.color = Color(0.85, 0.85, 0.85)
