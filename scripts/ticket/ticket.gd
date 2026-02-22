extends PanelContainer

## Bir bilet: grid içinde kazıma alanları, sembol ataması, tamamlanma kontrolü.

const TD = preload("res://scripts/systems/ticket_data.gd")

signal ticket_completed(symbols: Array)
signal area_revealed(area_index: int, symbol: String)

var ticket_type: String = "paper"
var _symbols: Array[String] = []
var _scratched_count: int = 0
var _total_areas: int = 0
var _scratch_area_scene := preload("res://scenes/ticket/ScratchArea.tscn")

@onready var _title_label: Label = $Margin/VBox/TitleLabel
@onready var _grid: GridContainer = $Margin/VBox/Grid


func setup(type: String) -> void:
	ticket_type = type
	var data := TD.get_ticket(type)

	_title_label.text = "🎫 %s Bilet" % data["name"]
	_grid.columns = data["cols"]
	_total_areas = data["cols"] * data["rows"]
	_scratched_count = 0

	# Sembolleri rastgele ata
	_symbols.clear()
	var available: Array = data["symbols"]
	for i in _total_areas:
		_symbols.append(available[randi() % available.size()])

	# Eski alanları temizle
	for child in _grid.get_children():
		child.queue_free()

	# Yeni alanları oluştur
	for i in _total_areas:
		var area := _scratch_area_scene.instantiate()
		_grid.add_child(area)
		area.setup(i, _symbols[i], TD.get_symbol_emoji(_symbols[i]))
		area.area_scratched.connect(_on_area_scratched)


func _on_area_scratched(area_index: int, symbol: String) -> void:
	_scratched_count += 1
	area_revealed.emit(area_index, symbol)

	# Scratch power: ek alanları otomatik kazı
	var extra := GameState.scratch_power - 1
	if extra > 0:
		_auto_scratch(extra)

	_check_completion()


func _auto_scratch(count: int) -> void:
	var unscratched: Array[Node] = []
	for area in _grid.get_children():
		if not area.is_scratched:
			unscratched.append(area)
	unscratched.shuffle()
	for i in mini(count, unscratched.size()):
		unscratched[i].scratch_silent()
		_scratched_count += 1


func _check_completion() -> void:
	if _scratched_count >= _total_areas:
		GameState.total_tickets_scratched += 1
		ticket_completed.emit(_symbols.duplicate())
		print("[Ticket] Completed! Symbols: ", _symbols)
