extends PanelContainer

## Tek bir yükseltme kartı. Satın alma, seviye gösterimi, maliyet kontrolü.

const UD = preload("res://scripts/systems/upgrade_data.gd")

var _upgrade_id: String
var _data: Dictionary

@onready var _name_label: Label = $Margin/VBox/Header/NameLabel
@onready var _level_label: Label = $Margin/VBox/Header/LevelLabel
@onready var _desc_label: Label = $Margin/VBox/DescLabel
@onready var _buy_btn: Button = $Margin/VBox/BuyBtn


func setup(upgrade_id: String) -> void:
	_upgrade_id = upgrade_id
	_data = UD.UPGRADES[upgrade_id]
	_name_label.text = _data["name"]
	_desc_label.text = _data["description"]
	_buy_btn.pressed.connect(_on_buy)
	GameState.coins_changed.connect(_refresh)
	_refresh(GameState.coins)


func _refresh(_coins: int = 0) -> void:
	var level := GameState.get_upgrade_level(_upgrade_id)
	var max_level: int = _data["max_level"]
	_level_label.text = "Lv %d/%d" % [level, max_level]

	if level >= max_level:
		_buy_btn.text = "MAX ✔"
		_buy_btn.disabled = true
	else:
		var cost := GameState.calc_cost(_data["base_cost"], level)
		_buy_btn.text = "💰 %s" % GameState.format_number(cost)
		_buy_btn.disabled = GameState.coins < cost


func _on_buy() -> void:
	var level := GameState.get_upgrade_level(_upgrade_id)
	if level >= _data["max_level"]:
		return
	var cost := GameState.calc_cost(_data["base_cost"], level)
	if GameState.spend_coins(cost):
		GameState.upgrades[_upgrade_id] = level + 1
		GameState.recalculate_upgrades()
		_refresh()
		print("[Upgrade] %s → Lv %d" % [_data["name"], level + 1])
