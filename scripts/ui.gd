extends CanvasLayer

const DOWN_DIRECTION_ICON = preload("res://data/images/down_direction_icon.png")
const LEFT_DIRECTION_ICON = preload("res://data/images/left_direction_icon.png")
const RIGHT_DIRECTION_ICON = preload("res://data/images/right_direction_icon.png")
const UP_DIRECTION_ICON = preload("res://data/images/up_direction_icon.png")


@onready var step_counter: Label = $UI/StepCounter
@onready var route_steps_keyset: Label = $UI/RouteStepsKeyset
@onready var step_info_menu: MenuButton = $UI/TopRightElems/StepInfo

#room selection info components
@onready var room_select_position: Label = $UI/TopRightElems/RoomSelectionInfo/layout/Position
@onready var room_select_borders: MenuButton = $UI/TopRightElems/RoomSelectionInfo/layout/ColumnContainer/Borders
@onready var room_select_rewards: MenuButton = $UI/TopRightElems/RoomSelectionInfo/layout/ColumnContainer/Content


@onready var main_scene: Node2D = $".."


signal stage_changed()
@onready var advance_btn: Button = $AdvanceBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_step_info(0)
	main_scene.room_selected.connect(display_room_info.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func display_step_desc(current_stage:int):
	step_counter.text = STEP_DESCRIPTIONS[current_stage]
	step_counter.text += '\n' + str(Utils.generator_stage)

func display_room_info():
	var selected_mu = Level.map.get_mu_at(main_scene.selected_room_pos)
	#display position
	room_select_position.text = str(main_scene.selected_room_pos)
	#MU content
	room_select_rewards.disabled = false
	var content_popup:PopupMenu = room_select_rewards.get_popup()
	content_popup.clear(true)
	content_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
	content_popup.add_item('Trap room' if selected_mu.parent_room.is_trap else 'Normal room')
	content_popup.set_item_disabled(-1, true)
	content_popup.add_separator()
	if selected_mu.is_fast_travel:
		content_popup.add_item('Warp point')
		content_popup.set_item_disabled(-1, true)
	if selected_mu.is_major_boss:
		content_popup.add_item('Major boss enemy')
		content_popup.set_item_disabled(-1, true)
	if selected_mu.is_minor_boss:
		content_popup.add_item('Combat encounter')
		content_popup.set_item_disabled(-1, true)
	if selected_mu.is_save:
		content_popup.add_item('Save point')
		content_popup.set_item_disabled(-1, true)
	if selected_mu.is_shop:
		content_popup.add_item('Shop')
		content_popup.set_item_disabled(-1, true)
	if selected_mu.is_spawn:
		content_popup.add_item('Initial spawn point')
		content_popup.set_item_disabled(-1, true)
	content_popup.add_separator()
	for reward:Reward in selected_mu.rewards:
		content_popup.add_item(reward.name)
		content_popup.set_item_disabled(-1, true)
	#MU borders
	room_select_borders.disabled = false
	var borders_popup:PopupMenu = room_select_borders.get_popup()
	borders_popup.clear(true)
	borders_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
	for direction:Utils.direction in range(4):
		if selected_mu.borders[direction] == Utils.border_type.LOCKED_DOOR:
			var specific_border_popup = PopupMenu.new()
			specific_border_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
			#gate keys
			for i:int in len(selected_mu.border_data[direction].keyset):
				specific_border_popup.add_item(selected_mu.border_data[direction].keyset[i].name)
				specific_border_popup.set_item_disabled(-1, true)
			specific_border_popup.add_separator()
			#gate final state
			specific_border_popup.add_item(Utils.gate_state_to_str(selected_mu.border_data[direction]))
			specific_border_popup.set_item_disabled(-1, true)
			#gate directionality
			specific_border_popup.add_item(Utils.gate_direction_to_str(selected_mu.border_data[direction]))
			specific_border_popup.set_item_disabled(-1, true)
			borders_popup.add_submenu_node_item(Utils.border_type_name(selected_mu.borders[direction]) ,specific_border_popup)
		else:
			borders_popup.add_item(Utils.border_type_name(selected_mu.borders[direction]))
			borders_popup.set_item_disabled(-1, true)
		borders_popup.set_item_icon(-1, _get_direction_icon(direction))

func _get_direction_icon(dir:Utils.direction) -> Resource:
	match (dir):
		Utils.direction.UP:
			return UP_DIRECTION_ICON
		Utils.direction.DOWN:
			return DOWN_DIRECTION_ICON
		Utils.direction.LEFT:
			return LEFT_DIRECTION_ICON
		Utils.direction.RIGHT:
			return RIGHT_DIRECTION_ICON
	return null

func load_step_info(current_stage:int):
	var step_popup:PopupMenu = step_info_menu.get_popup()
	step_popup.clear(true)
	for step:RouteStep in Level.route_steps:
		var new_option_popup:PopupMenu = PopupMenu.new()
		new_option_popup.title = 'Step ' + str(step.index)
		#add areas submenu
		var new_area_popup:PopupMenu = PopupMenu.new()
		new_area_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
		new_area_popup.title = 'View step areas'
		new_area_popup.add_item('Areas in step ' + str(step.index) + ':')
		new_area_popup.set_item_disabled(-1, true)
		new_area_popup.add_separator()
		for area:AreaPoint in step.areas:
			new_area_popup.add_item(str(area.area_index))
			new_area_popup.set_item_disabled(-1, true)
		new_option_popup.add_submenu_node_item(new_area_popup.title, new_area_popup)
		#add rewards submenu
		var new_rewards_popup:PopupMenu = PopupMenu.new()
		new_rewards_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
		new_rewards_popup.title = 'View step rewards'
		new_rewards_popup.add_item('Step ' + str(step.index) + ' rewards:')
		new_rewards_popup.set_item_disabled(-1, true)
		new_rewards_popup.add_separator()
		#add keyset
		for key:Reward in step.keyset:
			if key is MainUpgrade:
				var main_upgrade_popup:PopupMenu = PopupMenu.new()
				main_upgrade_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
				main_upgrade_popup.add_item(key.description)
				main_upgrade_popup.set_item_disabled(-1, true)
				new_rewards_popup.add_submenu_node_item(key.name, main_upgrade_popup)
			elif key is KeyItem:
				var key_item_popup:PopupMenu = PopupMenu.new()
				key_item_popup.add_theme_color_override('font_disabled_color', Color.WHITE)
				key_item_popup.add_item(key.description)
				key_item_popup.set_item_disabled(-1, true)
				key_item_popup.add_separator()
				for kiu:KeyItemUnit in key.kius:
					key_item_popup.add_item(kiu.name)
					key_item_popup.set_item_disabled(-1, true)
				new_rewards_popup.add_submenu_node_item(key.name, key_item_popup)
		new_rewards_popup.add_separator()
		#add other rewards
		for reward:Reward in step.reward_pool:
			new_rewards_popup.add_item(reward.name)
			new_rewards_popup.set_item_disabled(-1, true)
		new_option_popup.add_submenu_node_item(new_rewards_popup.title, new_rewards_popup)
		#add to parent
		step_popup.add_submenu_node_item(new_option_popup.title, new_option_popup)

func _on_advance_btn_button_down() -> void:
	Utils.generator_stage += 1
	display_step_desc(Utils.generator_stage)
	stage_changed.emit()
	
	if Utils.generator_stage == 7: load_step_info(7)

const STEP_DESCRIPTIONS = [
	'',
	'Place area points',
	'Expand area points',
	'Establish initial area',
	'Establish area connections',
	'Designate area order',
	'Establish hub-containing area if applicable',
	'Distribute route steps',
	'Place essential points',
	'Place additional points for route step rewards',
	'Expand area subpoints',
	'Assign inter-area connection points',
	'Establish area subpoint connections',
	'Assign fast travel points',
	'Assign side upgrade, main upgrade and key item unit points',
	'Place rooms for all points',
	'Prepare hub zone',
	'Map intra-area connections',
	'Set save points',
	'Extrude keyset points, create boss rooms and create looping paths',
	'Distribute minor rewards',
	'Recalculate room areas',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
]
