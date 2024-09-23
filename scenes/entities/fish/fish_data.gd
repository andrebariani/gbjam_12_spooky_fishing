extends Resource
class_name FishData

@export_group("Base")
@export var id: StringName
@export var name: String
@export var icon: CompressedTexture2D = preload("res://assets/fish_icon.png")
@export var sprite: CompressedTexture2D
@export var galery_photo: CompressedTexture2D
@export_multiline var description: String
@export var bait: BaitData = preload("res://scenes/items/maggot.tres")
@export var stamina: float = 0
@export var mooch_bait: BaitData = null
@export_enum("Static", "Fidgety") var behavior: String = "Static"
@export_range(0.1, 20, 0.1) var size_centimeters: float

@export_subgroup("Nibble Logic")
## If set, it will nibble on the bait a fixed number of times
@export var is_fixed_attempts: bool = false
## Times the fish it will nibble before taking a bite 
@export var max_attempts: int = 7
@export var min_interval: float= 0.3
@export var max_interval: float=  3.0
@export var hook_window: float = 3.0

@export_subgroup("Shadow")
enum SHADOW_SIZE {SMALL, MEDIUM, LARGE, HUGE, TITANIC}
@export var shadow_size: SHADOW_SIZE = SHADOW_SIZE.MEDIUM

@export_subgroup("Spawn Conditions")
enum RARITY {COMMON, UNCOMMON, RARE, LEGENDARY}
@export var rarity: RARITY = RARITY.COMMON
enum WEATHER {ANY, RAIN, SNOW, CLEAR, FOG}
@export var weather: WEATHER = WEATHER.ANY
@export var is_timed_only: bool = false
@export_range(0, 23, 1, "or_greater", "or_less") var start_time_window: int
@export_range(0, 23, 1, "or_greater", "or_less") var end_time_window: int
