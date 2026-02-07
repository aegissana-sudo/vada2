extends Area2D

@export var resource_amount := 500

@onready var body_rect: ColorRect = $Body
@onready var label: Label = $Label

func _ready() -> void:
	add_to_group("resources")
	body_rect.color = Color(0.2, 0.7, 0.3)
	_update_label()

func take(amount: int) -> int:
	if resource_amount <= 0:
		return 0
	var taken := min(resource_amount, amount)
	resource_amount -= taken
	_update_label()
	if resource_amount <= 0:
		queue_free()
	return taken

func _update_label() -> void:
	label.text = str(resource_amount)
