extends Node2D

## Ana sahne: bilet → kazıma → eşleşme → coin → yeni bilet döngüsü.

const MS = preload("res://scripts/systems/match_system.gd")
const UD = preload("res://scripts/systems/upgrade_data.gd")
const TD = preload("res://scripts/systems/ticket_data.gd")

const BD = preload("res://scripts/systems/building_data.gd")

var _ticket_scene := preload("res://scenes/ticket/Ticket.tscn")
var _result_scene := preload("res://scenes/ui/MatchResult.tscn")
var _upgrade_btn_scene := preload("res://scenes/ui/UpgradeButton.tscn")
var _building_btn_scene := preload("res://scenes/ui/BuildingButton.tscn")
var _offline_popup_scene := preload("res://scenes/ui/OfflinePopup.tscn")
var _stats_popup_scene := preload("res://scenes/ui/StatsPopup.tscn")
var _current_ticket: PanelContainer
var _current_result: PanelContainer

@onready var coin_label: Label = %CoinLabel
@onready var bps_label: Label = %BPSLabel
@onready var stars_label: Label = %StarsLabel
@onready var ticket_container: CenterContainer = %TicketContainer
@onready var upgrade_list: VBoxContainer = %UpgradeList
@onready var paper_btn: Button = %PaperBtn
@onready var bronze_btn: Button = %BronzeBtn
@onready var silver_btn: Button = %SilverBtn
@onready var reset_btn: Button = %ResetBtn
@onready var dev_add_btn: Button = %DevAddBtn
@onready var building_list: VBoxContainer = %BuildingList
@onready var stats_btn: Button = %StatsBtn

## Buton → bilet türü eşlemesi
var _ticket_buttons: Dictionary = {}


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.bps_changed.connect(_on_bps_changed)

	# Bilet seçim butonları
	_ticket_buttons = {
		"paper": paper_btn,
		"bronze": bronze_btn,
		"silver": silver_btn,
	}
	paper_btn.pressed.connect(_on_ticket_selected.bind("paper"))
	bronze_btn.pressed.connect(_on_ticket_selected.bind("bronze"))
	silver_btn.pressed.connect(_on_ticket_selected.bind("silver"))
	reset_btn.pressed.connect(_on_reset_pressed)
	dev_add_btn.pressed.connect(_on_dev_add)
	stats_btn.pressed.connect(_on_stats_pressed)

	# Dev butonlarını gizle (debug için .tscn'den visible açılabilir)
	dev_add_btn.visible = false
	reset_btn.visible = true

	SaveManager.load_game()
	_update_all_ui()
	_build_upgrade_panel()
	_build_building_panel()
	_spawn_new_ticket()
	_check_offline_earnings()
	print("[Main] Ready")


# --- Bilet Seçimi ---

func _on_ticket_selected(type: String) -> void:
	if type == GameState.current_ticket_type:
		return
	var data := TD.get_ticket(type)
	# Açılma kontrolü
	if GameState.total_coins_earned < data["unlock_at"]:
		return
	# Maliyet kontrolü
	if data["cost"] > 0 and GameState.coins < data["cost"]:
		return
	GameState.current_ticket_type = type
	_spawn_new_ticket()


func _update_ticket_buttons() -> void:
	for type in _ticket_buttons:
		var btn: Button = _ticket_buttons[type]
		var data := TD.get_ticket(type)
		var unlocked: bool = GameState.total_coins_earned >= int(data["unlock_at"])
		var is_selected: bool = GameState.current_ticket_type == type
		var can_afford: bool = int(data["cost"]) == 0 or GameState.coins >= int(data["cost"])

		if not unlocked:
			# Kilitli
			btn.disabled = true
			btn.text = "%s %s 🔒 (%s)" % [_ticket_icon(type), data["name"],
				GameState.format_number(data["unlock_at"]) + " coin'de açılır"]
		elif is_selected:
			# Seçili
			btn.disabled = true
			btn.text = "▶ %s %s" % [_ticket_icon(type), _ticket_cost_text(data)]
		elif not can_afford:
			# Para yetmez
			btn.disabled = true
			btn.text = "%s %s 💸" % [_ticket_icon(type), _ticket_cost_text(data)]
		else:
			# Alınabilir
			btn.disabled = false
			btn.text = "%s %s" % [_ticket_icon(type), _ticket_cost_text(data)]


func _ticket_icon(type: String) -> String:
	match type:
		"paper": return "📄"
		"bronze": return "🥉"
		"silver": return "🥈"
	return "🎫"


func _ticket_cost_text(data: Dictionary) -> String:
	if data["cost"] == 0:
		return "%s (Ücretsiz)" % data["name"]
	return "%s (%s Coin)" % [data["name"], GameState.format_number(data["cost"])]


# --- Bilet ---

func _spawn_new_ticket() -> void:
	if _current_ticket:
		_current_ticket.queue_free()
		_current_ticket = null
	if _current_result:
		_current_result.queue_free()
		_current_result = null

	var type := GameState.current_ticket_type
	var data := TD.get_ticket(type)

	# Maliyet düş (kağıt hariç)
	if data["cost"] > 0:
		if not GameState.spend_coins(data["cost"]):
			# Para yetmezse kağıt bilete geri dön
			GameState.current_ticket_type = "paper"
			type = "paper"

	_current_ticket = _ticket_scene.instantiate()
	ticket_container.add_child(_current_ticket)
	_current_ticket.setup(type)
	_current_ticket.ticket_completed.connect(_on_ticket_completed)
	_update_ticket_buttons()


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


func _build_building_panel() -> void:
	for building_id in BD.BUILDING_ORDER:
		var btn := _building_btn_scene.instantiate()
		building_list.add_child(btn)
		btn.setup(building_id)


# --- UI ---

func _update_all_ui() -> void:
	_on_coins_changed(GameState.coins)
	_on_bps_changed(GameState.bps)
	stars_label.text = "⭐ 0"
	_update_ticket_buttons()


func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = "💰 %s Coin" % GameState.format_number(new_amount)
	_update_ticket_buttons()
	# Coin label pulse animasyonu
	var tween := create_tween()
	tween.tween_property(coin_label, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(coin_label, "scale", Vector2.ONE, 0.12)


func _on_bps_changed(new_bps: float) -> void:
	bps_label.text = "BPS: %.1f/sn" % new_bps
	var tween := create_tween()
	tween.tween_property(bps_label, "scale", Vector2(1.1, 1.1), 0.08)
	tween.tween_property(bps_label, "scale", Vector2.ONE, 0.12)


# --- Reset ---

func _on_reset_pressed() -> void:
	GameState.coins = 0
	GameState.total_coins_earned = 0
	GameState.scratch_power = 1
	GameState.match_bonus_pct = 0.0
	GameState.current_ticket_type = "paper"
	GameState.bps = 0.0
	GameState.upgrades.clear()
	GameState.buildings.clear()
	GameState.total_tickets_scratched = 0
	GameState.total_matches = 0
	SaveManager.save_game()
	# Panelleri yeniden oluştur
	for child in upgrade_list.get_children():
		child.queue_free()
	for child in building_list.get_children():
		child.queue_free()
	_build_upgrade_panel()
	_build_building_panel()
	_update_all_ui()
	_spawn_new_ticket()
	print("[Main] Game reset!")


func _on_dev_add() -> void:
	GameState.add_coins(10_000)
	print("[Dev] +10K coin")


# --- Stats ---

func _on_stats_pressed() -> void:
	var popup := _stats_popup_scene.instantiate()
	get_node("UILayer").add_child(popup)


# --- Offline Gelir ---

func _check_offline_earnings() -> void:
	var result := SaveManager.calc_offline_earnings()
	if result.is_empty():
		return
	var popup := _offline_popup_scene.instantiate()
	get_node("UILayer").add_child(popup)
	popup.setup(result["elapsed"], result["earnings"])
