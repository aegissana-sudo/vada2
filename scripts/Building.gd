extends Area2D

var selected := false

@onready var body_rect: ColorRect = $Body

func _ready() -> void:
	add_to_group("buildings")
	_update_visual()

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	_update_visual()

func _update_visual() -> void:
	if selected:
		body_rect.color = Color(1.0, 0.75, 0.2)
	else:
		body_rect.color = Color(0.6, 0.55, 0.5)
