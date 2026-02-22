extends Node

## Oyun durumunu tutan global autoload.
## Tüm sistemler buradan okur/yazar.

const TD = preload("res://scripts/systems/ticket_data.gd")
const BD = preload("res://scripts/systems/building_data.gd")

# --- Sinyaller ---
signal coins_changed(new_amount: int)
signal bps_changed(new_bps: float)
signal ticket_type_changed(new_type: String)

# --- Para ---
var coins: int = 0:
	set(value):
		coins = max(value, 0)
		coins_changed.emit(coins)

var total_coins_earned: int = 0

# --- Kazıma ---
var scratch_power: int = 1  # Tıklama başına kazınan alan sayısı (hesaplanmış)

# --- Yükseltme Bonusları (hesaplanmış) ---
var match_bonus_pct: float = 0.0  # Eşleşme ödülü bonus yüzdesi

# --- Bilet ---
var current_ticket_type: String = "paper":
	set(value):
		current_ticket_type = value
		ticket_type_changed.emit(current_ticket_type)

# --- BPS (Bilet Per Second) ---
var bps: float = 0.0:
	set(value):
		bps = value
		bps_changed.emit(bps)

# --- Yükseltmeler: { "upgrade_id": level } ---
var upgrades: Dictionary = {}

# --- Buildings: { "building_id": count } ---
var buildings: Dictionary = {}

# --- İstatistikler ---
var total_tickets_scratched: int = 0
var total_matches: int = 0

# --- Pasif Gelir ---
var _coin_accumulator: float = 0.0


func _ready() -> void:
	print("[GameState] Initialized")


func _process(delta: float) -> void:
	if bps <= 0.0:
		return
	var base_reward: int = TD.get_ticket(current_ticket_type)["base_reward"]
	_coin_accumulator += bps * float(base_reward) * delta
	if _coin_accumulator >= 1.0:
		var whole := int(_coin_accumulator)
		_coin_accumulator -= whole
		add_coins(whole)


func add_coins(amount: int) -> void:
	total_coins_earned += amount
	coins += amount


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false


func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)


func get_building_count(building_id: String) -> int:
	return buildings.get(building_id, 0)


## Maliyet formülü: baz * 1.15 ^ seviye
func calc_cost(base_cost: int, level: int) -> int:
	return int(base_cost * pow(1.15, level))


## Yükseltme etkilerini yeniden hesapla. Her upgrade alımı sonrası çağrılır.
func recalculate_upgrades() -> void:
	var UD = preload("res://scripts/systems/upgrade_data.gd")
	scratch_power = 1
	match_bonus_pct = 0.0
	for upgrade_id in upgrades:
		var data: Dictionary = UD.UPGRADES.get(upgrade_id, {})
		if data.is_empty():
			continue
		var level: int = upgrades[upgrade_id]
		match data["effect_type"]:
			"scratch_power":
				scratch_power += data["effect_per_level"] * level
			"match_bonus_pct":
				match_bonus_pct += data["effect_per_level"] * level


## Building BPS'i yeniden hesapla. Her building alımı sonrası çağrılır.
func recalculate_buildings() -> void:
	var total_bps: float = 0.0
	for building_id in buildings:
		var data: Dictionary = BD.BUILDINGS.get(building_id, {})
		if data.is_empty():
			continue
		var count: int = buildings[building_id]
		total_bps += count * float(data["bps"])
	bps = total_bps


## Büyük sayıları okunabilir formata çevir
func format_number(n: int) -> String:
	var thresholds := [
		[1_000_000_000_000_000_000, "Qi"],
		[1_000_000_000_000_000, "Qa"],
		[1_000_000_000_000, "T"],
		[1_000_000_000, "B"],
		[1_000_000, "M"],
		[1_000, "K"],
	]
	for entry in thresholds:
		if n >= entry[0]:
			return "%.1f%s" % [float(n) / float(entry[0]), entry[1]]
	return str(n)
