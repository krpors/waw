require "level"
require "player"
require "camera"
require "layer"

DEBUG = false

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

-- Loads up some background layers, parallax scrolling and such.
function loadLayers()
	local layer1 = Layer.new(0.2)
	layer1:loadImage("images/norfair-01.bmp")
	layer1.pulsating = false

	local layer2 = Layer.new(2.0)
	layer2:loadImage("images/bubbles.png") 
	layer2.pulsating = true 
	layer2.opacity = 255

	camera:addLayer(layer1)
	camera:addLayer(layer2)
end

function love.load()
	level = Level.new()
	player = Player.new()
	player:setLevel(level)

	-- just playtesting here
	local maxX, maxY = level:getDimensions()
	camera:setBounds(0, 0, maxX / 3, maxY / 3)

	local playerStartX, playerStartY = level:getPlayerStartPos()
	player.x = playerStartX
	player.y = playerStartY

	music = love.audio.newSource("sounds/razor-ub.it", "stream")
	--music:play()

	alb = love.graphics.newImageFont("images/font.png", 
		" abcdefghijklmnopqrstuvwxyz" ..
    	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    	"123456789.,!?-+/():;%&`'*#=[]\"")

	love.graphics.setFont(alb)

	loadLayers()
end

function love.update(dt)
	player:update(dt)
	camera:update(dt)
	-- center the cam on the player (lock in)
	camera:setPosition(player.x - 800/2 * camera.scaleX, player.y - 600/2 * camera.scaleY)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
	if key == "left" then player:left() end
	if key == "right" then player:right() end
	if key == "up" then player:up() end
	if key == "down" then player:down() end
	if key == " " then player:jump() end
	if key == "d" then DEBUG = not DEBUG end
	if key == "l" then 
		level.map = love.filesystem.load("levels/002.lua")()
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

	if DEBUG then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("DEBUGGING is ON", 0, 0)
	end
end
