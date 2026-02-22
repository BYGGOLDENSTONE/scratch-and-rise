extends PanelContainer

## Tek bir building kartı. Satın alma, adet gösterimi, BPS katkısı.

const BD = preload("res://scripts/systems/building_data.gd")

var _building_id: String
var _data: Dictionary

@onready var _name_label: Label = $Margin/VBox/Header/NameLabel
@onready var _count_label: Label = $Margin/VBox/Header/CountLabel
@onready var _desc_label: Label = $Margin/VBox/DescLabel
@onready var _buy_btn: Button = $Margin/VBox/BuyBtn


func setup(building_id: String) -> void:
	_building_id = building_id
	_data = BD.BUILDINGS[building_id]
	_name_label.text = _data["name"]
	_desc_label.text = "%s (BPS: +%.1f)" % [_data["description"], _data["bps"]]
	_buy_btn.pressed.connect(_on_buy)
	GameState.coins_changed.connect(_refresh)
	_refresh(GameState.coins)


func _refresh(_coins: int = 0) -> void:
	var count := GameState.get_building_count(_building_id)
	var total_bps: float = count * _data["bps"]
	if count > 0:
		_count_label.text = "x%d (%.1f BPS)" % [count, total_bps]
	else:
		_count_label.text = "x0"

	var cost := GameState.calc_cost(int(_data["base_cost"]), count)
	_buy_btn.text = "💰 %s" % GameState.format_number(cost)
	_buy_btn.disabled = GameState.coins < cost


func _on_buy() -> void:
	var count := GameState.get_building_count(_building_id)
	var cost := GameState.calc_cost(int(_data["base_cost"]), count)
	if GameState.spend_coins(cost):
		GameState.buildings[_building_id] = count + 1
		GameState.recalculate_buildings()
		_refresh()
		print("[Building] %s → x%d" % [_data["name"], count + 1])
