extends Node

@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll : float = 0.0 # Ubah ke float untuk perhitungan yang mulus
var score : int
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	# Pastikan $Ground memiliki node Sprite2D anak dan properti texture
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	# reset variables
	game_running = false
	game_over = false
	score = 0
	scroll = 0.0 # Reset scroll sebagai float
	$ScoreLabel.text = "SCORE: " + str(score)
	$GameOver.hide()
	
	# Bersihkan pipes
	# Pastikan semua pipe ada di group "pipes"
	get_tree().call_group("pipes", "queue_free") 
	pipes.clear()
	
	# generate starting pipes
	generate_pipes()
	$Flyhero.reset() # Pastikan fungsi reset() ada di skrip Flyhero

func _input(event):
	if game_over == false:
		# Gunakan Input.is_action_pressed() untuk input yang lebih baik di Godot
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Flyhero.flying:
						$Flyhero.flap()
						check_top()
	# Tambahkan input untuk restart saat game over (misalnya tombol R atau mouse click)
	elif game_over == true and event is InputEventMouseButton and event.pressed:
		_on_game_over_restart()
	
func start_game():
	game_running = true
	$Flyhero.flying = true
	$Flyhero.flap()
	# start pipe timer
	$PipeTimer.start()

# Perbaikan 1: Tambahkan garis bawah pada 'delta' untuk menghilangkan warning.
func _process(_delta):
	if game_running:
		scroll += SCROLL_SPEED * _delta # Menggunakan delta untuk scroll berbasis waktu
		# Anda bisa menggunakan SCROLL_SPEED saja jika tidak ingin berbasis delta
		
		# reset scroll
		if scroll >= screen_size.x:
			scroll = 0
		# move ground node
		$Ground.position.x = -scroll
		# move pipes
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED


func _on_pipe_timer_timeout():
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	# Perbaikan 2: Ubah salah satu angka menjadi float untuk menghindari Integer Division Warning (jika terjadi)
	# Namun, di sini randi_range sudah menghasilkan integer, jadi ini hanya catatan.
	pipe.position.y = (float(screen_size.y) - float(ground_height)) / 2.0 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	
	# Pastikan signal 'hit' dan 'scored' sudah didefinisikan di skrip Pipe
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	
	add_child(pipe)
	pipes.append(pipe)
	
func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)

func check_top():
	if $Flyhero.position.y < 0:
		$Flyhero.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$GameOver.show()
	$Flyhero.flying = false
	game_running = false
	game_over = true
	
func bird_hit():
	$Flyhero.falling = true
	stop_game()

func _on_ground_hit():
	$Flyhero.falling = false
	stop_game()

func _on_game_over_restart():
	new_game()
