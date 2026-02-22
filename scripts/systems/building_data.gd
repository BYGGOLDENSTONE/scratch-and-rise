class_name BuildingData

## Building tanımları ve sıralaması.
## Statik erişim: BuildingData.BUILDINGS, BuildingData.BUILDING_ORDER

const BUILDINGS := {
	"auto_scratcher": {
		"name": "Oto-Kazıyıcı",
		"description": "Yavaş ama sadık",
		"base_cost": 5000,
		"bps": 0.1,
	},
	"mini_stand": {
		"name": "Mini Tezgah",
		"description": "Köşe başı tezgahı",
		"base_cost": 15000,
		"bps": 0.3,
	},
	"luck_machine": {
		"name": "Şans Makinesi",
		"description": "Insert coin to play",
		"base_cost": 50000,
		"bps": 1.0,
	},
	"scratch_workshop": {
		"name": "Kazıma Atölyesi",
		"description": "Zanaatkâr kalitesi",
		"base_cost": 150000,
		"bps": 3.0,
	},
}

const BUILDING_ORDER: Array[String] = [
	"auto_scratcher",
	"mini_stand",
	"luck_machine",
	"scratch_workshop",
]
