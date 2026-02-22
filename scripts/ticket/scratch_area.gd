extends Panel

## Tek bir kazıma alanı. Tıkla veya sürükle → sembol açılır.

signal area_scratched(area_index: int, symbol: String)

var symbol: String = ""
var area_index: int = 0
var is_scratched: bool = false

@onready var _symbol_label: Label = $SymbolLabel
@onready var _cover: ColorRect = $Cover


func setup(index: int, symbol_id: String, emoji: String) -> void:
	area_index = index
	symbol = symbol_id
	_symbol_label.text = emoji


func _gui_input(event: InputEvent) -> void:
	if is_scratched:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			scratch()
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			scratch()


## Normal kazıma — sinyal gönderir
func scratch() -> void:
	if is_scratched:
		return
	is_scratched = true
	_cover.visible = false
	_symbol_label.visible = true
	area_scratched.emit(area_index, symbol)


## Sessiz kazıma — scratch_power ek alanları için (sinyal yok)
func scratch_silent() -> void:
	if is_scratched:
		return
	is_scratched = true
	_cover.visible = false
	_symbol_label.visible = true
