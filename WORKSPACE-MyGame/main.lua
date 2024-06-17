local playerload = require 'player'
local enemiesload = require 'enemies'

-- Import libraries
baton = require 'libraries/baton/baton'
--baton = require 'path.to.baton' -- if it's in subfolders

-- Guarda una referencia a la fuente original
originalFont = love.graphics.getFont()

local playerMove = baton.new {
	controls = {
		left = {'key:left', 'axis:leftx-', 'button:dpleft'},
		right = {'key:right', 'axis:leftx+', 'button:dpright'},
		up = {'key:up', 'axis:lefty-', 'button:dpup'},
		down = {'key:down', 'axis:lefty+', 'button:dpdown'},
		Action = {'key:space', 'button:a', 'mouse:1'},
	},
	pairs = {
		move = {'left', 'right', 'up', 'down','Action'}
	},
	joystick = love.joystick.getJoysticks()[1],
	deadzone = .33,
}

-- definea function to load highscores from a file
local function loadScores()
    local HighScores = {}
    if love.filesystem.getInfo("scores.txt") then
        local data = love.filesystem.read("scores.txt")
        for line in data:gmatch("[^\r\n]+") do
            local name, scores = line:match("([^,]+),([^,]+)")
            scores = tonumber(scores)
            table.insert(HighScores, {name = name, scores = scores})
        end
    end
    return HighScores
end

-- Esta función divide una cadena por un separador y devuelve una tabla con los fragmentos
function string.split(str, sep)
    local result = {}
    local i = 1
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
      result[i] = s
      i = i + 1
    end
    return result
end

function love.textinput(t)
    if gameState == "intro" and not Amelia_sound_1:isPlaying() then
        text = text .. t
    else 
        text=""
    end    
end

function love.keypressed(key)
    if gameState == "intro" and key == "escape" then
        Amelia_sound_1:stop()
    end    
    if gameState == "intro" and not Amelia_sound_1:isPlaying() then 
        if key == "backspace" then
            -- Elimina el último carácter de la variable text
            text = text:sub(1, -2)
        elseif key == "return" and text ~= "" then
            -- Elimina los espacios al principio de la variable text
            text = text:gsub("^%s+", "")
            -- Guarda la variable text
            name_user = text
            text = ""
            gameState = "playing"
        elseif key == "return" and text == "" then
            name_user = "NaN2"
            text = ""
            gameState = "playing"
        end
    end
    if gameState == "menu" and key == "escape" then
        Amelia_sound_1:play()
        --Amelia_sound_1:setLooping(false)
        gameState = "intro"
    end  
end

function love.mousepressed(x, y, button)

    --game over mode buttons
    if button == 1 and gameState == "game over" then
        -- check if mouse is within restart button area
        if x >= restart_button.x and x <= restart_button.x + restart_button.width and y >= restart_button.y and y <= restart_button.y + restart_button.height then
            -- restart game
            for i = #enemies, 1, -1 do
                table.remove(enemies, i)
            end
            for i = #enemies_2, 1, -1 do
                table.remove(enemies_2, i)
            end
            for i = #bullets, 1, -1 do
                table.remove(bullets,i)
            end
            for i = #enemyBullets, 1, -1 do
                table.remove(enemyBullets,i)
            end
            for i = #powerUps, 1, -1 do
                table.remove(powerUps,i)
            end
            local HighScores = loadScores()
            --saveScores(HighScores) 
            gameState = "playing"
            powerUpActive = false
            lives = 3
            score= 0
            difficulty=1
        end

        -- check if mouse is within HighScores button area
        if x >= HighScores_button.x and x <= HighScores_button.x + HighScores_button.width and y >= HighScores_button.y and y <= HighScores_button.y + HighScores_button.height then
            -- ShowGame overscreen game
            gameState = "scores"
        end

        -- check if mouse is within HighScores button area
        if x >= menu_button.x and x <= menu_button.x + menu_button.width and y >= menu_button.y and y <= menu_button.y + menu_button.height then
            -- ShowGame overscreen game
            gameState = "menu"
        end
        
    end

    --menu mode buttons
    if button == 1 and gameState == "menu" then
        -- check if mouse is within scores button area
        if x >= HighScores_button.x and x <= HighScores_button.x + HighScores_button.width and y >= HighScores_button.y and y <= HighScores_button.y + HighScores_button.height then
            gameState = "scores"
        end
        -- check if mouse is within new game button area
        if x >= NewGame_button.x and x <= NewGame_button.x + NewGame_button.width and y >= NewGame_button.y and y <= NewGame_button.y + NewGame_button.height then
            Amelia_sound_1:play()
            --Amelia_sound_1:setLooping(false)
            gameState = "intro"
        end
        -- check if mouse is within settings button area
        if x >= back_button.x and x <= back_button.x + back_button.width and y >= back_button.y and y <= back_button.y + back_button.height then
            --gameState = "Settings"
            print("settings")
        end
    end

    --scores mode buttons
    if button == 1 and gameState == "scores" then
        -- check if mouse is within back button area
        if x >= back_button.x and x <= back_button.x + back_button.width and y >= back_button.y and y <= back_button.y + back_button.height then
            gameState = "game over"
        end
    end

end

-- Esta función guarda los puntajes en un archivo llamado scores.txt
function saveScores(HighScores)
    local file = love.filesystem.newFile("scores.txt")
    file:open("w")
    for i = 1, #HighScores do
      file:write(HighScores[i].name .. "," .. HighScores[i].scores .. "\n")
    end
    file:close()
end



-- Esta función actualiza los puntajes y los guarda si hay un nuevo récord
function updateScores(name_user, score)
    local HighScores = loadScores()
    table.insert(HighScores, {name = name_user, scores = score}) -- crea una entrada con el nombre y el puntaje del jugador
    table.sort(HighScores, function(a, b) return a.scores > b.scores end) -- ordena la tabla por puntaje
    while #HighScores > 5 do -- solo se guardan los cinco mejores puntajes
        table.remove(HighScores)
    end
    saveScores(HighScores)
end


function updateDifficulty()
    difficulty_log = math.log(score + 1,10) 
    if difficulty_log > 2 then
        difficulty=math.floor (difficulty_log) -1
    else
        difficulty=math.floor (difficulty_log)
    end
end


function love.load()
    -- Import libraries
    anim8 = require 'libraries/anim8/anim8'

    -- Set the initial game state
    text = ""
    name = ""
    gameState = "menu"
    difficulty = 1

    -- load background sounds
    background_music = love.audio.newSource('sounds/music_2.mp3', 'stream')
    background_music:setVolume(0.8)

    Amelia_sound_1 = love.audio.newSource('sounds/Amelia_intro.mp3', 'stream')
    Amelia_sound_1:setVolume(1)

    Amelia_sound_2 = love.audio.newSource('sounds/Amelia_damage.mp3', 'stream')
    Amelia_sound_2:setVolume(1)
    
    Amelia_sound_3 = love.audio.newSource('sounds/Amelia_destroy_enemy.mp3', 'stream')
    Amelia_sound_3:setVolume(.5)

    Amelia_sound_4 = love.audio.newSource('sounds/Amelia_game-over.mp3', 'stream')
    Amelia_sound_4:setVolume(1)

    Amelia_sound_5 = love.audio.newSource('sounds/Amelia_destroy_enemy_2.mp3', 'stream')
    Amelia_sound_5:setVolume(.8)

    -- load background images
    background_image = love.graphics.newImage('assets/backg_1.jpeg')
    Intro_background_image = love.graphics.newImage('assets/Intro.jpeg')
    Main_menu_background_image = love.graphics.newImage('assets/Main_menu.jpg')
    Main_menu_title_background_image=love.graphics.newImage('assets/Main_menu_title.png')
    Game_over_image= love.graphics.newImage('assets/game-over_Screen.jpeg')
    button_image= love.graphics.newImage('assets/button.png')

    -- set up background positions
    background_positions = {
        y1 = 0,
        y2 = -background_image:getHeight()
    }

    Menu_background_positions = {
        y1 = 0,
        y2 = -Main_menu_background_image:getHeight()
    }

    Menu__title_background_positions = {
        y1 = 0,
        y2 = -Main_menu_title_background_image:getHeight()
    }

    Intro_background_positions = {
        y1 = 0,
        y2 = -Intro_background_image:getHeight()
    }

    Game_over_background_positions = {
        y1 = 0,
        y2 = -Game_over_image:getHeight()
    }

    -- set background scroll speed
    scroll_speed = 200

    -- set up BACK button
    back_button = {
        x = 317,
        y = 400,
        width = 150,
        height = 50
    }
    -- set up restart button
    restart_button = {
        x = 317,
        y = 300,
        width = 150,
        height = 50
    }

    -- set up Main Menu button
    menu_button = {
        x = 317,
        y = 400,
        width = 150,
        height = 50
    }

    -- set up HighScores button
    HighScores_button = {
        x = 317,
        y = 500,
        width = 150,
        height = 50
    }

    -- set up Settings button
    Settings_button = {
        x = 317,
        y = 400,
        width = 150,
        height = 50
    }

    -- set up New Game button
    NewGame_button = {
        x = 317,
        y = 300,
        width = 150,
        height = 50
    }

    
    -- CREATE PLAYER 1--
    local p = {}

    --Player
    p.x=300
    p.y=460
    p.lives=3
    p.score=0
    p.speed=500
    
    playerload(p)

    -- CREATE ENEMIES--
    local e1={}
    local e2={}

    --Enemy 1
    e1.SpawnDelay=1.5
    e1.Active=True
    e1.ShotDelay = 1.25
    e1.LastEnemyShot = 0

    --Enemy 2
    e2.SpawnDelay=30
    e2.Active=false
    e2.ShotDelay = 1.25
    e2.LastEnemyShot = 0

    enemiesload(e1,e2)

    -- Set powerUp
    powerUpActive = false
    powerUpDuration = 0

    -- Load the image of powerUp
    powerUpImage = love.graphics.newImage("assets/PowerUp_1.png")

    -- Create a table to store the powerUps
    powerUps = {}
    -- Set the delay between powerUp spawns
    powerUpSpawnDelay = 60
    -- Set the time since the last powerUp spawn
    timeSinceLastpowerUpSpawn = powerUpSpawnDelay
end

function love.update(dt)
    playerMove:update()
    if gameState == "intro" then
        love.graphics.setFont(originalFont)
        -- Get input Move
        left = playerMove:get 'left'
        right = playerMove:get 'right'
    end
    -- Only update the game logic when the game state is "playing"
    if gameState == "playing" then
        Amelia_sound_1:stop()
        love.graphics.setFont(originalFont)
        background_music:play()
        background_music:setLooping(true)

        -- Get input Move
        left = playerMove:get 'left'
        right = playerMove:get 'right'
        Action= playerMove:get 'Action'

        --local powerUpX, powerUpY, powerUpWidth, powerUpHeight = getPowerUpPositionAndSize()

        -- update Power up time
        if powerUpActive then
            powerUpDuration = powerUpDuration - dt
            if powerUpDuration <= 0 then
                powerUpActive = false
            end
        end

        -- Update the time since the last powerUp spawn
        timeSinceLastpowerUpSpawn = timeSinceLastpowerUpSpawn + dt

        if score >= 1000 then
            -- Spawn a new powerUp when enough time has passed since the last powerUp spawn
            if timeSinceLastpowerUpSpawn >= powerUpSpawnDelay then
                local r = math.random(0,3)
                if r == 0 then
                    spawnpowerUp()
                    timeSinceLastpowerUpSpawn = 0
                end
            end
        end

        -- Update the position of the powerUp
        for i, powerUp in ipairs(powerUps) do
            powerUp.y = powerUp.y + (200+((difficulty-1)*100)) * dt 
            -- Remove enemies that go off screen
            if powerUp.y > love.graphics.getHeight() then
                table.remove(powerUp, i)
            end
        end

        for j, powerUp in ipairs(powerUps) do
            if player.x < powerUp.x + powerUpImage:getWidth()*0.125 and player.x + player.sprite:getWidth()*0.25 > powerUp.x and player.y < powerUp.y + powerUpImage:getHeight()*0.125 and player.y + player.sprite:getHeight()*0.25 > powerUp.y then
                -- El jugador está tocando el elemento de power-up, así que lo activamos
                powerUpActive = true
                table.remove(powerUps, j)
                powerUpDuration = 20 -- Establece la duración del power-up en 20 segundos
            end
        end


        -- update background positions
        background_positions.y1 = background_positions.y1 + (scroll_speed+ ((difficulty-1)*50)) * dt
        background_positions.y2 = background_positions.y2 + (scroll_speed+ ((difficulty-1)*50)) * dt

        -- reset background positions
        if background_positions.y1 >= background_image:getHeight() then
            background_positions.y1 = 0
            background_positions.y2 = -background_image:getHeight()
        end

        -- Verifica si el jugador está fuera de los límites de la pantalla en el eje X
        if player.x < 0 then
            player.x = 0
        elseif player.x + player.sprite:getWidth()*0.25 > love.graphics.getWidth() then
            player.x = love.graphics.getWidth()- player.sprite:getWidth()*0.25
        end

        
        
        

        if left == 1 then
            left_motor_sound:play()
            player.x = player.x - player.speed * dt
        elseif right == 1 then 
            right_motor_sound:play()
            player.x = player.x + player.speed * dt
        end


        -- Update the time since the last shot
        timeSinceLastShot = timeSinceLastShot + dt
        

        -- Shoot a bullet when spacebar is pressed and enough time has passed since the last shoot
        if Action == 1 and timeSinceLastShot > shotDelay then
            bullet_sound:play()
            ActionBullet()
            timeSinceLastShot = 0
        end
        
        -- Update the time since the last enemy spawn
        timeSinceLastEnemySpawn = timeSinceLastEnemySpawn + dt

        -- Spawn a new enemy when enough time has passed since the last enemy spawn
        if timeSinceLastEnemySpawn >= enemySpawnDelay then
            spawnEnemy()
            timeSinceLastEnemySpawn = 0
        end
        
        -- Update the position of the enemies
        
        for i, e in ipairs(enemies) do
            e.y = e.y + (math.random(180,280,100) + ((difficulty-1)*100)) * dt 
            -- Remove enemies that go off screen
            if e.y > love.graphics.getHeight() then
                table.remove(enemies, i)
            end
        end

        if score >= 2500 then
            -- Update the time since the last enemy_2 spawn
            timeSinceLastEnemy_2_Spawn = timeSinceLastEnemy_2_Spawn + dt

            -- Spawn a new enemy_2 when enough time has passed since the last enemy_2 spawn
            if timeSinceLastEnemy_2_Spawn >= enemy_2_SpawnDelay then
                spawnEnemy_2()
                timeSinceLastEnemy_2_Spawn = 0
            end
                    
            -- Update the position of the enemies_2
            for i, e2 in ipairs(enemies_2) do
                e2.y = e2.y + (math.random(150,250,100)  + ((difficulty-1)*100)) * dt 
                -- Remove enemies that go off screen
                if e2.y > love.graphics.getHeight() then
                    table.remove(enemies_2, i)
                end
            end

            -- Update the time since the last enemy_2 shot
            timeSinceLastEnemy_2_Shot = timeSinceLastEnemy_2_Shot + dt
        
            -- Shoot an enemy_2 bullet when enough time has passed since the last shot
            if timeSinceLastEnemy_2_Shot + ((difficulty-1)*0.25) >= enemy_2_ShotDelay then
                for i, e in ipairs(enemies_2) do
                    ActionEnemy_2_Bullet(e)
                end
                timeSinceLastEnemy_2_Shot = 0
            end

        end

        -- Update the position of the bullets
        for i, b in ipairs(bullets) do
            b.y = b.y - 500 * dt
            

            -- Check for collisions with enemies
            for j, e in ipairs(enemies) do
                if checkCollision(b.x, b.y, enemyBullet.sprite:getWidth()*0.0625, 
                        enemyBullet.sprite:getHeight()*0.0625, e.x, e.y, enemy_1.sprite:getWidth()*0.125, 
                        enemy_1.sprite:getHeight()*0.125) then
                    enemy_dead_sound:play()
                    -- Remove the bullet and enemy when they collide
                    table.remove(bullets, i)
                    table.remove(enemies, j)
                    local r = math.random(0,5)
                    if r == 0 then
                        Amelia_sound_3:play()
                    end
                    -- Score sumatory 
                    score = score + 100
                    updateDifficulty()
                    break
                end
            end

            -- Check for collisions with enemies_2
            for j, e2 in ipairs(enemies_2) do
                if checkCollision(b.x, b.y, enemyBullet.sprite:getWidth()*0.0625, 
                        enemyBullet.sprite:getHeight()*0.0625, e2.x, e2.y, enemy_2.sprite:getWidth()*0.18, 
                        enemy_2.sprite:getHeight()*0.18) then
                    enemy_dead_sound:play()
                    -- Remove the bullet and enemy when they collide
                    table.remove(bullets, i)
                    table.remove(enemies_2, j)
                    Amelia_sound_5:play()
                    -- Score sumatory 
                    score = score + 500
                    updateDifficulty()
                    break
                end
            end

            -- Remove bullets that go off screen
            if b.y < 0 then
                table.remove(bullets, i)
            end
        end

        -- Update the position of the enemy bullets
        for i, eB in ipairs(enemyBullets) do
            eB.y = eB.y + (400 + ((difficulty-1)*140)) * dt
            -- Remove bullets that go off screen
            if eB.y > love.graphics.getHeight() then
                table.remove(enemyBullets, i)
            end
        end
        -- Update the time since the last enemy shot
        timeSinceLastEnemyShot = timeSinceLastEnemyShot + dt

        

        -- Shoot an enemy bullet when enough time has passed since the last shot
        if timeSinceLastEnemyShot + ((difficulty-1)*0.25) >= enemyShotDelay then
            for i, e in ipairs(enemies) do
                ActionEnemyBullet(e)
            end
            timeSinceLastEnemyShot = 0
        end

        
        -- Check for collisions between enemy bullets and the spacecraft
        for i, eB in ipairs(enemyBullets) do
            if checkCollision(eB.x, eB.y-enemyBullet.sprite:getHeight()*0.0625, enemyBullet.sprite:getWidth()*0.0625, enemyBullet.sprite:getHeight()*0.0625, player.x, player.y, player.sprite:getWidth()*0.25, player.sprite:getHeight()*0.25) then
                -- Decrement the number of lives
                lives = lives - 1
                if lives > 0 then
                    Amelia_sound_2:play()
                end
                -- Remove the bullet
                table.remove(enemyBullets, i)
                -- Change the game state to "game over" when the player runs out of lives
                if lives <= 0 then
                    Amelia_sound_2:stop()
                    Amelia_sound_3:stop()
                    Amelia_sound_5:stop()
                    background_music:stop()
                    updateScores(name_user, score)
                    background_music:pause()
                    Amelia_sound_4:play()
                    gameOver()
                end
            end
        end
        player.animations.walk:update(dt)
        enemyBullet.animations.move:update(dt)
        enemy_1.animations.move:update(dt)
        enemy_2.animations.move:update(dt)
        Bullet.animations.move:update(dt)
    end
    
end

function love.draw()
    if gameState == "playing" then
        --draw backgrounds
        love.graphics.draw(background_image, 0, background_positions.y1)
        love.graphics.draw(background_image, 0, background_positions.y2)

        -- Draw the enemy bullets
        for i, eB in ipairs(enemyBullets) do
            enemyBullet.animations.move:draw(enemyBullet.spriteSheet, eB.x, eB.y-20,math.pi,0.0937, 0.0937)
        end

        -- Draw the enemies
        for i, e in ipairs(enemies) do
            enemy_1.animations.move:draw(enemy_1.spriteSheet, e.x, e.y,0,0.125, 0.125)
        end

        -- Draw the enemies_2
        for i, e2 in ipairs(enemies_2) do
            enemy_2.animations.move:draw(enemy_2.spriteSheet, e2.x, e2.y,0,0.18, 0.18)
        end

        -- Draw the powerUps
        for i, powerUp in ipairs(powerUps) do
            love.graphics.draw(powerUpImage, powerUp.x, powerUp.y,0,0.125, 0.125)
        end

        -- Draw the bullets
        for i, b in ipairs(bullets) do
            Bullet.animations.move:draw(Bullet.spriteSheet, b.x, b.y-20,0,0.0625, 0.0625)
        end
        -- Draw the player
        player.animations.walk:draw(player.spriteSheet, player.x, player.y,0,0.25, 0.25)
    

        -- Draw the number of lives
        love.graphics.print("Lives: " .. lives, 10, 10)
        -- Draw the score
        love.graphics.print("Score: " .. score, 80, 10)
        -- Draw the difficulty
        love.graphics.print("Difficulty: " .. difficulty, 180, 10)

    end

    -- Draw the game over screen when the game state is "game over"
    if gameState == "game over" then
        --draw background
        love.graphics.draw(background_image, 0, background_positions.y1)
        love.graphics.draw(background_image, 0, background_positions.y2)
        drawGameOver()
    end

    if gameState == "scores" then
        love.graphics.draw(Game_over_image, 0, Game_over_background_positions.y1,0,1,1)
        drawScoresScreen()
    end

    if gameState == "intro" then
        x_t=0--love.graphics.getWidth()/6
        y_t=love.graphics.getHeight()/10+5
        love.graphics.draw(Intro_background_image, 0, Intro_background_positions.y1,0,0.8, 0.6)

        if not Amelia_sound_1:isPlaying() then
            -- Ejecutar una acción
            local textWidth = love.graphics.getFont():getWidth("Enter your name: " .. text)
            local textHeight = love.graphics.getFont():getHeight("Enter your name: " .. text)

            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", x_t, y_t, textWidth + 10, textHeight + 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Enter your name: " .. text, x_t,y_t)
        end
    end

    if gameState == "menu" then
        -- Save the previous color
        local r, g, b, a = love.graphics.getColor()
        drawMenu()
        -- Restore the previous color
        love.graphics.setColor(r, g, b, a)
    end
end

-- Function to create and Action two new bullets
function ActionBullet()
    if powerUpActive then
        local bulletOffset = 25
        -- Dispara dos balas en lugar de una
        local newBullet1 = {x = player.x + (player.sprite:getWidth()*0.25 /2)-(Bullet.sprite:getWidth()*0.0625/2)+ bulletOffset, y = player.y}
        local newBullet2 = {x = player.x + (player.sprite:getWidth()*0.25 /2)-(Bullet.sprite:getWidth()*0.0625/2)-bulletOffset , y = player.y}
        table.insert(bullets, newBullet1)
        table.insert(bullets, newBullet2)
    else
        -- Dispara una sola bala como de costumbre
        local newBullet1 = {x = player.x + (player.sprite:getWidth()*0.25 /2)-(Bullet.sprite:getWidth()*0.0625/2) , y = player.y}
        table.insert(bullets, newBullet1)
    end
end


-- Function to spawn a new powerUp
function spawnpowerUp()
    local newpowerUp = {x = math.random(0, love.graphics.getWidth() - powerUpImage:getWidth()*0.125), y = -powerUpImage:getHeight()*0.125}
    table.insert(powerUps, newpowerUp)
end

-- Function to spawn a new enemy_1
function spawnEnemy()
    local newEnemy = {x = math.random(0, love.graphics.getWidth() - enemy_1.sprite:getWidth()*0.125), y = -enemy_1.sprite:getHeight()*0.125}
    table.insert(enemies, newEnemy)
end

-- Function to spawn a new enemy_2
function spawnEnemy_2()
    local newEnemy_2 = {x = math.random(0, love.graphics.getWidth() - enemy_2.sprite:getWidth()*0.18), y = -enemy_2.sprite:getHeight()*0.18}
    table.insert(enemies_2, newEnemy_2)
end

-- Function to check for collisions between two rectangles
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

-- Function to Action an enemy bullet
function ActionEnemyBullet(e)
    local newBullet = {x = e.x+ (enemy_1.sprite:getWidth()* 0.125/2)+(enemyBullet.sprite:getWidth()*0.0625/2), y = e.y + enemy_1.sprite:getHeight()* 0.125}
    table.insert(enemyBullets, newBullet)
end

-- Function to Action an enemy_2 bullet
function ActionEnemy_2_Bullet(e2)
    local newBullet = {x = e2.x+ (enemy_2.sprite:getWidth()* 0.18/2)+(enemyBullet.sprite:getWidth()*0.0625/2), y = e2.y + enemy_2.sprite:getHeight()* 0.18}
    table.insert(enemyBullets, newBullet)
end


function drawScoresScreen()
    -- Crea una nueva fuente con el archivo de fuente especificado
    local myFont = love.graphics.newFont("data/Franchise.ttf", 50) 
    local myFont_2 = love.graphics.newFont("data/Franchise.ttf", 30)
    local myFont_3 = love.graphics.newFont(20)
    
    -- draw  Back button
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.rectangle('fill', back_button.x, back_button.y, back_button.width, back_button.height,10,10)
    
    love.graphics.setFont(myFont_2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print('B a c k', back_button.x + 40, back_button.y + 10)    
    
    love.graphics.setFont(myFont_2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Your Score: ", 0, (love.graphics.getHeight() / 2)+20 , love.graphics.getWidth(), "center")
    love.graphics.setFont(myFont_2)
    love.graphics.printf(score, 0, (love.graphics.getHeight() / 2)+50 , love.graphics.getWidth(), "center")
    love.graphics.setColor(1, 1, 1)
    -- draw HighScores
    drawScores()
end

function drawMenu()
    --background
    love.graphics.draw(Main_menu_background_image, 0, Menu_background_positions.y1,0,0.8, 0.6)
    love.graphics.draw(Main_menu_title_background_image, 0, Menu__title_background_positions.y1,0,0.25, 0.2)
    
    -- Crea una nueva fuente con el archivo de fuente especificado
    local myFont = love.graphics.newFont("data/Franchise.ttf", 100) 
    local myFont_2 = love.graphics.newFont("data/Franchise.ttf", 30)

    -- draw  buttons
    --New GAME button---
    love.graphics.setColor(255, 255, 255, 1)
    --love.graphics.draw(button_image, NewGame_button.x-(NewGame_button.width/8), NewGame_button.y,0,0.15,0.2)
    love.graphics.rectangle('fill', NewGame_button.x, NewGame_button.y, NewGame_button.width, NewGame_button.height,10,10)
       
    love.graphics.setFont(myFont_2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print('N e w G a m e', NewGame_button.x + 16, NewGame_button.y + 10)
        
    --Highcores button---
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.rectangle('fill', HighScores_button.x, HighScores_button.y, HighScores_button.width, HighScores_button.height,10,10)

    love.graphics.setFont(myFont_2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print('S c o r e s', HighScores_button.x + 25, HighScores_button.y + 10) 
    
    --Settings button---
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.rectangle('fill', Settings_button.x, Settings_button.y, Settings_button.width, Settings_button.height,10,10)
    
    love.graphics.setFont(myFont_2)
    love.graphics.setColor(0, 0 ,0, 1)
    love.graphics.print('S e t t i n g s', Settings_button.x+10, Settings_button.y + 10) 

end

function drawGameOver()
    -- Crea una nueva fuente con el archivo de fuente especificado
    local myFont = love.graphics.newFont("data/Franchise.ttf", 100) 
    local myFont_2 = love.graphics.newFont("data/Franchise.ttf", 30)

    -- draw  buttons
    if not Amelia_sound_4:isPlaying() then
        --Menu button
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.rectangle('fill', menu_button.x, menu_button.y, menu_button.width, menu_button.height,10,10)
               
        love.graphics.setFont(myFont_2)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print('M e n u', menu_button.x + 40, menu_button.y + 10)

        --Restart button
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.rectangle('fill', restart_button.x, restart_button.y, restart_button.width, restart_button.height,10,10)
       
        love.graphics.setFont(myFont_2)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print('R e s t a r t', restart_button.x + 16, restart_button.y + 10)
        
        --Highcores button
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.rectangle('fill', HighScores_button.x, HighScores_button.y, HighScores_button.width, HighScores_button.height,10,10)
        
        --love.graphics.setFont(myFont_2)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print('S c o r e s', HighScores_button.x + 20, HighScores_button.y + 10)    
    end

    love.graphics.setFont(myFont)
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.printf("G a m e   O v e r", 0, love.graphics.getHeight()/2-150, love.graphics.getWidth(), "center")
end


-- Esta función muestra los puntajes en la pantalla
function drawScores()
    local HighScores = loadScores()
    -- get window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- calculate text position
    local titleX = windowWidth / 2
    local titleY = 10 --windowHeight / 4
    
    -- Crea una nueva fuente 
    local myFont = love.graphics.newFont("data/Franchise.ttf", 50) 
    local myFont_2 = love.graphics.newFont(20)
    local myFont_3 = love.graphics.newFont(15)
    -- Establece la fuente actual en la nueva fuente creada
    love.graphics.setFont(myFont) 
    -- draw title
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf("High Scores:", 0, titleY, windowWidth, "center")
    --love.graphics.print("Mejores puntajes:", 10, 10)

    love.graphics.setFont(myFont_2) -- Establece la fuente actual en la nueva fuente creada
    love.graphics.setColor(1, 1, 1)
    -- draw highscores

    --table.sort(highscores, compare)
    for i, entry in ipairs(HighScores) do
        local y = titleY + i * 40
        love.graphics.setFont(myFont_2)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(i..". "..entry.name..":", 0, y+15, windowWidth, "center")
        love.graphics.setFont(myFont_3)
        love.graphics.printf(entry.scores, 0, y+35, windowWidth, "center")
        love.graphics.setColor(1, 1, 1)
    end
end
  
-- Esta función se llama cuando se termina el juego y se obtiene un puntaje
function gameOver()
    gameState = "game over"
end
