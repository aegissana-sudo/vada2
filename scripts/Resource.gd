extends Area2D

@export var resource_amount := 500

@onready var body_rect: ColorRect = $Body
@onready var label: Label = $Label

func _ready() -> void:
	body_rect.color = Color(0.2, 0.7, 0.3)
	label.text = str(resource_amount)
