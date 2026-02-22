extends Panel

## Tek bir kazıma alanı. Mouse/parmak gezdirerek kazı → sembol parça parça görünür.

signal area_scratched(area_index: int, symbol: String)

const SCRATCH_RADIUS := 12
const REVEAL_THRESHOLD := 0.65
const LINE_STEP := 3.0
const MASK_SIZE := 80

var symbol: String = ""
var area_index: int = 0
var is_scratched: bool = false

var _mask_image: Image
var _mask_texture: ImageTexture
var _total_pixels: int = 0
var _cleared_pixels: int = 0
var _last_scratch_pos: Vector2 = Vector2(-1, -1)
var _revealed: bool = false

@onready var _symbol_label: Label = $SymbolLabel
@onready var _cover_rect: ColorRect = $CoverRect


func setup(index: int, symbol_id: String, emoji: String) -> void:
	area_index = index
	symbol = symbol_id
	_symbol_label.text = emoji


func _ready() -> void:
	# Simge baştan görünür — kapak shader'ı üstünü örter
	_symbol_label.visible = true

	# 80x80 beyaz mask oluştur (beyaz = kapalı, siyah = açık)
	_mask_image = Image.create(MASK_SIZE, MASK_SIZE, false, Image.FORMAT_L8)
	_mask_image.fill(Color.WHITE)
	_total_pixels = MASK_SIZE * MASK_SIZE
	_cleared_pixels = 0

	_mask_texture = ImageTexture.create_from_image(_mask_image)

	# Shader material'e mask texture'ı ata
	var mat: ShaderMaterial = _cover_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("mask_texture", _mask_texture)


func _gui_input(event: InputEvent) -> void:
	if is_scratched:
		return

	# --- Mouse: basılı tutmaya gerek yok, üzerinden geçmek yeterli ---
	if event is InputEventMouseMotion:
		var pos := _to_mask_pos(event.position)
		if _last_scratch_pos.x >= 0:
			_scratch_line(_last_scratch_pos, pos)
		else:
			_scratch_at(pos)
		_last_scratch_pos = pos

	# --- Dokunmatik ---
	elif event is InputEventScreenTouch:
		if event.pressed:
			var pos := _to_mask_pos(event.position)
			_scratch_at(pos)
			_last_scratch_pos = pos
		else:
			_last_scratch_pos = Vector2(-1, -1)

	elif event is InputEventScreenDrag:
		var pos := _to_mask_pos(event.position)
		if _last_scratch_pos.x >= 0:
			_scratch_line(_last_scratch_pos, pos)
		else:
			_scratch_at(pos)
		_last_scratch_pos = pos


func _mouse_exit_area() -> void:
	_last_scratch_pos = Vector2(-1, -1)


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_mouse_exit_area()


## Pozisyonu panel koordinatından mask koordinatına çevir
func _to_mask_pos(local_pos: Vector2) -> Vector2:
	var s := size
	return Vector2(
		clampf(local_pos.x / s.x * MASK_SIZE, 0, MASK_SIZE - 1),
		clampf(local_pos.y / s.y * MASK_SIZE, 0, MASK_SIZE - 1)
	)


## Tek noktada daire çizerek pikselleri sil
func _scratch_at(center: Vector2) -> void:
	if _revealed:
		return
	var cx := int(center.x)
	var cy := int(center.y)
	var r := SCRATCH_RADIUS

	for y in range(maxi(cy - r, 0), mini(cy + r + 1, MASK_SIZE)):
		for x in range(maxi(cx - r, 0), mini(cx + r + 1, MASK_SIZE)):
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= r * r:
				var current := _mask_image.get_pixel(x, y)
				if current.r > 0.5:
					_mask_image.set_pixel(x, y, Color.BLACK)
					_cleared_pixels += 1

	_update_mask_texture()
	_check_threshold()


## İki nokta arası interpolasyonla kesintisiz çizgi
func _scratch_line(from: Vector2, to: Vector2) -> void:
	var dist := from.distance_to(to)
	if dist < 0.1:
		_scratch_at(to)
		return

	var steps := int(ceil(dist / LINE_STEP))
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var pos := from.lerp(to, t)
		_scratch_at(pos)


## Mask texture'ı güncelle
func _update_mask_texture() -> void:
	_mask_texture.update(_mask_image)


## Eşik kontrolü — %65 kazındıysa açılmış say
func _check_threshold() -> void:
	if _revealed:
		return
	var ratio := float(_cleared_pixels) / float(_total_pixels)
	if ratio >= REVEAL_THRESHOLD:
		_reveal()


## Alan açıldı — kalan kaplama fade-out
func _reveal() -> void:
	_revealed = true
	is_scratched = true

	# Kalan kaplama fade-out animasyonu
	var tween := create_tween()
	var mat: ShaderMaterial = _cover_rect.material as ShaderMaterial
	if mat:
		tween.tween_method(_set_fade_alpha, 1.0, 0.0, 0.3)
	tween.tween_callback(_on_fade_complete)

	area_scratched.emit(area_index, symbol)


func _set_fade_alpha(value: float) -> void:
	var mat: ShaderMaterial = _cover_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("fade_alpha", value)


func _on_fade_complete() -> void:
	_cover_rect.visible = false


## Sessiz kazıma — scratch_power ek alanları için (sinyal yok, animasyonlu)
func scratch_silent() -> void:
	if is_scratched:
		return
	is_scratched = true
	_revealed = true

	# Mask'ı tamamen temizle
	_mask_image.fill(Color.BLACK)
	_cleared_pixels = _total_pixels
	_update_mask_texture()

	# Kaplama fade-out animasyonu
	var tween := create_tween()
	var mat: ShaderMaterial = _cover_rect.material as ShaderMaterial
	if mat:
		tween.tween_method(_set_fade_alpha, 1.0, 0.0, 0.3)
	tween.tween_callback(_on_fade_complete)


## Anında tam kazıma (animasyonsuz)
func scratch_instant() -> void:
	if is_scratched:
		return
	is_scratched = true
	_revealed = true
	_mask_image.fill(Color.BLACK)
	_cleared_pixels = _total_pixels
	_update_mask_texture()
	_cover_rect.visible = false
