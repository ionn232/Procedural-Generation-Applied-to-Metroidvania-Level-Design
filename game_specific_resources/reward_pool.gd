class_name RewardPool
extends Resource

static func import_reward_pool():
	#this should be importing info from somewhere. ideally.
	keyset.resize(25) #TODO: make not hard-coded
	var num_main_upgrades:int = len(main_upgrades)
	for i:int in range(len(keyset)):
		#add main upgrades
		if i < num_main_upgrades:
			keyset[i] = main_upgrades[i]
		#add key items
		else:
			var item = key_items[i - num_main_upgrades]
			keyset[i] = key_items[i - num_main_upgrades]


static var keyset:Array = [] #type: Array[MainUpgrade || KeyItem]

static var main_upgrades:Array = [
	MainUpgrade.createNew('double jump', 'allows user to jump a second time before touching the ground'),
	MainUpgrade.createNew('dash', 'quick burst of speed in any direction'),
	MainUpgrade.createNew('wall climb', 'grants ability to climb certain wall surfaces'),
	MainUpgrade.createNew('ground slam', 'enables a powerful downward slam while airborne'),
	MainUpgrade.createNew('glide', 'slows fall speed and allows for longer horizontal movement'),
	MainUpgrade.createNew('grapple', 'hook onto grapple points to swing or pull'),
	MainUpgrade.createNew('time slow', 'temporarily slows down time'),
	MainUpgrade.createNew('water boots', 'allows walking through water'),
	MainUpgrade.createNew('charged attack', 'hold attack button to deal increased damage'),
	MainUpgrade.createNew('pogo jump', 'allows jumping on enemies and spikes without taking damage'),
	MainUpgrade.createNew('lava boots', 'walk on lava or hot surfaces without taking damage'),
	MainUpgrade.createNew('water mantle', 'allows traversing through water as if it was air'),
	MainUpgrade.createNew('blink', 'short-range teleport through obstacles'),
	MainUpgrade.createNew('light aura', 'illuminates dark areas and reveals secrets'),
	MainUpgrade.createNew('mega hit', 'a wide swing that leaves you unprotected for some time'),
]

static var key_items:Array = [
	_make_key_item('small key', 'a small key made out of three fragments', [
		'small key fragment 1', 'small key fragment 2', 'small key fragment 3']),
	_make_key_item('ancient coin', 'a complete coin made from two halves', [
		'coin half A', 'coin half B']),
	_make_key_item('crystal badge', 'badge assembled from four shards', [
		'crystal shard top', 'crystal shard bottom', 'left shard', 'right shard']),
	_make_key_item('mystic seal', 'a magical seal pieced from runes', [
		'rune alpha', 'rune beta', 'rune gamma']),
	_make_key_item('temple key', 'forged from parts found in forgotten shrines', [
		'temple gear', 'temple gem', 'temple core']),
	_make_key_item('emblem of fire', 'symbol of fire, made of flame parts', [
		'flame piece 1', 'flame piece 2', 'flame crest']),
	_make_key_item('ocean medallion', 'assembled from underwater pieces', [
		'pearl fragment', 'coral fragment', 'shell core']),
	_make_key_item('cursed locket', 'reconstructed from haunted relics', [
		'chain link', 'silver pendant', 'obsidian shard']),
	_make_key_item('ancient tablet', 'tablet completed from broken segments', [
		'tablet corner 1', 'tablet corner 2', 'center piece']),
	_make_key_item('wind charm', 'a charm blessed by wind spirits', [
		'feather token', 'air essence', 'whistle core', 'tassel']),
]
static func _make_key_item(name: String, desc: String, unit_names: Array[String]) -> KeyItem:
	var units:Array[KeyItemUnit] = []
	for unit_name in unit_names:
		units.append(KeyItemUnit.createNew(unit_name, 'part of ' + name))
	var item = KeyItem.createNew(name, desc)
	item.assign_units(units)
	return item
	
static var side_upgrades:Array[SideUpgrade] = [
	SideUpgrade.createNew('Fire projectile', 'Shoots a blazing fireball'),
	SideUpgrade.createNew('Ice projectile', 'Shoots freezing ice pellets'),
	SideUpgrade.createNew('Wind projectile', 'Shoots a gust of wind'),
	SideUpgrade.createNew('Electric projectile', 'Discharges a shocking current'),
	SideUpgrade.createNew('Poison projectile', 'Shoots a poisoning dart'),
	SideUpgrade.createNew('Dark projectile', 'Blinds an enemy for a brief time'),
	SideUpgrade.createNew('Auto-repair', 'Stand still for a brief time to start healing gradually'),
	SideUpgrade.createNew('Radar', 'Reacts to nearby treasure'),
	SideUpgrade.createNew('Return', 'Return to the previous save point at no additional cost'),
]

static var equipment:Array[Equipment] = [
	Equipment.createNew('Equipment1', 'A piece of equipment'),
	Equipment.createNew('Equipment2', 'A piece of equipment'),
	Equipment.createNew('Equipment3', 'A piece of equipment'),
	Equipment.createNew('Equipment4', 'A piece of equipment'),
	Equipment.createNew('Equipment5', 'A piece of equipment'),
	Equipment.createNew('Equipment6', 'A piece of equipment'),
	Equipment.createNew('Equipment7', 'A piece of equipment'),
	Equipment.createNew('Equipment8', 'A piece of equipment'),
	Equipment.createNew('Equipment9', 'A piece of equipment'),
	Equipment.createNew('Equipment10', 'A piece of equipment'),
	Equipment.createNew('Equipment11', 'A piece of equipment'),
	Equipment.createNew('Equipment12', 'A piece of equipment'),
	Equipment.createNew('Equipment13', 'A piece of equipment'),
	Equipment.createNew('Equipment14', 'A piece of equipment'),
	Equipment.createNew('Equipment15', 'A piece of equipment'),
	Equipment.createNew('Equipment16', 'A piece of equipment'),
	Equipment.createNew('Equipment17', 'A piece of equipment'),
	Equipment.createNew('Equipment18', 'A piece of equipment'),
	Equipment.createNew('Equipment19', 'A piece of equipment'),
	Equipment.createNew('Equipment20', 'A piece of equipment'),
	Equipment.createNew('Equipment21', 'A piece of equipment'),
	Equipment.createNew('Equipment22', 'A piece of equipment'),
	Equipment.createNew('Equipment23', 'A piece of equipment'),
	Equipment.createNew('Equipment24', 'A piece of equipment'),
	Equipment.createNew('Equipment25', 'A piece of equipment'),
	Equipment.createNew('Equipment26', 'A piece of equipment'),
	Equipment.createNew('Equipment27', 'A piece of equipment'),
	Equipment.createNew('Equipment28', 'A piece of equipment'),
	Equipment.createNew('Equipment29', 'A piece of equipment'),
	Equipment.createNew('Equipment30', 'A piece of equipment'),
	Equipment.createNew('Equipment31', 'A piece of equipment'),
	Equipment.createNew('Equipment32', 'A piece of equipment'),
	Equipment.createNew('Equipment33', 'A piece of equipment'),
	Equipment.createNew('Equipment34', 'A piece of equipment'),
	Equipment.createNew('Equipment35', 'A piece of equipment'),
	Equipment.createNew('Equipment36', 'A piece of equipment'),
	Equipment.createNew('Equipment37', 'A piece of equipment'),
	Equipment.createNew('Equipment38', 'A piece of equipment'),
	Equipment.createNew('Equipment39', 'A piece of equipment'),
	Equipment.createNew('Equipment40', 'A piece of equipment'),
	Equipment.createNew('Equipment41', 'A piece of equipment'),
	Equipment.createNew('Equipment42', 'A piece of equipment'),
	Equipment.createNew('Equipment43', 'A piece of equipment'),
	Equipment.createNew('Equipment44', 'A piece of equipment'),
	Equipment.createNew('Equipment45', 'A piece of equipment'),
	Equipment.createNew('Equipment46', 'A piece of equipment'),
	Equipment.createNew('Equipment47', 'A piece of equipment'),
	Equipment.createNew('Equipment48', 'A piece of equipment'),
	Equipment.createNew('Equipment49', 'A piece of equipment'),
	Equipment.createNew('Equipment50', 'A piece of equipment'),
]

static var collectibles:Array[Collectible] = [
	Collectible.createNew('Collectible1', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible2', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible3', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible4', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible5', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible6', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible7', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible8', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible9', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible10', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible11', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible12', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible13', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible14', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible15', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible16', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible17', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible18', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible19', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible20', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible21', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible22', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible23', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible24', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible25', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible26', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible27', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible28', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible29', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible30', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible31', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible32', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible33', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible34', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible35', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible36', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible37', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible38', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible39', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible40', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible41', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible42', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible43', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible44', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible45', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible46', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible47', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible48', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible49', 'A shiny stone, must have some use'),
	Collectible.createNew('Collectible50', 'A shiny stone, must have some use'),
]

static var stat_upgrades:Array[StatUpgrade] = [
	StatUpgrade.createNew('HP upgrade 1', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 2', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 3', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 4', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 5', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 6', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 7', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 8', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 9', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 10', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 11', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 12', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 13', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 14', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 15', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 16', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 17', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 18', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 19', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 20', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 21', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 22', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 23', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 24', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 25', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 26', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 27', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 28', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 29', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 30', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 31', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 32', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 33', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 34', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 35', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 36', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 37', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 38', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 39', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 40', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 41', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 42', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 43', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 44', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 45', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 46', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 47', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 48', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 49', 'Increses health points'),
	StatUpgrade.createNew('HP upgrade 50', 'Increses health points'),
]
