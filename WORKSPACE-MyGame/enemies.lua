-- Import libraries
anim8 = require 'libraries/anim8/anim8'
-- declare load as local
local function load(o1,o2)
    -- Create the of enemies
    enemy_1={}
    enemy_2={}

    enemy_1.sprite = love.graphics.newImage("assets/enemy_1.png")
    enemy_2.sprite = love.graphics.newImage("assets/enemy_2.png")

    enemy_1.spriteSheet = love.graphics.newImage("assets/spritesheet_enemy_1.png")
    enemy_2.spriteSheet = love.graphics.newImage("assets/spritesheet_enemy_2.png")

    enemy_1.grid = anim8.newGrid(327,762, enemy_1.spriteSheet:getWidth(),enemy_1.spriteSheet:getHeight())
    enemy_2.grid = anim8.newGrid(357,409, enemy_2.spriteSheet:getWidth(),enemy_2.spriteSheet:getHeight())

    enemy_1.animations = {}
    enemy_2.animations = {}
    
    enemy_1.animations.move =anim8.newAnimation(enemy_1.grid('1-2', 1),0.25)
    enemy_2.animations.move =anim8.newAnimation(enemy_2.grid('1-2', 1),0.25)

    -- Load the sound of enemy dead
    enemy_dead_sound = love.audio.newSource('sounds/enemy_dead.mp3', 'stream')

    -- Create a table to store the enemies
    enemies = {}
    enemies_2 = {}

    -- Set the delay between enemy spawns
    enemySpawnDelay = o1.SpawnDelay
    enemy_2_SpawnDelay = o2.SpawnDelay
    enemy_2_Active = o2.Active

    -- Set the time since the last enemy spawn
    timeSinceLastEnemySpawn = enemySpawnDelay
    timeSinceLastEnemy_2_Spawn = enemy_2_SpawnDelay

    -- Create enemy bullet
    enemyBullet={}

    enemyBullet.sprite = love.graphics.newImage("assets/bullet_enemy_1_0.png")

    enemyBullet.spriteSheet = love.graphics.newImage("assets/spritesheet_bullet_enemy_1.png")

    enemyBullet.grid = anim8.newGrid(81,396, enemyBullet.spriteSheet:getWidth(),enemyBullet.spriteSheet:getHeight())
    
    enemyBullet.animations = {}

    enemyBullet.animations.move =anim8.newAnimation(enemyBullet.grid('1-3', 1),0.25)

    -- Create a table to store the enemy bullets
    enemyBullets = {}

    -- Set the delay between enemy shots
    enemyShotDelay = o1.ShotDelay
    enemy_2_ShotDelay = o2.ShotDelay

    -- Set the time since the last enemy shot
    timeSinceLastEnemyShot = o1.LastEnemyShot
    timeSinceLastEnemy_2_Shot = o2.LastEnemyShot
    end
  -- return the local version of load
  return load