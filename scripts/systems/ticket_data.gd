class_name TicketData

## Bilet türleri ve sembol verileri.
## Statik erişim: TicketData.get_ticket("paper")

const SYMBOLS := {
	"cherry": "🍒",
	"lemon": "🍋",
	"grape": "🍇",
	"star": "⭐",
	"moon": "🌙",
	"diamond": "💎",
	"heart": "❤️",
	"seven": "7️⃣",
	"crown": "👑",
	"phoenix": "🔥",
	"dragon": "🐉",
	"rainbow": "🌈",
	"lightning": "⚡",
	"cosmos": "🌌",
	"infinity": "♾️",
}

const TICKETS := {
	"paper": {
		"name": "Kağıt",
		"cost": 0,
		"cols": 3,
		"rows": 2,
		"symbols": ["cherry", "lemon", "grape"],
		"base_reward": 5,
		"unlock_at": 0,
	},
	"bronze": {
		"name": "Bronz",
		"cost": 10,
		"cols": 4,
		"rows": 2,
		"symbols": ["cherry", "lemon", "grape", "star", "moon"],
		"base_reward": 25,
		"unlock_at": 500,
	},
	"silver": {
		"name": "Gümüş",
		"cost": 50,
		"cols": 3,
		"rows": 3,
		"symbols": ["cherry", "lemon", "grape", "star", "moon", "diamond", "heart"],
		"base_reward": 100,
		"unlock_at": 5000,
	},
}


static func get_ticket(type: String) -> Dictionary:
	return TICKETS.get(type, TICKETS["paper"])


static func get_symbol_emoji(symbol_id: String) -> String:
	return SYMBOLS.get(symbol_id, "?")


static func get_area_count(type: String) -> int:
	var t := get_ticket(type)
	return t["cols"] * t["rows"]
