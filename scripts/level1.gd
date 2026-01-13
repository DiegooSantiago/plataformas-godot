extends Node2D

var coins := 0
var lives := 3

@onready var coin_label = $HUD/CoinLabel
@onready var lives_label = $HUD/LivesLabel
@onready var player = $Player
@onready var respawn_point = $RespawnPoint

func _ready():
	coin_label.text = "Monedas: %d" % coins
	lives_label.text = "Vidas: %d" % lives

	for coin in get_tree().get_nodes_in_group("coins"):
		coin.collected.connect(_on_coin_collected)

func _process(_delta):
	if player.global_position.y > 700:
		_player_died()

func _on_coin_collected():
	coins += 1
	coin_label.text = "Monedas: %d" % coins

func _player_died():
	lives -= 1
	lives_label.text = "Vidas: %d" % lives

	if lives <= 0:
		get_tree().reload_current_scene()
	else:
		player.global_position = respawn_point.global_position
		player.velocity = Vector2.ZERO
