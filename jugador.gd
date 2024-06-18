extends CharacterBody2D
@onready var animated_sprite =$AnimatedSprite2D
@export var SPEED:float = 400.0
@export var JUMP_VELOCITY: float= -400.0
@export var JUMP_VELOCITY_ON_WALL :float = -200
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity = 800
@export var friction: float = 10.0
@export var air_friction: float = 4.0

var is_attacking = false
var attack2_duration = 2.5 # Duración de la animación de ataque en segundos
var attack1_duration = 1.7 # Duración de la animación de ataque en segundos
var attack_timer = 0.0
var jump_push_back = 400
var gravity_sliding = 200
var is_slading= false
var is_on_left_wall = false
var is_on_right_wall = false


func _physics_process(delta):
	#var velocity = Vector2.ZERO
	var is_crouching = false
# Aplicar gravedad
	if !is_on_floor():
		velocity.y += gravity * delta
	 # Verificar si el ataque está activo
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
		# Si está atacando, no cambiar de animación
		move_and_slide()
		#self.velocity = velocity
		return
	# Movimiento horizontal
	if Input.is_action_pressed("right"):
		velocity.x = SPEED 
		animated_sprite.flip_h = false
		if !is_on_floor():
			animated_sprite.play("jump-player")
		elif animated_sprite.animation != "running-player-with-sword":
			animated_sprite.speed_scale = 1.5
			animated_sprite.play("running-player-with-sword")
		velocity.x = lerp(float(velocity.x), 0.0, friction * delta)
		if abs(velocity.x) < 1.0:
			velocity.x = 0.0

	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED 
		animated_sprite.flip_h = true
		if !is_on_floor():
			animated_sprite.play("jump-player")
		elif animated_sprite.animation != "running-player-with-sword":
			animated_sprite.speed_scale = 1.5
			animated_sprite.play("running-player-with-sword")
			#intentando 	quwe ataque
	else:
		# Movimiento de agacharse
		animated_sprite.speed_scale=1
		if is_on_floor() and Input.is_action_pressed("down"):
			is_crouching = true
			velocity.x = lerp(float(velocity.x), 0.0, friction * delta)
			if abs(velocity.x) < 1.0:
				velocity.x = 0.0
			if animated_sprite.animation != "down-player":
				animated_sprite.play("down-player")

		else :
			velocity.x = lerp(float(velocity.x), 0.0, friction * delta)
			if abs(velocity.x) < 1.0:
				velocity.x = 0.0
				
	

	
	# Movimiento de salto
	if is_on_floor() and Input.is_action_just_pressed("up"):
		velocity.y = JUMP_VELOCITY
		if animated_sprite.animation != "jump-player":
			animated_sprite.play("jump-player")
			
	is_on_left_wall = false
	is_on_right_wall = false
	
	# Verificar colisiones
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		#cusmiando los metodos del nodo pero no funciono
		#if collision:
			#print("Collision detected. Properties and Methods:")
			#print("\nProperties:")
			#for property_name in collision:
				#print(property_name)
			#print("\nMethods:")
			#for method_name in collision.get_method_list():
				#print(method_name)
		if collision and collision.has_method("get_normal"):
			#print(collision.has_method("get_normal"))
			var normal = collision.get_normal()
			#print(normal)
			if normal.x > 0:
				is_on_left_wall = true
			elif normal.x < 0:
				is_on_right_wall = true
				
	# saltandeo en la pared
	if is_on_wall() and Input.is_action_just_pressed("up"):
		velocity.y = JUMP_VELOCITY_ON_WALL
		
		# animated_sprite.scale.x *= -1
		if is_on_left_wall:
			velocity.x = jump_push_back
		elif is_on_right_wall:
			velocity.x = -jump_push_back
		
	#deslizando en la pared
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			is_slading= true
			if is_slading:
				velocity.y += (gravity_sliding * delta)
				velocity.y = min(velocity.y,gravity_sliding)
				if animated_sprite.animation != "sliding-strong-man":
					animated_sprite.play("sliding-strong-man")
	
		# haciendo el ataque
	if Input.is_action_just_pressed("attack") and is_on_floor():
		is_attacking = true
		attack_timer = attack1_duration
		animated_sprite.play("comb-strong-man-sword")
		velocity.x = 0.0
	if Input.is_action_just_pressed("attack2") and is_on_floor():
		is_attacking = true
		attack_timer = attack2_duration
		animated_sprite.play("comb-strong-man-sword2")
		velocity.x = 0.0
		
	# Cambiar la animación a "idle" si aterriza
	if is_on_floor() and velocity.y == 0 and !Input.is_action_pressed("right") and !Input.is_action_pressed("left") and !is_crouching and !is_attacking:
		if animated_sprite.animation != "idle-player-with-sword":
			animated_sprite.play("idle-player-with-sword")
	# Aplicar la velocidad al personaje
	move_and_slide()



