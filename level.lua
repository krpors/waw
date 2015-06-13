Level = {}
Level.__index = Level 

function Level.new()
	local self = setmetatable({}, Level)

	self.imgtiles = love.graphics.newImage("images/tiles.png")
	self.imgtiles:setFilter("linear", "nearest")

	self.maintile = love.graphics.newQuad(222, 712, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.bgtile = love.graphics.newQuad(205, 627, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.loltile2 = love.graphics.newQuad(188, 627, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.grasstile1 = love.graphics.newQuad(171, 695, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.grasstile2 = love.graphics.newQuad(171, 678, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())

	self.map = {
		{ 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 3 },
		{ 3, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 4, 4, 4, 4, 4 },
		{ 3, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 },
		{ 3, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1 },
		{ 3, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
		{ 3, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 3, 0, 0, 0, 0, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 3, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0 },
		{ 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0 },
		{ 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
		{ 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	}

	self.tilesize = 50

	return self
end

function Level:getBoundsForTile(x, y)
	local xx = (x - 1) * self.tilesize
	local yy = (y - 1) * self.tilesize
	return xx, yy, self.tilesize, self.tilesize 
end

function Level:update(dt)
end

function Level:draw()
	for y = 1, #self.map do
		for x = 1, #self.map[y] do
			thetile = nil
			if self.map[y][x] == 0 then
				--love.graphics.setColor(40, 40, 40)
				thetile = self.bgtile
			elseif self.map[y][x] == 1 then
				love.graphics.setColor(255, 255, 255)
				thetile = self.maintile
			elseif self.map[y][x] == 2 then
				love.graphics.setColor(255, 255, 255)
				thetile = self.loltile2
			elseif self.map[y][x] == 3 then
				love.graphics.setColor(255, 255, 255)
				thetile = self.grasstile1
			elseif self.map[y][x] == 4 then
				love.graphics.setColor(255, 255, 255)
				thetile = self.grasstile2
			end

			if thetile ~= nil then
				love.graphics.draw(self.imgtiles, thetile, (x-1) * self.tilesize - 1, (y-1) * self.tilesize - 1, 0, self.tilesize / 16, self.tilesize / 16)
			end
		end
	end
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Welcome!!! A b c 123 454", 0, -20)

    love.graphics.setColor(255, 0, 0)
    love.graphics.print("Yeah, jumping off here", 1050, 600)
    love.graphics.print("incurs the death penalty.", 1050, 612)
    love.graphics.print("Fix it plx.", 1050, 624)
end
