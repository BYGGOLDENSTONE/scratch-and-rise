extends Node2D

## Ana sahne script'i. UI güncellemelerini GameState sinyalleriyle yapar.

@onready var coin_label: Label = %CoinLabel
@onready var bps_label: Label = %BPSLabel
@onready var stars_label: Label = %StarsLabel


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.bps_changed.connect(_on_bps_changed)
	SaveManager.load_game()
	_update_all_ui()
	print("[Main] Ready")


func _update_all_ui() -> void:
	_on_coins_changed(GameState.coins)
	_on_bps_changed(GameState.bps)
	stars_label.text = "⭐ 0"


func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = "💰 %s Coin" % GameState.format_number(new_amount)


func _on_bps_changed(new_bps: float) -> void:
	bps_label.text = "BPS: %.1f/sn" % new_bps
