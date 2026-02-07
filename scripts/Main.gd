extends Node2D

@export var unit_scene: PackedScene
@export var building_scene: PackedScene
@export var resource_scene: PackedScene

var selected_units: Array[Node] = []
var selected_building: Node = null
var resource_stockpile := 150
var status_message := ""

const UNIT_COST := 50

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	if unit_scene == null:
		unit_scene = preload("res://scenes/Unit.tscn")
	if building_scene == null:
		building_scene = preload("res://scenes/Building.tscn")
	if resource_scene == null:
		resource_scene = preload("res://scenes/Resource.tscn")

	_spawn_starting_entities()
	_update_hud()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(event.position, event.shift_pressed)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_issue_move_command(event.position)

	if event.is_action_pressed("spawn_unit"):
		_spawn_unit_from_selected_building()

func _handle_left_click(click_position: Vector2, additive: bool) -> void:
	status_message = ""
	var hit = _pick_entity(click_position)
	if not additive:
		_clear_selection()

	if hit == null:
		_update_hud()
		return

	if hit.is_in_group("units"):
		_select_unit(hit)
		selected_building = null
	elif hit.is_in_group("buildings"):
		_select_building(hit)

	_update_hud()

func _issue_move_command(target_position: Vector2) -> void:
	var target_resource = _pick_entity(target_position)
	for unit in selected_units:
		if target_resource != null and target_resource.is_in_group("resources"):
			if unit.has_method("set_resource_target"):
				unit.set_resource_target(target_resource)
		elif unit.has_method("set_target"):
			unit.set_target(target_position)

func _select_unit(unit: Node) -> void:
	if not selected_units.has(unit):
		selected_units.append(unit)
	if unit.has_method("set_selected"):
		unit.set_selected(true)

func _select_building(building: Node) -> void:
	selected_building = building
	if building.has_method("set_selected"):
		building.set_selected(true)

func _clear_selection() -> void:
	for unit in selected_units:
		if unit.has_method("set_selected"):
			unit.set_selected(false)
	selected_units.clear()

	if selected_building != null and selected_building.has_method("set_selected"):
		selected_building.set_selected(false)
	selected_building = null

func _pick_entity(screen_position: Vector2) -> Node:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = screen_position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1
	var results: Array[Dictionary] = space_state.intersect_point(query, 1)
	if results.size() == 0:
		return null
	var collider = results[0].get("collider")
	return collider as Node

func _spawn_unit_from_selected_building() -> void:
	if selected_building == null:
		status_message = "Выберите штаб, чтобы нанять юнита."
		_update_hud()
		return
	if unit_scene == null:
		return
	if resource_stockpile < UNIT_COST:
		status_message = "Недостаточно ресурсов для найма."
		_update_hud()
		return
	var unit = unit_scene.instantiate()
	add_child(unit)
	unit.global_position = selected_building.global_position + Vector2(48, 0)
	resource_stockpile -= UNIT_COST
	_register_unit(unit)
	status_message = "Нанят новый юнит."
	_update_hud()

func _spawn_starting_entities() -> void:
	var building = building_scene.instantiate()
	add_child(building)
	building.global_position = Vector2(200, 220)

	for i in range(3):
		var unit = unit_scene.instantiate()
		add_child(unit)
		unit.global_position = Vector2(140 + i * 40, 300)
		_register_unit(unit)

	for i in range(2):
		var resource = resource_scene.instantiate()
		add_child(resource)
		resource.global_position = Vector2(380 + i * 80, 200)

func _register_unit(unit: Node) -> void:
	if unit.has_signal("resource_collected"):
		unit.resource_collected.connect(_on_resource_collected)

func _on_resource_collected(amount: int) -> void:
	resource_stockpile += amount
	_update_hud()

func _update_hud() -> void:
	var info = "ЛКМ: выбор, ПКМ: приказ на движение/сбор, B: нанять юнита (%d)" % UNIT_COST
	info += "\nРесурсы: %d" % resource_stockpile
	if selected_units.size() > 0:
		info += "\nВыбрано юнитов: %d" % selected_units.size()
	if selected_building != null:
		info += "\nВыбрано здание: Штаб"
	if status_message != "":
		info += "\n" + status_message
	hud_label.text = info
