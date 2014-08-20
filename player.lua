Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.size = 20

	self.moveright = false
	self.moveleft = false
	self.moveleft = false

	self.x = 60
	self.y = 20

	self.speed = 150

	return self
end

function Player:setLevel(level)
	self.level = level
end

function Player:collides()
	for y = 1, #self.level.map do
		for x = 1, #self.level.map[y] do
			-- Check if the player's y position (y + size) intersects a map block
			-- First of all, only check on blocks which are collidable:
			local tiletype = self.level.map[y][x]
			if tiletype > 0 then
				local xx, yy, w, h = self.level:getBoundsForTile(x, y)
				if self.x + self.size >= xx and 
					self.x <= xx + w and 
					self.y + self.size >= yy and 
					self.y <= yy + h then
					return true
				end
			end
		end
	end

	return false
end

-- Determines whether the new x,y position will mean a collision
function Player:willCollide(newx, newy)
	for y = 1, #self.level.map do
		for x = 1, #self.level.map[y] do
			-- Check if the player's y position (y + size) intersects a map block
			-- First of all, only check on blocks which are collidable:
			local tiletype = self.level.map[y][x]
			if tiletype == 1 then
				local xx, yy, w, h = self.level:getBoundsForTile(x, y)
				if newx + self.size >= xx and 
					newx <= xx + w and 
					newy + self.size >= yy and 
					newy <= yy + h then
					return true
				end
			end
		end
	end

	return false
end

function Player:update(dt)
	local newx = self.x
	local newy = self.y

	if self.moveleft then newx = self.x - self.speed * dt end
	if self.moveright then newx = self.x + self.speed * dt end
	if self.moveup then newy = self.y - self.speed * dt end
	if self.movedown then newy = self.y + self.speed * dt end

	self.collide = self:willCollide(newx, newy)

	if self.collide then
		return
	else
	end	

	self.x = newx
	self.y = newy
end

function Player:left()
	self.moveleft = true
end

function Player:right()
	self.moveright = true
end

function Player:up()
	self.moveup = true
end


function Player:down()
	self.movedown = true
end


function Player:stop()
	self.moveleft = false
	self.moveright = false
	self.movedown = false
	self.moveup = false
end

-- Actually draws the player on the screen
function Player:draw()
	if self.collide then 
		love.graphics.setColor(255, 0, 0)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)

	love.graphics.print("Player at (" .. self.x .. ", " .. self.y .. ")", 0, 500)
end
