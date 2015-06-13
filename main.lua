require "level"
require "player"
require "camera"

local font

local level
local player
local music

local zooming_in = false
local zooming_out = false

local zoomiter = 1
local zoomspeed = 1

soundJump = love.audio.newSource("sounds/jump.wav", "static")
soundBump = love.audio.newSource("sounds/bump.wav", "static")
soundDrop = love.audio.newSource("sounds/drop.wav", "static")

function love.load()
	love.window.setMode(800, 600, {fsaa=2})
	love.window.setTitle("Love2D prototyping")
	level = Level.new()
	player = Player.new()
	player:setLevel(level)

	music = love.audio.newSource("sounds/razor-ub.it", "stream")
	music:play()

	alb = love.graphics.newImageFont("images/font.png", 
		" abcdefghijklmnopqrstuvwxyz" ..
    	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    	"123456789.,!?-+/():;%&`'*#=[]\"")

	love.graphics.setFont(alb)
end

function love.update(dt)
	player:update(dt)
	camera:setPosition(player.x - 800/2 * camera.scaleX, player.y - 600/2 * camera.scaleY)

	if zooming_in then
		if zoomspeed <= 0.5 then
			zooming_in = false
		else
			zoomspeed = zoomspeed - dt
			camera:setScale(zoomspeed, zoomspeed)
		end
	end

	if zooming_out then
		if zoomspeed >= 2 then
			zooming_out = false
		else
			zoomspeed = zoomspeed + dt
			camera:setScale(zoomspeed, zoomspeed)
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if key == "a" then
		zooming_in = true
		zooming_out = false
		--camera:scale(2, 2)
	end

	if key == "s" then
		zooming_in = false
		zooming_out = true
		--camera:scale(0.5, 0.5)
	end

	if key == "left" then
		player:left()
	end

	if key == "right" then
		player:right()
	end

	if key == "up" then
		player:up()
	end

	if key == "down" then
		player:down()
	end
	if key == " " then
		player:jump()
	end

end

function love.keyreleased(key)
	if key == "left" or key == "right" or key == "up" or key == "down" then
		player:stop()
	end
end

function love.draw()
	camera:set()

	level:draw()
	player:draw()

	camera:unset()
end
