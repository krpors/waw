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
	level = Level.new()
	player = Player.new()
	player:setLevel(level)

	music = love.audio.newSource("sounds/razor-ub.it", "stream")
--	music:play()

	alb = love.graphics.newImageFont("images/font.png", 
		" abcdefghijklmnopqrstuvwxyz" ..
    	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    	"123456789.,!?-+/():;%&`'*#=[]\"")

	love.graphics.setFont(alb)


	local bgimage = love.graphics.newImage("images/norfair-01.bmp")
	local phantoonAtlas = love.graphics.newImage("images/phantoon.png")
	phantoonAtlas:setFilter("nearest", "nearest")
	local quad = love.graphics.newQuad(0, 10, 71, 112, phantoonAtlas:getWidth(), phantoonAtlas:getHeight())

	camera:newLayer(0.1, 
		function()
			for i = -10, 10 do
				for j = -10, 10 do
					love.graphics.setColor(255, 255, 255)
					love.graphics.draw(bgimage, i * 256, j * 256)
				end
			end
		end)

	-- This is ugly. Default scope is global so we can misuse this to
	-- quickly prototype something :) 
	opacity = 120
	oc = 2

	camera:newLayer(0.2,
		function()
			if opacity >= 254  then oc = -1 end 
			if opacity <= 0 then oc = 1 end

			opacity = opacity + oc
			love.graphics.setColor(255, opacity, 255, opacity)
			love.graphics.draw(phantoonAtlas, quad, 200, 300, 0, 5)
		end)
end

function love.update(dt)
	player:update(dt)
	-- center the cam on the player (lock in)
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
	end

	if key == "s" then
		zooming_in = false
		zooming_out = true
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

	-- draw layers, level and player
	camera:draw()
	level:draw()
	player:draw()

	camera:unset()
end
