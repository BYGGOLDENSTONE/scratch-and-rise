extends PanelContainer

## Eşleşme sonuç popup'ı. Detayları gösterir, tıkla veya süre ile kapanır.

signal dismissed

@onready var _title: Label = $Margin/VBox/Title
@onready var _details: VBoxContainer = $Margin/VBox/Details
@onready var _total_label: Label = $Margin/VBox/TotalLabel

var _auto_close_time := 2.5


func setup(result: Dictionary) -> void:
	# Başlık
	if result["is_jackpot"]:
		_title.text = "🎰 JACKPOT! 🎰"
	elif result["total"] > 0 and result["lines"][0]["type"] != "consolation":
		_title.text = "✨ EŞLEŞME! ✨"
	else:
		_title.text = "😅 Şansız Bilet"

	# Detay satırları
	for child in _details.get_children():
		child.queue_free()

	for line in result["lines"]:
		var lbl := Label.new()
		lbl.text = line["text"]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if line["type"] == "jackpot":
			lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
			lbl.add_theme_font_size_override("font_size", 16)
		elif line["type"] == "consolation":
			lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		_details.add_child(lbl)

	# Toplam
	_total_label.text = "💰 +%s Coin!" % GameState.format_number(result["total"])
	if result["is_jackpot"]:
		_total_label.add_theme_font_size_override("font_size", 22)

	# Otomatik kapanma
	await get_tree().create_timer(_auto_close_time).timeout
	_dismiss()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_dismiss()


func _dismiss() -> void:
	dismissed.emit()
	queue_free()
