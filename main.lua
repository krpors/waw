require "level"
require "player2"

local level
local player

function love.load()
	love.window.setMode(800, 600, {fsaa=2})
	level = Level.new()
	player = Player2.new()
	player:setLevel(level)
end

function love.update(dt)
	player:update(dt)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
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

end

function love.keyreleased(key)
	if key == "left" or key == "right" or key == "up" or key == "down" then
		player:stop()
	end
end

function love.draw()
	level:draw()
	player:draw()
end
