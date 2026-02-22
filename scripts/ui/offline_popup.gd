extends PanelContainer

## "Hoş Geldin Geri!" offline gelir popup'ı.

signal collected

@onready var _time_label: Label = $Margin/VBox/TimeLabel
@onready var _earnings_label: Label = $Margin/VBox/EarningsLabel
@onready var _collect_btn: Button = $Margin/VBox/CollectBtn


func setup(elapsed: float, earnings: int) -> void:
	_time_label.text = "⏱ Uzakta geçen süre: %s" % _format_time(elapsed)
	_earnings_label.text = "💰 +%s Coin kazandın!" % GameState.format_number(earnings)
	_collect_btn.pressed.connect(_on_collect.bind(earnings))


func _format_time(seconds: float) -> String:
	var secs := int(seconds)
	if secs < 3600:
		return "%d dk" % (secs / 60)
	var hours := secs / 3600
	var mins := (secs % 3600) / 60
	if hours >= 24:
		return "%d sa %d dk" % [hours, mins]
	return "%d sa %d dk" % [hours, mins]


func _on_collect(earnings: int) -> void:
	GameState.add_coins(earnings)
	collected.emit()
	queue_free()
