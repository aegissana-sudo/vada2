extends Area2D

signal resource_collected(amount: int)

@export var speed := 120.0
@export var gather_interval := 0.6
@export var gather_amount := 10
@export var interact_range := 18.0

var selected := false
var target_position: Vector2
var target_resource: Node = null
var gather_timer := 0.0

@onready var body_rect: ColorRect = $Body

func _ready() -> void:
	target_position = global_position
	add_to_group("units")
	_update_visual()

func _process(delta: float) -> void:
	if target_resource != null and not is_instance_valid(target_resource):
		target_resource = null
		gather_timer = 0.0

	if target_resource != null:
		target_position = target_resource.global_position
	var distance = global_position.distance_to(target_position)
	if distance > 4.0:
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta
		gather_timer = 0.0
	elif target_resource != null:
		gather_timer += delta
		if gather_timer >= gather_interval:
			gather_timer = 0.0
			if target_resource.has_method("take"):
				var gathered = target_resource.take(gather_amount)
				if gathered > 0:
					resource_collected.emit(gathered)
				if gathered < gather_amount:
					target_resource = null

func set_target(new_target: Vector2) -> void:
	target_position = new_target
	target_resource = null
	gather_timer = 0.0

func set_resource_target(resource: Node) -> void:
	target_resource = resource
	if resource != null:
		target_position = resource.global_position
	gather_timer = 0.0

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	_update_visual()

func _update_visual() -> void:
	if selected:
		body_rect.color = Color(0.2, 0.8, 1.0)
	else:
		body_rect.color = Color(0.85, 0.85, 0.85)
