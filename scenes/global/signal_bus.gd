extends Node

@warning_ignore("unused_signal")
signal hour_passed(prev_hour)
@warning_ignore("unused_signal")
signal fish_bited()
@warning_ignore("unused_signal")
signal fish_hooked(fish: FishData)
@warning_ignore("unused_signal")
signal minigame_completed(got_caught: bool, fish: FishData)
@warning_ignore("unused_signal")
signal zone_entered(zone_name: String)
