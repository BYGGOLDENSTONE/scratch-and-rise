extends PanelContainer

## İstatistik popup'ı. Oyuncu verilerini gösterir.

signal closed

@onready var _stats_list: VBoxContainer = $Margin/VBox/StatsList
@onready var _close_btn: Button = $Margin/VBox/CloseBtn


func _ready() -> void:
	_close_btn.pressed.connect(_on_close)
	_populate()


func _populate() -> void:
	for child in _stats_list.get_children():
		child.queue_free()

	var stats := [
		["💰 Mevcut Coin", GameState.format_number(GameState.coins)],
		["💰 Toplam Kazanılan", GameState.format_number(GameState.total_coins_earned)],
		["🎫 Kazınan Bilet", str(GameState.total_tickets_scratched)],
		["✨ Toplam Eşleşme", str(GameState.total_matches)],
		["⬆ Kazıma Gücü", str(GameState.scratch_power)],
		["📈 Eşleşme Bonusu", "%.1f%%" % GameState.match_bonus_pct],
		["🏗 BPS", "%.1f/sn" % GameState.bps],
		["🎫 Aktif Bilet", GameState.current_ticket_type.capitalize()],
	]

	for entry in stats:
		var hbox := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = entry[0]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var value_label := Label.new()
		value_label.text = entry[1]
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(name_label)
		hbox.add_child(value_label)
		_stats_list.add_child(hbox)


func _on_close() -> void:
	closed.emit()
	queue_free()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		accept_event()
