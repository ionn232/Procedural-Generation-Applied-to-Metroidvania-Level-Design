extends CanvasLayer

@onready var step_counter: Label = $UI/StepCounter
@onready var route_step_info: Label = $UI/RouteStepInfo
@onready var route_steps_keyset: Label = $UI/RouteStepsKeyset
@onready var step_info_menu: MenuButton = $UI/StepInfo


signal stage_changed()
@onready var advance_btn: Button = $AdvanceBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_step_info(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_rs_info():
	route_step_info.text = ''
	for RS:RouteStep in Level.route_steps:
		route_step_info.text += '\n---------------------------------------------------------------\n'
		route_step_info.text += 'RS' + str(RS.index) + ' with areas: '
		for area in RS.areas:
			route_step_info.text += str(area.area_index)

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

func display_step_desc(current_stage:int):
	step_counter.text = STEP_DESCRIPTIONS[current_stage]
	step_counter.text += '\n' + str(Utils.generator_stage)

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
		new_rewards_popup.add_item('Step ' + str(step.index) + ' keyset:')
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
