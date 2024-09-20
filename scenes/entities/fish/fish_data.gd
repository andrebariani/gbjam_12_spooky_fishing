extends Resource
class_name FishData

@export_group("Base")
@export var id: StringName
@export var name: String
@export var icon: ImageTexture
@export var description: String
@export var is_moochable: bool
@export var stamina: float
@export_enum("Static", "Fidgety") var behavior: String = "Static"
@export_range(0.1, 20, 0.1) var size_centimeters: float

@export_subgroup("Nibble Logic")
@export var is_fixed_attempts: bool = false
@export var max_attempts: int = 7
@export var min_interval: float= 0.3
@export var max_interval: float=  3.0
@export var hook_window: float = 3.0

@export_subgroup("Shadow")
enum SHADOW_SIZE {SMALL, MEDIUM, LARGE, HUGE, TITANIC}
@export var shadow_size: SHADOW_SIZE = SHADOW_SIZE.MEDIUM

@export_subgroup("Spawn Conditions")
@export_enum("None", "Rain", "Snow", "Clear", "Fog") var weather: String = "Clear"
@export var is_timed_only: bool
@export_range(0, 23, 1, "or_greater", "or_less") var time_window: int
