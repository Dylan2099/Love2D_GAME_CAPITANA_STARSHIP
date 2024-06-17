-- Import libraries
    anim8 = require 'libraries/anim8/anim8'
-- declare load as local
local function load(o)
    -- CREATE PLAYER 1
    player={}

    -- Set the initial position of the player
    player.x = o.x
    player.y = o.y

    -- Set the initial number of lives
    lives = o.lives

    -- Set the initial score
    score = o.score

    -- Set the speed of the player
    player.speed = o.speed

    -- player = love.graphics.newImage("assets/ship.png")
    player.sprite = love.graphics.newImage("assets/ship.png")
    player.spriteSheet = love.graphics.newImage("assets/spritesheet_SHIP_CSS.png")

    player.grid = anim8.newGrid(335,500, player.spriteSheet:getWidth(),player.spriteSheet:getHeight())
    
    player.animations = {}
    --player.animations.left =anim8.newAnimation(player.grid('1-2', 1),0.1)
    player.animations.walk =anim8.newAnimation(player.grid('1-2', 1),0.25)

    -- Load the sound of the player motor
    left_motor_sound = love.audio.newSource('sounds/left_motor.mp3', 'stream')
    left_motor_sound:setVolume(0.3)
    right_motor_sound = love.audio.newSource('sounds/right_motor.mp3', 'stream')
    right_motor_sound:setVolume(0.3)

    -- Load the image of the player bullet
    bulletImage = love.graphics.newImage("assets/bullet.png")
    -- Create bullet
    Bullet={}

    Bullet.sprite = love.graphics.newImage("assets/bullet.png")

    Bullet.spriteSheet = love.graphics.newImage("assets/spritesheet_bullet.png")

    Bullet.grid = anim8.newGrid(81,396, Bullet.spriteSheet:getWidth(),Bullet.spriteSheet:getHeight())
    
    Bullet.animations = {}

    Bullet.animations.move =anim8.newAnimation(Bullet.grid('1-2', 1),0.25)

    -- Create a table to store the bullets
    bullets = {}
    -- Load the sound of the bullet
    bullet_sound = love.audio.newSource('sounds/bullet.mp3', 'stream')
    -- Set the delay between shots
    shotDelay = 0.7
    -- Set the time since the last shot
    timeSinceLastShot = shotDelay
    end
  -- return the local version of load
  return load