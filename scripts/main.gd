extends Node2D

## Ana sahne: bilet → kazıma → eşleşme → coin → yeni bilet döngüsü.

const MS = preload("res://scripts/systems/match_system.gd")
const UD = preload("res://scripts/systems/upgrade_data.gd")

var _ticket_scene := preload("res://scenes/ticket/Ticket.tscn")
var _result_scene := preload("res://scenes/ui/MatchResult.tscn")
var _upgrade_btn_scene := preload("res://scenes/ui/UpgradeButton.tscn")
var _current_ticket: PanelContainer
var _current_result: PanelContainer

@onready var coin_label: Label = %CoinLabel
@onready var bps_label: Label = %BPSLabel
@onready var stars_label: Label = %StarsLabel
@onready var ticket_container: CenterContainer = %TicketContainer
@onready var upgrade_list: VBoxContainer = %UpgradeList


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.bps_changed.connect(_on_bps_changed)
	SaveManager.load_game()
	_update_all_ui()
	_build_upgrade_panel()
	_spawn_new_ticket()
	print("[Main] Ready")


# --- Bilet ---

func _spawn_new_ticket() -> void:
	if _current_ticket:
		_current_ticket.queue_free()
		_current_ticket = null
	if _current_result:
		_current_result.queue_free()
		_current_result = null

	_current_ticket = _ticket_scene.instantiate()
	ticket_container.add_child(_current_ticket)
	_current_ticket.setup(GameState.current_ticket_type)
	_current_ticket.ticket_completed.connect(_on_ticket_completed)


func _on_ticket_completed(symbols: Array) -> void:
	var result := MS.evaluate(symbols, GameState.current_ticket_type)

	# Yükseltme bonusu uygula
	var bonus_mult := 1.0 + GameState.match_bonus_pct / 100.0
	if bonus_mult > 1.0:
		var original: int = result["total"]
		result["total"] = int(result["total"] * bonus_mult)
		result["lines"].append({
			"text": "⬆ Bonus: x%.2f → +%d" % [bonus_mult, result["total"] - original],
			"type": "bonus",
		})

	GameState.add_coins(result["total"])
	if result["lines"].size() > 0 and result["lines"][0]["type"] != "consolation":
		GameState.total_matches += 1

	print("[Main] Match: %d coin (jackpot=%s)" % [result["total"], result["is_jackpot"]])

	_current_result = _result_scene.instantiate()
	ticket_container.add_child(_current_result)
	_current_result.setup(result)
	_current_result.dismissed.connect(_on_result_dismissed)


func _on_result_dismissed() -> void:
	_spawn_new_ticket()


# --- Yükseltmeler ---

func _build_upgrade_panel() -> void:
	for upgrade_id in UD.UPGRADE_ORDER:
		var btn := _upgrade_btn_scene.instantiate()
		upgrade_list.add_child(btn)
		btn.setup(upgrade_id)


# --- UI ---

func _update_all_ui() -> void:
	_on_coins_changed(GameState.coins)
	_on_bps_changed(GameState.bps)
	stars_label.text = "⭐ 0"


func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = "💰 %s Coin" % GameState.format_number(new_amount)


func _on_bps_changed(new_bps: float) -> void:
	bps_label.text = "BPS: %.1f/sn" % new_bps
