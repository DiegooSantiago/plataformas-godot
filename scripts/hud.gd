extends CanvasLayer

func _ready():
	var screen_size: Vector2i = DisplayServer.window_get_size()
	var os_name := OS.get_name()

	# Escala base
	var hud_scale := Vector2.ONE

	# --- ANDROID ---
	if os_name == "Android":
		# Teléfonos pequeños
		if screen_size.x <= 1280:
			hud_scale = Vector2(1.6, 1.6)
		else:
			hud_scale = Vector2(1.4, 1.4)

	# --- PC (Windows, Linux, macOS) ---
	else:
		# Pantallas grandes
		if screen_size.x >= 1920:
			hud_scale = Vector2.ONE
		else:
			# Laptops pequeñas
			hud_scale = Vector2(1.2, 1.2)

	scale = hud_scale
