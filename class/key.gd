class_name Key
extends Resource

var name: String
var description : String

static func createNew(name:String, desc:String) -> Key:
	var newKey = Key.new()
	newKey.name = name
	newKey.description = desc
	return newKey
