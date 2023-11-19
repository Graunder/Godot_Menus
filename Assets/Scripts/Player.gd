extends CharacterBody3D

# Player references
@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var eyes = $Neck/Head/Eyes
@onready var collisionCrouching = $CollisionCrouching
@onready var collisionStanding = $CollisionStanding
@onready var playerRayCast3d = $RayCast3D
@onready var playerRayCast3d2 = $RayCast3D2
@onready var playerRayCast3d3 = $RayCast3D3
@onready var playerRayCast3d4 = $RayCast3D4
@onready var playerCamera3d = $Neck/Head/Eyes/Camera3D
@onready var animation_player = $Neck/Head/Eyes/AnimationPlayer

@onready var rays = [$RayCast3D, $RayCast3D2, $RayCast3D3, $RayCast3D4]

# Variables visible from editor
@export var speedWalking = 5.0
@export var speedSprinting = 8.0
@export var speedCrouching = 3.0
@export var mouseSensetivity = 0.1
@export var lerpSpeed = 10.0
@export var lerpSpeedAir = 3.0
@export var slideTimerMax = 1.5
@export var slideSpeed = 10.0
@export var slideAfter = 1.0
@export var slideHeadAngle = 2.0
@export var extraGravity = 1.5
@export var headBobbing = true
@export var jumpingAnims = true
@export var jumpingDelay = 0.3

# Player states
var walking = false
var sprinting = false
var crouching = false
var freeLooking = false
var sliding = false

# Head bobbing variables
const headBobbingSpeedSprinting = 22.0
const headBobbingSpeedWalking = 14.0
const headBobbingSpeedCrouching = 10.0
const headBobbingIntensitySprinting = 0.2
const headBobbingIntensityWalking = 0.1
const headBobbingIntensityCrouching = 0.05
var headBobbingIntensityCurrent = 0.0
var headBobbingVector = Vector2.ZERO
var headBobbingIndex = 0.0

# General variables
const jumpVelocity = 4.5
const originalHeadHeight = 0.0
var speedCurrent = 5.0
var direction = Vector3.ZERO
var crouchingDepth = -0.5
var freeLookTiltAmount = 7.0
var slideTimer = 0.0
var slideVector = Vector2.ZERO
var lastVelocity = Vector3.ZERO
var canSlide = false
var canSlideTimer = 0.0
var airTime = 0.0
var jumpTimer = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Handle mouse input
	if event is InputEventMouseMotion:
		if freeLooking:
			# Handle Free Looking rotation
			neck.rotate_y(deg_to_rad(-event.relative.x * mouseSensetivity))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-90), deg_to_rad(90))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouseSensetivity))
		
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSensetivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	# Movement input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if is_on_floor():
		airTime = 0.0
		jumpTimer += delta
	else:
		airTime += delta
	
	# Add the gravity
	if not is_on_floor():
		velocity.y -= (gravity + gravity * airTime * extraGravity) * delta
		#velocity.y -= gravity * delta * (extraGravity if velocity.y > 0 else 1)

	# Handle Crouching/Sprinting/Walking
	if Input.is_action_pressed("crouch") || sliding:
		# Crouching
		speedCurrent = lerp(speedCurrent, speedCrouching, delta * lerpSpeed)
		head.position.y = lerp(head.position.y, originalHeadHeight + crouchingDepth, delta * lerpSpeed)
		
		change_collisions(false)
		
		# Slide begining logic
		if sprinting && canSlide && input_dir != Vector2.ZERO:
			sliding = true
			slideVector = input_dir
			slideTimer = slideTimerMax
			freeLooking = true
			reset_slide_check()
		
		walking = false
		sprinting = false
		crouching = true
		reset_slide_check()
	elif !height_raycast_hit() && is_on_floor():
		change_collisions(true)
		
		head.position.y = lerp(head.position.y, originalHeadHeight, delta * lerpSpeed)
		
		# Handle Springting as lower priority than Crouching
		if Input.is_action_pressed("sprint") && !Input.is_action_pressed("backward"):
			# Sprinting
			speedCurrent = lerp(speedSprinting, speedCrouching, delta * lerpSpeed)
			
			walking = false
			sprinting = true
			crouching = false
			
			if !canSlide:
				canSlideTimer += delta
				if canSlideTimer > slideAfter:
					canSlide = true
		else:
			# Walking
			speedCurrent = lerp(speedWalking, speedCrouching, delta * lerpSpeed)
			
			walking = true
			sprinting = false
			crouching = false
			reset_slide_check()

	# Handle Free Looking state
	if Input.is_action_pressed("freelook") || sliding:
		freeLooking = true
		
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(slideHeadAngle), delta * lerpSpeed)
		else:
			eyes.rotation.z = -deg_to_rad(neck.rotation.y * freeLookTiltAmount)
	else:
		freeLooking = false
		# Reseting Rotations
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerpSpeed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerpSpeed)

	# Handle Sliding
	if sliding:
		slideTimer -= delta
		if slideTimer <= 0:
			sliding = false
			freeLooking = false

	# Handle Headbobbing
	if headBobbing:
		# Assign Headbobbing intensity and speed
		if sprinting:
			headBobbingIntensityCurrent = headBobbingIntensitySprinting
			headBobbingIndex += headBobbingSpeedSprinting * delta
		elif walking:
			headBobbingIntensityCurrent = headBobbingIntensityWalking
			headBobbingIndex += headBobbingSpeedWalking * delta
		elif crouching:
			headBobbingIntensityCurrent = headBobbingIntensityCrouching
			headBobbingIndex += headBobbingSpeedCrouching * delta
			
		if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
			# Apply Headbobbing
			headBobbingVector.y = sin(headBobbingIndex)
			headBobbingVector.x = sin(headBobbingIndex / 2) + 0.5
			
			eyes.position.y = lerp(eyes.position.y, headBobbingVector.y * (headBobbingIntensityCurrent / 2.0), delta * lerpSpeed)
			eyes.position.x = lerp(eyes.position.x, headBobbingVector.x * headBobbingIntensityCurrent, delta * lerpSpeed)
		else:
			eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerpSpeed)
			eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerpSpeed)

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if !jumpingAnims:
			jump_variables()
		if jumpingAnims && jumpTimer > jumpingDelay:
			jump_variables()
			animation_player.play("anim_player_jump")
		
	# Handle Landing animation
	if jumpingAnims && jumpTimer > jumpingDelay && is_on_floor() && lastVelocity.y < 0.0:
		animation_player.play("anim_player_land")
		jumpTimer = 0.0

	# Get the input direction and handle the movement/deceleration
	# As good practice, you should replace UI actions with custom gameplay actions
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerpSpeed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerpSpeedAir)
	
	if sliding:
		direction = (transform.basis * Vector3(slideVector.x, 0, slideVector.y)).normalized()
		speedCurrent = (slideTimer + 0.1) * slideSpeed
	
	if direction:
		velocity.x = direction.x * speedCurrent
		velocity.z = direction.z * speedCurrent
	else:
		velocity.x = move_toward(velocity.x, 0, speedCurrent)
		velocity.z = move_toward(velocity.z, 0, speedCurrent)
		
	lastVelocity = velocity
	
	move_and_slide()

func change_collisions(isStanding: bool):
	collisionStanding.disabled = !isStanding
	collisionCrouching.disabled = isStanding
	
func height_raycast_hit():
	var hasHit = false
	for i in rays:
		if i.is_colliding():
			hasHit = true
			break
	return hasHit
	
func reset_slide_check():
	canSlide = false
	canSlideTimer = 0.0
	
func jump_variables():
	velocity.y = jumpVelocity
	sliding = false
