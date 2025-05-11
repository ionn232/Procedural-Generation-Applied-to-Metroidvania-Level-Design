class_name RewardPool
extends Resource

static func import_reward_pool():
	#this should be importing info from somewhere. ideally.
	keyset.resize(25) #TODO: make not hard-coded
	var num_main_upgrades:int = len(main_upgrades)
	for i:int in range(len(keyset)):
		#add main upgrades
		if i < num_main_upgrades - 1:
			keyset[i] = main_upgrades[i]
		#add key items
		else:
			keyset[i] = key_items[i - num_main_upgrades]

static func _make_key_item(name: String, desc: String, unit_names: Array[String]) -> KeyItem:
	var units:Array[KeyItemUnit] = []
	for unit_name in unit_names:
		units.append(KeyItemUnit.createNew(unit_name, 'part of ' + name))
	var item = KeyItem.createNew(name, desc)
	item.assign_units(units)
	return item

static var main_upgrades:Array = [
	MainUpgrade.createNew('double jump', 'allows user to jump a second time before touching the ground'),
	MainUpgrade.createNew('dash', 'quick burst of speed in any direction'),
	MainUpgrade.createNew('wall climb', 'grants ability to climb certain wall surfaces'),
	MainUpgrade.createNew('ground slam', 'enables a powerful downward slam while airborne'),
	MainUpgrade.createNew('glide', 'slows fall speed and allows for longer horizontal movement'),
	MainUpgrade.createNew('grapple', 'hook onto grapple points to swing or pull'),
	MainUpgrade.createNew('time slow', 'temporarily slows down time for precise movements'),
	MainUpgrade.createNew('water boots', 'allows walking through water'),
	MainUpgrade.createNew('charged attack', 'hold attack button to deal increased damage'),
	MainUpgrade.createNew('magic dash', 'quick burst of speed that lets you cross magic barriers'),
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
static var keyset:Array = [] #type: Array[MainUpgrade || KeyItem]
static var equipment:Array = []
static var collectibles:Array = []
