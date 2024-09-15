extends Resource
class_name FishData

@export_group("Base")
@export var id: StringName
@export var name: String
@export var description: String
@export var icon: ImageTexture
@export_range(0.1, 20, 0.1) var number: float

@export_subgroup("Shadow")
@export_enum("Small", "Medium", "Large", "Huge", "Titanic") var shadow_size: String = "Medium"

@export_subgroup("Spawn Conditions")
@export_enum("None", "Rain", "Snow", "Clear", "Fog") var weather: String = "Clear"
@export var time_range: String
