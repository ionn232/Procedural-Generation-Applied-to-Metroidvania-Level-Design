extends Node

@onready var generator: MapGenerator = $".."

func execute(): ##randomly place around areas a point for each main upgrade, key item unit and side upgrades.
	for current_step:RouteStep in Level.route_steps:
		#main upgrades
		if current_step.keyset[0] is MainUpgrade:
			var main_upgrade:MainUpgrade = current_step.keyset[0]
			var chosen_area:AreaPoint = current_step.areas[Utils.rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(
				Utils.rng.randf_range(-generator.area_size_rooms_xy.x/2.0,generator.area_size_rooms_xy.x/2.0), 
				Utils.rng.randf_range(-generator.area_size_rooms_xy.y/2.0, generator.area_size_rooms_xy.y/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.reward_pool.push_back(main_upgrade)
			chosen_area.subpoints.push_back(new_point)
		#key items
		elif current_step.keyset[0] is KeyItem:
			var key_item:KeyItem = current_step.keyset[0]
			for KIU:KeyItemUnit in key_item.kius:
				var chosen_area:AreaPoint = current_step.areas[Utils.rng.randi_range(0, len(current_step.areas) - 1)]
				var random_pos:Vector2 = Vector2(
					Utils.rng.randf_range(-generator.area_size_rooms_xy.x/2.0,generator.area_size_rooms_xy.x/2.0), 
					Utils.rng.randf_range(-generator.area_size_rooms_xy.y/2.0, generator.area_size_rooms_xy.y/2.0))
				var new_point = Point.createNew(random_pos)
				chosen_area.reward_pool.push_back(KIU)
				chosen_area.subpoints.push_back(new_point)
		#side upgrades
		var rs_side_upgrades:Array[Reward] = current_step.get_side_upgrades()
		for side_upgrade:SideUpgrade in rs_side_upgrades:
			var chosen_area:AreaPoint = current_step.areas[Utils.rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(
				Utils.rng.randf_range(-generator.area_size_rooms_xy.x/2.0,generator.area_size_rooms_xy.x/2.0), 
				Utils.rng.randf_range(-generator.area_size_rooms_xy.y/2.0, generator.area_size_rooms_xy.y/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.reward_pool.push_back(side_upgrade)
			chosen_area.subpoints.push_back(new_point)
	#add new nodes
	for area:AreaPoint in Level.area_points:
		area.add_subarea_nodes()
		area.calculate_intra_area_distance()
